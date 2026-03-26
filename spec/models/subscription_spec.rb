require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:subscription) }

    it { is_expected.to validate_presence_of(:plan) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:plan).with_values(pro: "pro", clinic: "clinic").backed_by_column_of_type(:string) }
    it { is_expected.to define_enum_for(:status).with_values(active: "active", canceled: "canceled", past_due: "past_due", trialing: "trialing").backed_by_column_of_type(:string).with_prefix(:status) }
  end

  describe "scopes" do
    let!(:active_sub)  { create(:subscription, status: "active", expires_at: 30.days.from_now) }
    let!(:expired_sub) { create(:subscription, status: "active", expires_at: 1.day.ago) }
    let!(:canceled_sub) { create(:subscription, status: "canceled", expires_at: 30.days.from_now) }

    it ".active returns active and unexpired subscriptions" do
      expect(Subscription.active).to include(active_sub)
      expect(Subscription.active).not_to include(expired_sub)
      expect(Subscription.active).not_to include(canceled_sub)
    end
  end
end
