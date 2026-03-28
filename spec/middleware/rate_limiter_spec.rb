require 'rails_helper'

RSpec.describe RateLimiter, type: :request do
  let(:redis) { Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")) }
  let(:pdf_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/sample_lab.pdf"),
      "application/pdf"
    )
  end

  before do
    allow(AnalyzeScanJob).to receive(:perform_async)
    # Clear rate limit keys for test IP
    redis.del("rate_limit:scans:127.0.0.1")
  end

  after do
    redis.del("rate_limit:scans:127.0.0.1")
  end

  describe "POST /api/v1/scans rate limiting" do
    context "within the limit" do
      it "allows requests under the threshold" do
        post "/api/v1/scans", params: { lab_files: [pdf_file] }
        expect(response.status).not_to eq(429)
      end
    end

    context "when limit is exceeded" do
      before do
        redis.set("rate_limit:scans:127.0.0.1", RateLimiter::SCAN_LIMIT)
        redis.expire("rate_limit:scans:127.0.0.1", RateLimiter::WINDOW_SECONDS)
      end

      it "returns 429 with error message" do
        post "/api/v1/scans", params: { lab_files: [pdf_file] }

        expect(response).to have_http_status(429)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Rate limit exceeded. Max 5 scans per hour.")
      end

      it "does not create a scan" do
        expect {
          post "/api/v1/scans", params: { lab_files: [pdf_file] }
        }.not_to change(Scan, :count)
      end
    end

    context "after exactly hitting the limit" do
      it "blocks the next request after 5 successful ones" do
        5.times do
          post "/api/v1/scans", params: { lab_files: [pdf_file] }
          expect(response.status).not_to eq(429)
        end

        post "/api/v1/scans", params: { lab_files: [pdf_file] }
        expect(response).to have_http_status(429)
      end
    end

    context "non-scan endpoints" do
      it "does not rate limit other routes" do
        redis.set("rate_limit:scans:127.0.0.1", 100)

        get "/health"
        expect(response.status).not_to eq(429)
      end
    end
  end
end
