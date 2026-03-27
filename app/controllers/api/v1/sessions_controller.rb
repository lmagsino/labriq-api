class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  protected

  # Devise calls this (via prepend_before_action) when no user is signed in.
  # Override to return 401 for JWT-only auth instead of the default no_content.
  def verify_signed_out_user
    unless request.authorization&.start_with?('Bearer ')
      render json: { message: "Couldn't find an active session." }, status: :unauthorized
    end
  end

  # ActionController::API has no flash — suppress Devise's flash messages
  def set_flash_message!(key, kind, options = {}); end
  def set_flash_message(key, kind, options = {}); end

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
end
