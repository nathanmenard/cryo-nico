class SubscriptionPlan < ApplicationRecord
  belongs_to :product

  has_many :subscriptions

  validates :session_count, presence: true, numericality: true
  validates :total, presence: true, numericality: true
end
