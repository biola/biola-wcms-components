class WcmsComponents::TagsController < ApplicationController

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @tags = Tag.by_type('object').custom_search(params[:q]).limit(10)
    render json: @tags.to_json(only: [:tag])
  end

end
