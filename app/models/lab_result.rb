class LabResult < ApplicationRecord
  belongs_to :scan

  enum :status, {
    normal: "normal",
    high: "high",
    low: "low",
    critical: "critical"
  }, prefix: true

  validates :name, :value, :status, presence: true

  scope :abnormal, -> { where.not(status: :normal) }
  scope :normal, -> { where(status: :normal) }
  scope :ordered, -> { order(:sort_order) }
end
