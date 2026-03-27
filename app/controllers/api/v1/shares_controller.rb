class Api::V1::SharesController < ApplicationController
  def show
    scan = Scan.includes(:lab_results, :doctor_questions).find_by!(share_token: params[:token])
    render json: ScanSerializer.new(scan, include: [:lab_results, :doctor_questions]).serializable_hash
  end
end
