class WcmsComponents::ChangeController < ApplicationController

  before_filter :set_change, only: [:undo, :undo_destroy]
  before_filter :pundit_authorize

  def index
    @changes = policy_scope(Change)
    @changes = @changes.where(association_chain: {'$elemMatch' => {name: params[:klass].classify}})

    # Filter Values
    @available_users = User.find(@changes.distinct(:modifier_id))

    @changes = @changes.where(modifier_id: params[:user_id]) if params[:user_id].present?
    @changes = @changes.where(action: params[:action_taken]) if params[:action_taken].present?
    @changes = @changes.by_last_change(params[:last_change]) if params[:last_change].present?

    @changes = @changes.desc(:updated_at)
    @changes = @changes.page(params[:page]).per(25)
  end

  def object_index
    object = params[:klass].safe_constantize.find(params[:id])
    @changes = []
    @available_users = []
    object_history = object.history_tracks
    @available_users += User.find(object_history.distinct(:modifier_id)) if object_history

    # Apply the filters -- if there are no results then it will be as an empty array
    @changes += set_filters(object_history)

    # Retrieve applicable nested object histories defined in the respective publishers settings
    fetch_nested_histories(object)

    @changes.sort!{ |a,b| b.created_at <=> a.created_at }
  end

  def undo
    if @change.undo!(modifier: current_user)
      if @change.action == 'create'
        flash[:info] = "Change was successfully reversed. <a href=/change/#{Change.last.id}/undo_destroy>Undo</a>"
      else
        flash[:info] = "Change was successfully reversed."
      end
    else
      flash[:error] = "Something went wrong. Please try again."
    end

    # ensure that the object wasn't just undone into nonexistence
    @parent = @change.trackable_root
    if @parent.class.where(id: @parent.id).present?
      redirect_to @parent
    else
      redirect_to @parent.class
    end
  end

  def undo_destroy
    if @change.undo!(modifier: current_user)
      flash[:info] = "#{@change.original[:title]} has been successfully recreated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to :back
  end

  private
  def set_filters(changes)
    changes = changes.where(modifier_id: params[:user_id]) if params[:user_id].present?
    changes = changes.where(action: params[:action_taken]) if params[:action_taken].present?
    changes = changes.by_last_change(params[:last_change]) if params[:last_change].present?
    changes
  end

  def fetch_nested_histories(object)
    relations = Settings.trackable_relations[params[:klass]]
    if relations.present?
      relations = relations.map{ |rels| object.send(rels) }.flatten
      relations.map do |relation|
        relation_tracks = relation.history_tracks
        if relation_tracks.present?
          @available_users += User.find(relation_tracks.distinct(:modifier_id))

          # Apply the filters -- if there are no results then it will be as an empty array
          @changes += set_filters(relation_tracks)

          @available_users.uniq!
        end
      end
    end
  end

  def set_change
    @change = Change.find(params[:id])
  end

  def pundit_authorize
    authorize (@change || Change)
  end

end
