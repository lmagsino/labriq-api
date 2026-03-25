class Scan < ApplicationRecord
  belongs_to :user, optional: true # anonymous scans allowed
  has_many :lab_results, dependent: :destroy
  has_many :doctor_questions, dependent: :destroy
  has_many_attached :lab_files
  has_many_attached :prescription_files

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  enum :urgency, {
    normal: "normal",
    attention: "attention",
    urgent: "urgent"
  }, prefix: true

  validates :status, presence: true
  validates :file_count, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: :completed) }
end
