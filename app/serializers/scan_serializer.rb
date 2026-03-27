class ScanSerializer
  include JSONAPI::Serializer

  attributes :id, :status, :file_count, :urgency, :summary,
             :prescription_context, :analyzed_at, :created_at

  has_many :lab_results, serializer: LabResultSerializer
  has_many :doctor_questions, serializer: DoctorQuestionSerializer

  attribute :urgency_note do |scan|
    scan.raw_ai_response&.dig("urgency_note")
  end

  attribute :lifestyle_tips do |scan|
    scan.raw_ai_response&.dig("lifestyle_tips") || []
  end
end
