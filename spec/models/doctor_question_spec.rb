require 'rails_helper'

RSpec.describe DoctorQuestion, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:scan) }
  end

  describe "validations" do
    subject { build(:doctor_question) }

    it { is_expected.to validate_presence_of(:question) }
  end

  describe "scopes" do
    let!(:second_q) { create(:doctor_question, sort_order: 1) }
    let!(:first_q)  { create(:doctor_question, sort_order: 0) }

    it ".ordered returns questions by sort_order" do
      expect(DoctorQuestion.ordered.first).to eq(first_q)
    end
  end
end
