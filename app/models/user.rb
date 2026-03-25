class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :scans, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  enum :plan_type, { free: "free", pro: "pro", clinic: "clinic" }

  validates :email, presence: true, uniqueness: true
end
