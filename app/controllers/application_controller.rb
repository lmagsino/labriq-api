class ApplicationController < ActionController::API
  rescue_from StandardError, with: :internal_error

  private

  def internal_error(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.first(10).join("\n"))
    render json: { error: "Something went wrong" }, status: :internal_server_error
  end
end
