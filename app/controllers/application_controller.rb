class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    documents_path
  end

  def render_turbo_flash
    turbo_stream.update("flash", partial: "shared/flashes")
  end
end
