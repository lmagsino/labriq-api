require 'rails_helper'

RSpec.describe "Scans", type: :request do
  let(:user) { create(:user) }
  let(:pdf_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/sample_lab.pdf"),
      "application/pdf"
    )
  end

  describe "POST /api/v1/scans" do
    context "without lab files" do
      it "returns 422" do
        post "/api/v1/scans", params: {}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("At least one lab file is required")
      end
    end

    context "with lab files" do
      before { allow(AnalyzeScanJob).to receive(:perform_async) }

      it "creates a scan and enqueues the job" do
        post "/api/v1/scans", params: { lab_files: [pdf_file] }

        expect(response).to have_http_status(:created)
        expect(json.dig("data", "attributes", "status")).to eq("pending")
        expect(AnalyzeScanJob).to have_received(:perform_async)
      end

      it "associates the scan with the current user when authenticated" do
        token = login_as(user)
        post "/api/v1/scans", params: { lab_files: [pdf_file] },
             headers: { "Authorization" => token }

        scan = Scan.last
        expect(scan.user).to eq(user)
      end

      it "creates an anonymous scan when not authenticated" do
        post "/api/v1/scans", params: { lab_files: [pdf_file] }

        scan = Scan.last
        expect(scan.user).to be_nil
      end
    end
  end

  describe "GET /api/v1/scans/:id" do
    let(:scan) { create(:scan, user: user, status: :completed) }

    it "returns the scan" do
      get "/api/v1/scans/#{scan.id}"

      expect(response).to have_http_status(:ok)
      expect(json.dig("data", "id")).to eq(scan.id.to_s)
      expect(json.dig("data", "attributes", "status")).to eq("completed")
    end

    it "returns 404 for unknown scan" do
      get "/api/v1/scans/99999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/scans" do
    context "without auth" do
      it "returns 401" do
        get "/api/v1/scans"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with auth" do
      it "returns the user's scans" do
        create_list(:scan, 3, user: user)
        token = login_as(user)

        get "/api/v1/scans", headers: { "Authorization" => token }

        expect(response).to have_http_status(:ok)
        expect(json["data"].length).to eq(3)
      end

      it "does not return other users' scans" do
        create(:scan, user: create(:user))
        token = login_as(user)

        get "/api/v1/scans", headers: { "Authorization" => token }

        expect(response).to have_http_status(:ok)
        expect(json["data"]).to be_empty
      end
    end
  end
end
