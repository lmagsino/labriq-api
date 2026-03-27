require 'rails_helper'

RSpec.describe "Shares", type: :request do
  describe "GET /api/v1/share/:token" do
    let(:scan) { create(:scan, status: :completed) }

    it "returns the scan for a valid share token" do
      get "/api/v1/share/#{scan.share_token}"

      expect(response).to have_http_status(:ok)
      expect(json.dig("data", "id")).to eq(scan.id.to_s)
    end

    it "returns 404 for an invalid token" do
      get "/api/v1/share/nonexistent"

      expect(response).to have_http_status(:not_found)
    end

    it "does not require authentication" do
      get "/api/v1/share/#{scan.share_token}"

      expect(response).to have_http_status(:ok)
    end
  end
end
