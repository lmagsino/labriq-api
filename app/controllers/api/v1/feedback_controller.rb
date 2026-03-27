class Api::V1::FeedbackController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    feedback = Feedback.new(feedback_params)

    if feedback.save
      render json: { message: "Feedback received. Thank you!" }, status: :created
    else
      render json: { errors: feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:scan_id, :lab_result_id, :feedback_type, :comment)
  end
end
