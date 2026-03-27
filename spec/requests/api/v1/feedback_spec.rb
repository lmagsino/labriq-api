require 'rails_helper'

RSpec.describe "Feedback", type: :request do
  let(:scan) { create(:scan) }

  describe "POST /api/v1/feedback" do
    context "with valid params" do
      it "creates feedback and returns 201" do
        post "/api/v1/feedback", params: {
          feedback: { scan_id: scan.id, feedback_type: "general", comment: "Great app!" }
        }, as: :json

        expect(response).to have_http_status(:created)
        expect(json["message"]).to eq("Feedback received. Thank you!")
      end

      it "works without authentication" do
        post "/api/v1/feedback", params: {
          feedback: { scan_id: scan.id, feedback_type: "incorrect_value" }
        }, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "returns 422 when feedback_type is missing" do
        post "/api/v1/feedback", params: {
          feedback: { scan_id: scan.id }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).to be_present
      end
    end
  end
end
