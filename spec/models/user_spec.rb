require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:scans).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:plan_type).with_values(free: "free", pro: "pro", clinic: "clinic").backed_by_column_of_type(:string) }
  end

  describe "defaults" do
    it "defaults plan_type to free" do
      user = build(:user)
      expect(user.plan_type).to eq("free")
    end
  end
end
