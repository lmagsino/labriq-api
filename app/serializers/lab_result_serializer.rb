class LabResultSerializer
  include JSONAPI::Serializer

  attributes :name, :value, :unit, :status, :reference_range, :explanation, :sort_order
end
