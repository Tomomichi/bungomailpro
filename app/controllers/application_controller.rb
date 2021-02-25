class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit
  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound,   with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  private

  def render_404(error = nil)
    logger.info "[404] Rendering 404 with exception: #{error.message}" if error
    render file: Rails.root.join("public", "404.html"), layout: false, status: :not_found
  end

  def not_authorized
    flash[:warning] = '権限がありません。。ログイン状態をご確認ください。'
    redirect_to request.referer || login_path
  end

  def not_authenticated
    flash[:warning] = 'ログインしてください。'
    redirect_to login_path
  end
end
