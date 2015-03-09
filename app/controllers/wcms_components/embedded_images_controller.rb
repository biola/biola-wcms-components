class WcmsComponents::EmbeddedImagesController < ApplicationController

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def create
    # Anyone who is logged in should be able to access this.
    @embedded_image = EmbeddedImage.new

    file = params[:file]
    @embedded_image.upload = file

    if @embedded_image.save
      render json: { filelink: @embedded_image.upload.url }
    else
      render json: { error: true, messages: @embedded_image.errors.full_messages }
    end
  end

end
