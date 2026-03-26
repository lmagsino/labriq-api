require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      { user: { email: "new@example.com", password: "password123", name: "New User" } }
    end

    context "with valid params" do
      it "creates a user and returns JWT in Authorization header" do
        post "/api/v1/auth/register", params: valid_params, as: :json

        expect(response).to have_http_status(:created)
        expect(response.headers['Authorization']).to be_present
        expect(json['user']['email']).to eq("new@example.com")
        expect(json['message']).to eq("Signed up successfully.")
      end
    end

    context "with invalid params" do
      it "returns 422 when email is missing" do
        post "/api/v1/auth/register", params: { user: { password: "password123" } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to be_present
      end

      it "returns 422 when email is already taken" do
        create(:user, email: "taken@example.com")
        post "/api/v1/auth/register", params: { user: { email: "taken@example.com", password: "password123" } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns JWT in Authorization header" do
        post "/api/v1/auth/login", params: { user: { email: "login@example.com", password: "password123" } }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers['Authorization']).to be_present
        expect(json['user']['email']).to eq("login@example.com")
        expect(json['message']).to eq("Logged in successfully.")
      end
    end

    context "with invalid credentials" do
      it "returns 401" do
        post "/api/v1/auth/login", params: { user: { email: "login@example.com", password: "wrongpassword" } }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let!(:user) { create(:user) }

    it "revokes the JWT and returns 200" do
      token = login_as(user)
      delete "/api/v1/auth/logout", headers: { 'Authorization' => token }

      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq("Logged out successfully.")
    end

    it "returns 401 without a token" do
      delete "/api/v1/auth/logout"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "protected endpoints" do
    it "returns 401 when no JWT provided" do
      get "/api/v1/scans"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 when JWT is invalid" do
      get "/api/v1/scans", headers: { 'Authorization' => 'Bearer invalid.token.here' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
