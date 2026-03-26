class PromptTemplate < ApplicationRecord
  validates :name, :version, :content, :model_name, presence: true

  scope :active, -> { where(active: true) }

  def self.current(name = "lab_analysis")
    active.where(name: name).order(version: :desc).first
  end
end
