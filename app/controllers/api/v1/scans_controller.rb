class Api::V1::ScansController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:create, :show]

  # POST /api/v1/scans
  def create
    if params[:lab_files].blank?
      return render json: { error: "At least one lab file is required" }, status: :unprocessable_entity
    end

    scan = Scan.new(user: current_user, status: :pending)
    scan.file_count = (params[:lab_files]&.length || 0) + (params[:prescription_files]&.length || 0)
    scan.lab_files.attach(params[:lab_files])
    scan.prescription_files.attach(params[:prescription_files]) if params[:prescription_files].present?

    if scan.save
      AnalyzeScanJob.perform_async(scan.id)
      render json: ScanSerializer.new(scan).serializable_hash, status: :created
    else
      render json: { errors: scan.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/scans/:id
  def show
    scan = Scan.includes(:lab_results, :doctor_questions).find(params[:id])
    render json: ScanSerializer.new(scan, include: [:lab_results, :doctor_questions]).serializable_hash
  end

  # GET /api/v1/scans (requires auth)
  def index
    scans = current_user.scans.recent.limit(50)
    render json: ScanSerializer.new(scans).serializable_hash
  end
end
