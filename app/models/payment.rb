class Payment < ApplicationRecord
  # for manual payments created by admin
  attr_accessor :external_product_id, :product_id, :session_count, :session_price, :new_client

  belongs_to :client, optional: true
  belongs_to :company_client, optional: true
  belongs_to :coupon, optional: true
  has_many :reservations, dependent: :destroy

  validates :amount, presence: true, numericality: true
  validates :mode, inclusion: ['online', 'pos', 'check', 'cash'], allow_nil: true
  validates :product_name, presence: true
  validates :transaction_id, uniqueness: true, numericality: true, length: { is: 6 }

  validate :belongs_to_client_or_company_client

  before_validation   :generate_random_transaction_id
  before_save         :update_amount_after_coupon_update
  before_create       :drop_transaction_id_if_not_online
  after_create        :generate_coupon

  scope :today, -> { where('date(payments.created_at) = ?', Date.today) }

  def self.to_csv
    attributes = {
      numero: 'Numéro de ticket',
      date: 'Date de création',
      client: 'Client',
      ht: 'Total HT',
      tax: 'Total TVA',
      ttc: 'Total TTC',
      prestation: 'Prestation',
    }
    CSV.generate(headers: true) do |csv|
      csv << attributes.values
      all.each do |payment|
        csv << [
          payment.date_id,
          I18n.l(payment.created_at, format: :long),
          payment.client.present? ? payment.client.full_name : payment.company_client.company.name,
          ActiveSupport::NumberHelper.number_to_currency((payment.amount_without_tax)/100),
          ActiveSupport::NumberHelper.number_to_currency(payment.tax_amount/100),
          ActiveSupport::NumberHelper.number_to_currency(payment.amount/100),
          payment.product_name,
        ]
      end
    end
  end

  def self.find_by_date_id(date_id)
    all.each do |payment|
      if payment.date_id == date_id
        return payment
      end
    end
    nil
  end

  def self.successful
    ids = []
    all.each do |payment|
      ids << payment.id if payment.successful?
    end
    all.where(id: ids)
  end

  def self.by_product(product_name)
    where(product_name: product_name)
  end

  def tax_amount
    amount * tax_rate / 100
  end

  def amount_without_tax
    amount - tax_amount
  end

  def successful?
    bank_name.present? || (mode != 'online' && as_paid?)
  end

  def date_id
    year = created_at.year
    month = created_at.month.to_s.rjust(2, '0')
    day = created_at.day.to_s.rjust(2, '0')
    hour, minutes = created_at.to_s(:time).split(':')
    [year, month, day, hour, minutes, id].join()
  end

  def mode_in_french
    case mode
    when 'cash'
      'Espèces'
    when 'check'
      'Chèque'
    when 'online'
      'CB en ligne'
    end
  end

  private

  def belongs_to_client_or_company_client
    errors.add(:base, 'has to belong to client or company client') if client.nil? && company_client.nil?
  end

  def generate_random_transaction_id
    if self.transaction_id.nil?
      self.transaction_id = (1..9).to_a.sample(6).join
    end
  end

  def update_amount_after_coupon_update
    return unless coupon_id_changed?
    if coupon
      self.amount = self.amount - (coupon.discount_amount(self) * 100)
    else
      reservation = client.reservations.where(payment: self).last
      self.amount = reservation.generate_amount
    end
  end

  def drop_transaction_id_if_not_online
    if self.mode != 'online'
      self.transaction_id = nil
    end
  end

  def generate_coupon
    person = client ? client : company_client
    return if person.is_a?(Client) && person.subscriber?
    last_loyalty_coupon = person.coupons.where(loyalty: true).last
    if last_loyalty_coupon
      sum = person.payments.where('created_at > ?', last_loyalty_coupon.created_at).sum(:amount)
    else
      sum = person.payments.sum(:amount)
    end
    if sum >= 550*100
      coupon = person.coupons.create!(
        franchises: [person.franchise],
        name: "20€ offerts après 550€ dépensés",
        value: 20,
        percentage: false,
        code: 'FIDELITE20',
        loyalty: true,
        usage_limit: 1,
        usage_limit_per_person: 1,
        start_date: Date.today,
        end_date: Date.today + 30.days
      )
      CouponMailer.loyalty(coupon).deliver_later
    end
  end
end
