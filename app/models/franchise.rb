class Franchise < ApplicationRecord
  has_many :blockers
  has_many :business_hours
  has_many :campaign_templates
  has_many :clients
  has_many :companies
  has_many :external_products
  has_many :rooms
  has_many :products, through: :rooms
  has_many :product_prices, through: :products
  has_many :company_clients, through: :companies
  has_many :reviews, through: :products
  has_many :comments, through: :clients
  has_many :campaigns
  has_many :payments, through: :clients
  has_and_belongs_to_many :coupons
  has_many :subscription_plans, through: :products
  has_many :subscriptions, through: :clients
  has_many :users

  accepts_nested_attributes_for :business_hours

  validates :name, presence: true, uniqueness: true
  validates :email, format: { with: /[a-z0-9\-_.]+@[a-z0-9_-]+\.[a-z0-9_\-]+/i }, allow_blank: true
  validates :zip_code, numericality: true, length: { is: 5 }, allow_blank: true
  validates :siret, numericality: true, length: { is: 14 }, allow_blank: true
  validates :phone, numericality: true, length: { is: 10 }, allow_blank: true

  after_create :create_business_hours

  def slug
    name.parameterize
  end

  def reservations
    product_price_ids = product_prices.pluck(:id)
    Reservation.where('product_price_id IN (?)', product_price_ids)
  end

  def surveys
    product_ids = products.pluck(:id)
    Survey.where('product_id IN (?)', product_ids)
  end

  def average_session_count_per_product(product)
    sum = 0
    product.reservations.each do |reservation|
      sum += reservation.product_price.session_count
    end
    sum / clients_count_per_product
  end

  private

  def create_business_hours
    ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].each do |day|
      business_hours.create!(
        day: day,
        morning_start_time: '09:00',
        morning_end_time: '12:00',
        afternoon_start_time: '14:00',
        afternoon_end_time: '20:00',
      )
    end
  end
end
