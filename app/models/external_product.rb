class ExternalProduct < ApplicationRecord
  belongs_to :franchise

  validates :name,     presence: true
  validates :tax_rate, presence: true, numericality: true

  def name_with_price
    "#{name} (#{ActiveSupport::NumberHelper.number_to_currency(amount)})"
  end

  def payments
    Payment.all.where(product_name: name)
  end

  def unique_clients_count
    clients_count = payments.successful.pluck(:client_id).compact.uniq.length
    company_clients_count = payments.successful.pluck(:company_client_id).compact.uniq.length
    clients_count + company_clients_count
  end

  def revenue_without_tax
    sum = payments.successful.sum(:amount) / 100
    sum * (1-tax_rate/100)
  end
end
