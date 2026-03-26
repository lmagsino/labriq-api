class Feedback < ApplicationRecord
  belongs_to :scan
  belongs_to :lab_result, optional: true

  enum :feedback_type, {
    incorrect_value: "incorrect_value",
    wrong_interpretation: "wrong_interpretation",
    missing_value: "missing_value",
    general: "general"
  }

  validates :feedback_type, presence: true
end
