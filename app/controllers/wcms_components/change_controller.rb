class WcmsComponents::ChangeController < ApplicationController

  before_filter :set_change, except: :index
  before_filter :pundit_authorize

  def index
    @changes = policy_scope(Change)
    @changes = @changes.where(association_chain: {'$elemMatch' => {name: params[:klass].classify}})

    # Filter Values
    @available_users = User.find @changes.distinct(:modifier)

    @changes = @changes.where(modifier_id: params[:user_id]) if params[:user_id].present?
    @changes = @changes.where(action: params[:action_taken]) if params[:action_taken].present?
    @changes = @changes.by_last_change(params[:last_change]) if params[:last_change].present?

    @changes = @changes.desc(:updated_at)
    @changes = @changes.page(params[:page]).per(25)
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
  def set_change
    @change = Change.find(params[:id])
  end

  def pundit_authorize
    authorize (@change || Change)
  end

end
