class DoctorQuestion < ApplicationRecord
  belongs_to :scan
  validates :question, presence: true
  scope :ordered, -> { order(:sort_order) }
end
