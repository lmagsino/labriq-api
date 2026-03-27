require 'rails_helper'

RSpec.describe ClaudeService do
  let(:service) { described_class.new }
  let(:scan) { create(:scan) }

  let(:valid_ai_response) do
    {
      "summary" => "Most results are within normal range.",
      "prescription_context" => nil,
      "urgency" => "normal",
      "urgency_note" => nil,
      "values" => [
        {
          "name" => "Glucose",
          "value" => "95",
          "unit" => "mg/dL",
          "status" => "normal",
          "reference" => "70-100",
          "explanation" => "Your blood sugar is in the healthy range."
        }
      ],
      "questions_for_doctor" => ["Should I retest in 6 months?"],
      "lifestyle_tips" => ["Stay hydrated."]
    }
  end

  before do
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: {
          content: [{ type: "text", text: valid_ai_response.to_json }]
        }.to_json
      )

    # Stub file_to_block to avoid needing real attached files or blob downloads
    allow(service).to receive(:build_content_blocks).and_return([
      { type: "document", source: { type: "base64", media_type: "application/pdf", data: "ZmFrZQ==" } },
      { type: "text", text: "Please analyze these lab results and respond with the JSON structure as instructed." }
    ])
  end

  describe "#analyze_lab_results" do
    it "calls the Claude API and returns parsed JSON" do
      result = service.analyze_lab_results(scan)

      expect(result["summary"]).to eq("Most results are within normal range.")
      expect(result["urgency"]).to eq("normal")
      expect(result["values"].length).to eq(1)
      expect(result["values"].first["name"]).to eq("Glucose")
    end

    it "sends the correct headers to the API" do
      service.analyze_lab_results(scan)

      expect(WebMock).to have_requested(:post, "https://api.anthropic.com/v1/messages")
        .with(headers: { "x-api-key" => ENV["ANTHROPIC_API_KEY"] })
    end

    it "raises an error when the API returns a non-200 status" do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 500, body: '{"error": "server error"}')

      expect { service.analyze_lab_results(scan) }.to raise_error(RuntimeError, /Claude API error: 500/)
    end

    it "strips markdown code fences from the response" do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: {
            content: [{ type: "text", text: "```json\n#{valid_ai_response.to_json}\n```" }]
          }.to_json
        )

      result = service.analyze_lab_results(scan)
      expect(result["summary"]).to eq("Most results are within normal range.")
    end
  end
end
