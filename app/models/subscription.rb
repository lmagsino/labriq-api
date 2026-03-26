class Subscription < ApplicationRecord
  belongs_to :user

  enum :plan, { pro: "pro", clinic: "clinic" }
  enum :status, {
    active: "active",
    canceled: "canceled",
    past_due: "past_due",
    trialing: "trialing"
  }, prefix: true

  validates :plan, :status, presence: true

  scope :active, -> { where(status: :active).where("expires_at > ?", Time.current) }
end
