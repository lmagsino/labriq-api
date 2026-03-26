class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  # Check auth before sign_out so we can return 401 for unauthenticated requests
  before_action :check_authenticated!, only: :destroy

  protected

  # ActionController::API has no flash — suppress Devise's flash messages
  def set_flash_message!(key, kind, options = {}); end
  def set_flash_message(key, kind, options = {}); end

  private

  def respond_with(resource, _opts = {})
    render json: {
      user: {
        id: resource.id,
        email: resource.email,
        name: resource.name,
        plan_type: resource.plan_type
      },
      message: "Logged in successfully."
    }, status: :ok
  end

  def respond_to_on_destroy(*_args)
    render json: { message: "Logged out successfully." }, status: :ok
  end

  def check_authenticated!
    unless current_user
      render json: { message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
