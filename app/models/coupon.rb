class Coupon < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :company_client, optional: true

  has_and_belongs_to_many :franchises
#  has_many :products
  has_many :payments

  validates :name, presence: true
  validates :value, presence: true, numericality: true
  validates :code, presence: true
  validates :franchise_ids, length: { minimum: 1 }

  validate :ensure_unique_code_per_franchise

  validates :percentage, inclusion: { in: [true, false] }
  validates :new_client, inclusion: { in: [true, false] }
  validates :usage_limit, numericality: true, allow_blank: true
  validates :usage_limit_per_person, numericality: true, allow_blank: true

  before_save :downcase_code
  before_save :format_objectives
  before_save :format_product_ids

  scope :global, -> { where(franchise_id: nil) }
  scope :active, -> { where(end_date: nil).or(where('end_date >= ?', Date.today)) }
  scope :expired, -> { where('end_date < ?', Date.today).order(end_date: :desc) }

  def ensure_unique_code_per_franchise
    franchises.each do |franchise|
      return errors.add(:code) if franchise.coupons.where(code: self.code&.downcase, loyalty: false).count > 1
    end
  end

  def code=(value)
    super(value&.downcase)
  end

  def global?
    franchise_id.nil?
  end

  def active?
    return true if end_date.nil?
    return true if end_date >= Date.today
    false
  end

  def objectives_french
    data = []
    objectives.each do |objective|
      objective_in_french = case objective
                            when 'sport'
                              'Sport'
                            when 'health'
                              'Santé'
                            when 'well-being'
                              'Bien-être'
                            when 'look'
                              'Esthétique'
                            end
      data << objective_in_french
    end
    data
  end

  def product_names
    names = []
    product_ids.reject(&:blank?).each do |product_id|
      names << Product.find(product_id).name
    end
    names
  end

  def applicable?(reservation)
    return false if start_date && start_date > Date.today
    return false if end_date && end_date < Date.today
    if usage_limit
      return false if payments.size >= usage_limit
    end
    if usage_limit_per_person
      return false if payments.where(client: reservation.client).size >= usage_limit_per_person
    end
    return false if male.in?([true, false]) && male != reservation.client.male
    if objectives
      any = objectives.any? { |objective| reservation.client.objectives.include?(objective) }
      return false if any == false
    end
    if product_ids
      return false if product_ids.include?(reservation.product_price.product.id.to_s) == false
    end
    if new_client == true
      return false if reservation.client.reservations.count > 1
    end
    true
  end

  def discount_amount(payment)
    if percentage
      return (payment.amount/100) * value / 100
    end
    value
  end

  private

  def downcase_code
    self.code = self[:code].downcase
  end

  def format_objectives
    return if objectives.nil?
    self.objectives = self.objectives.reject { |objective| objective.empty? }
  end

  def format_product_ids
    return if product_ids.nil?
    self.product_ids = self.product_ids.reject { |objective| objective.empty? }
  end
end
