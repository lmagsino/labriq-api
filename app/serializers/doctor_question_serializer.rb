class DoctorQuestionSerializer
  include JSONAPI::Serializer

  attributes :question, :sort_order
end
