require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:scan) }
    it { is_expected.to belong_to(:lab_result).optional }
  end

  describe "validations" do
    subject { build(:feedback) }

    it { is_expected.to validate_presence_of(:feedback_type) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:feedback_type)
        .with_values(
          incorrect_value: "incorrect_value",
          wrong_interpretation: "wrong_interpretation",
          missing_value: "missing_value",
          general: "general"
        )
        .backed_by_column_of_type(:string)
    end
  end
end
