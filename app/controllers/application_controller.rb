class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def render_turbo_flash
    turbo_stream.update("flash", partial: "shared/flashes")
  end
end
