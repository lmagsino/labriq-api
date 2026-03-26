class Api::V1::ScansController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:create, :show]

  def create
    head :not_implemented
  end

  def show
    head :not_implemented
  end

  def index
    head :not_implemented
  end
end
