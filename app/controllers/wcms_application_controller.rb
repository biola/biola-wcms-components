# ApplicationController should inherit from this controller.
class WcmsApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate!
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout -> { (@layout || :application).to_s }

  def true_user
    authentication.user
  end
  helper_method :true_user

  def current_user
    unless @current_user
      # clear impersonation_id if true_user is not logged in
      if session[:impersonation_id] && !true_user
        session[:impersonation_id] = nil
      end

      # Fetch impersonated user from their ID, otherwise return true_user
      @current_user = (session[:impersonation_id] && User.where(id: session[:impersonation_id]).first) || true_user
    end
    @current_user
  end
  helper_method :current_user

  protected

  def impersonate_user(user)
    @current_user = user
    session[:impersonation_id] = user.id.to_s
  end

  def stop_impersonating_user
    @impersonated_var = true_user
    session[:impersonation_id] = nil
  end

  def authenticate!
    authentication.perform || render_error_page(401)
  end

  def authentication
    @authentication ||= CasAuthentication.new(session)
  end

  def render_error_page(status)
    render file: "#{Rails.root}/public/#{status}",
           formats: [:html],
           status: status,
           layout: false
  end

  def user_not_authorized
    render_error_page(403)
  end
end
