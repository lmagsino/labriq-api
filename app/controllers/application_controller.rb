class ApplicationController < ActionController::API
  rescue_from StandardError, with: :internal_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def internal_error(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.first(10).join("\n"))
    render json: { error: "Something went wrong" }, status: :internal_server_error
  end
end
