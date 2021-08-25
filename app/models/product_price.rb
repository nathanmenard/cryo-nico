class ProductPrice < ApplicationRecord
  belongs_to :product
  has_many :reservations, dependent: :destroy

  validates :session_count, presence: true, numericality: true
  validates :total, presence: true, numericality: true
  validates :professionnal, inclusion: { in: [true, false ] }

  def unit_price
    total / session_count
  end

  def product_name_with_session_count
    "#{product.name} (#{session_count_formatted})"
  end

  private

  def session_count_formatted
    "#{session_count} séance#{session_count > 1 ? 's' : ''}"
  end
end
