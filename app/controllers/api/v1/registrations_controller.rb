class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        user: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          plan_type: resource.plan_type
        },
        message: "Signed up successfully."
      }, status: :created
    else
      render json: {
        errors: resource.errors.full_messages,
        message: "Signup failed."
      }, status: :unprocessable_entity
    end
  end
end
