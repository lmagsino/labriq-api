class AnalyzeScanJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 2

  def perform(scan_id)
    scan = Scan.find(scan_id)
    scan.update!(status: :processing)

    result = ClaudeService.new.analyze_lab_results(scan)

    ActiveRecord::Base.transaction do
      scan.update!(
        summary: result["summary"],
        prescription_context: result["prescription_context"],
        urgency: result["urgency"] || "normal",
        raw_ai_response: result,
        analyzed_at: Time.current,
        status: :completed
      )

      (result["values"] || []).each_with_index do |val, idx|
        scan.lab_results.create!(
          name: val["name"],
          value: val["value"],
          unit: val["unit"],
          status: val["status"] || "normal",
          reference_range: val["reference"],
          explanation: val["explanation"],
          sort_order: idx
        )
      end

      (result["questions_for_doctor"] || []).each_with_index do |q, idx|
        scan.doctor_questions.create!(
          question: q,
          sort_order: idx
        )
      end
    end

    CleanupScanFilesJob.perform_in(60, scan_id)

  rescue StandardError => e
    scan&.update(status: :failed)
    Rails.logger.error("AnalyzeScanJob failed for scan #{scan_id}: #{e.message}")
    raise
  end
end
