class WcmsComponents::ChangesController < ApplicationController

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
    # Retrieve object of who's history you are desiring after.
    @object = params[:klass].safe_constantize.find(params[:id])
    @changes = []
    @available_users = []
    object_history = @object.history_tracks # TODO: this seems to not be pulling the embedded document history
    @available_users += User.find(object_history.distinct(:modifier_id)) if object_history

    # Apply the filters -- if there are no results then it will be as an empty array
    @changes += set_filters(object_history)

    # Retrieve applicable nested object histories defined in the respective publishers settings
    fetch_nested_histories(@object) do |histories|
      if histories.present?
        @available_users += User.find(histories.distinct(:modifier_id))
        @changes += set_filters(histories)
      end
    end

    @available_users.uniq!

    @changes.sort!{ |a,b| b.created_at <=> a.created_at }
  end

  def undo
    set_modifier

    if @change.undo! current_user
      if @change.action == 'create'
        flash[:info] = "Change was successfully reversed. <a href=wcms_components/changes/#{Change.last.id}/undo_destroy>Undo</a>"
      else
        flash[:info] = "Change was successfully reversed."
      end
    else
      flash[:error] = "Something went wrong. Please try again."
    end

    # Ensure that the object wasn't just undone into nonexistence.
    #  For the time being referenced documents will not be able to be undone as
    #  we have no way to redirect back to the owning object.
    @parent = params[:owning_class].safe_constantize
    if @parent.where(id: params[:owning_id]).present?
      redirect_to @parent.find(params[:owning_id])
    else
      redirect_to @parent
    end
  end

  def undo_destroy
    # Undo destory at the moment is only available in flash notices after destroy is completed.
    #  Because of this the modifier for the change will be set as the last known object modifier.
    #  This could cause issues so we may want to find a way to set it since mongoid history wont.
    if @change.undo!
      flash[:info] = "#{@change.original[:title]} has been successfully recreated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to :back
  end

  private
  # Mongoid history for some reason is refraining from setting modifier on undo! so this will set it manually
  #  if the parent object is present.
  def set_modifier
    if @change.trackable_root.present?
      @change.trackable_root.modifier = current_user
    end
  end

  def set_filters(changes)
    changes = changes.where(modifier_id: params[:user_id]) if params[:user_id].present?
    changes = changes.where(action: params[:action_taken]) if params[:action_taken].present?
    changes = changes.by_last_change(params[:last_change]) if params[:last_change].present?
    changes
  end

  def fetch_nested_histories(object, &block)
    # Trackable relations is an array of nested (e.g. has_many/belongs_to) relationships (e.g. ["attachments", "concentrations"])
    #  for a given class. Embedded documents are handled by Mongoid History.
    if relations = Settings.trackable_relations[params[:klass]]

      # Getting all the related objects for each relationship.
      all_related_objects = relations.map{ |rels| object.send(rels) }.flatten.compact

      # Passing the histories as a parameter to the block defined in object_index
      all_related_objects.each { |related_object| block.call(related_object.history_tracks) }
    end
  end

  def set_change
    @change = Change.find(params[:id])
  end

  def pundit_authorize
    authorize (@change || Change)
  end

end
