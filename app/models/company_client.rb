class CompanyClient < ApplicationRecord
  attr_accessor :password_2

  belongs_to :company
  belongs_to :company_client, optional: true

  has_many :coupons
  has_many :credits
  has_many :payments
  has_many :reservations
  has_many :reviews

  has_secure_password :password, validations: false

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  validates :email, format: { with: /[a-z0-9\-_.]+@[a-z0-9_-]+\.[a-z0-9_\-]+/i }
  validates :phone, numericality: true, length: { is: 10 }, allow_blank: true

  scope :birthday_today, -> { where('EXTRACT(month FROM birth_date::date) = ? AND EXTRACT(day FROM birth_date::date) = ?', Date.today.month, Date.today.day) }

  def self.find_by_private_key(key)
    all.each do |company_client|
      if company_client.private_key == key
        return company_client
      end
    end
    raise ActiveRecord::RecordNotFound
  end

  def full_name
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def franchise
    company.franchise
  end

  def private_key
    Base64.urlsafe_encode64("#{id}-#{first_name}-#{last_name}")
  end

  def can_make_reservations?
    company_client.present?
  end
end
