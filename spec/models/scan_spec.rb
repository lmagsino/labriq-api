require 'rails_helper'

RSpec.describe Scan, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:lab_results).dependent(:destroy) }
    it { is_expected.to have_many(:doctor_questions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:scan) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:file_count).is_greater_than(0) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: "pending", processing: "processing", completed: "completed", failed: "failed").backed_by_column_of_type(:string) }
    it { is_expected.to define_enum_for(:urgency).with_values(normal: "normal", attention: "attention", urgent: "urgent").backed_by_column_of_type(:string).with_prefix(:urgency) }
  end

  describe "scopes" do
    let!(:old_scan)       { create(:scan, created_at: 2.days.ago) }
    let!(:new_scan)       { create(:scan, created_at: 1.minute.ago) }
    let!(:completed_scan) { create(:scan, status: "completed", created_at: 3.days.ago) }

    it ".recent returns scans newest first" do
      expect(Scan.recent.first).to eq(new_scan)
    end

    it ".completed returns only completed scans" do
      expect(Scan.completed).to include(completed_scan)
      expect(Scan.completed).not_to include(old_scan)
    end
  end
end
