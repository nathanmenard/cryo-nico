class Subscription < ApplicationRecord
  attr_accessor :product_id, :session_count, :total

  belongs_to :subscription_plan
  belongs_to :client

  validates :status, presence: true

  scope :active, -> { where(status: 'active') }

  def active?
    status == 'active'
  end

  def cancel
    return if status == 'canceled'
    update!(status: 'canceled')
  end
end
