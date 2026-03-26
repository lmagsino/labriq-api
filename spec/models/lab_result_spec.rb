require 'rails_helper'

RSpec.describe LabResult, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:scan) }
  end

  describe "validations" do
    subject { build(:lab_result) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(normal: "normal", high: "high", low: "low", critical: "critical").backed_by_column_of_type(:string).with_prefix(:status) }
  end

  describe "scopes" do
    let!(:normal_result)   { create(:lab_result, status: "normal") }
    let!(:high_result)     { create(:lab_result, status: "high") }
    let!(:first_result)    { create(:lab_result, sort_order: 0) }
    let!(:second_result)   { create(:lab_result, sort_order: 1) }

    it ".abnormal excludes normal results" do
      expect(LabResult.abnormal).to include(high_result)
      expect(LabResult.abnormal).not_to include(normal_result)
    end

    it ".normal returns only normal results" do
      expect(LabResult.normal).to include(normal_result)
      expect(LabResult.normal).not_to include(high_result)
    end

    it ".ordered returns results by sort_order" do
      expect(LabResult.ordered.map(&:sort_order)).to eq(LabResult.ordered.map(&:sort_order).sort)
    end
  end
end
