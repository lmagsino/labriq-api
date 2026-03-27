require 'rails_helper'

RSpec.describe AnalyzeScanJob do
  let(:scan) { create(:scan, status: :pending) }

  let(:ai_result) do
    {
      "summary" => "Results look mostly normal.",
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
          "explanation" => "Blood sugar is healthy."
        }
      ],
      "questions_for_doctor" => ["Should I retest in 6 months?", "Is my diet ok?", "Any concerns?"],
      "lifestyle_tips" => ["Stay hydrated."]
    }
  end

  before do
    allow(ClaudeService).to receive(:new).and_return(
      instance_double(ClaudeService, analyze_lab_results: ai_result)
    )
    allow(CleanupScanFilesJob).to receive(:perform_in)
  end

  describe "#perform" do
    it "sets the scan status to processing then completed" do
      described_class.new.perform(scan.id)

      expect(scan.reload.status).to eq("completed")
    end

    it "saves summary, urgency, and analyzed_at on the scan" do
      described_class.new.perform(scan.id)

      scan.reload
      expect(scan.summary).to eq("Results look mostly normal.")
      expect(scan.urgency).to eq("normal")
      expect(scan.analyzed_at).to be_present
    end

    it "creates LabResult records" do
      expect { described_class.new.perform(scan.id) }.to change { scan.lab_results.count }.by(1)

      result = scan.lab_results.first
      expect(result.name).to eq("Glucose")
      expect(result.status).to eq("normal")
    end

    it "creates DoctorQuestion records" do
      expect { described_class.new.perform(scan.id) }.to change { scan.doctor_questions.count }.by(3)
    end

    it "schedules CleanupScanFilesJob after 60 seconds" do
      described_class.new.perform(scan.id)

      expect(CleanupScanFilesJob).to have_received(:perform_in).with(60, scan.id)
    end

    context "when ClaudeService raises an error" do
      before do
        allow(ClaudeService).to receive(:new).and_return(
          instance_double(ClaudeService, analyze_lab_results: nil).tap do |svc|
            allow(svc).to receive(:analyze_lab_results).and_raise(RuntimeError, "API down")
          end
        )
      end

      it "sets the scan status to failed" do
        expect { described_class.new.perform(scan.id) }.to raise_error(RuntimeError)

        expect(scan.reload.status).to eq("failed")
      end

      it "re-raises the error for Sidekiq retry" do
        expect { described_class.new.perform(scan.id) }.to raise_error(RuntimeError, "API down")
      end
    end
  end
end
