class Reservation < ApplicationRecord
  attr_accessor :transaction_id, :amount, :product_id, :perform_refund

  belongs_to :client, optional: true
  belongs_to :company_client, optional: true
  belongs_to :product_price
  belongs_to :payment, optional: true
  belongs_to :user, optional: true

  has_one_attached :invoice

  validate :belongs_to_client_or_company_client
  validates :email_notification, inclusion: { in: [true, false ] }
  validates :first_time, inclusion: { in: [true, false ] }, allow_nil: true
  validates :to_be_paid_online, inclusion: { in: [true, false ] }, allow_nil: false

  before_save :check_room_availability
  # before_save :check_coupon
  before_save :round_minutes
  before_create :generate_first_time
  after_create :generate_invoice

  scope :scheduled, -> { where.not(start_time: nil).where(canceled: false) }
  scope :finished_yesterday, -> { where('DATE(start_time) = ?', Date.yesterday) }
  scope :today, -> { where(start_time: Date.today.all_day) }

  def self.to_csv
    attributes = {
      paid: "Statut",
      created_at: 'Date',
      transaction_id: 'N° de facture',
      amount: 'Montant',
      client_id: 'Client',
      invoice: 'Lien PDF',
    }
    CSV.generate(headers: true) do |csv|
      csv << attributes.values
      all.each do |reservation|
        csv << [(reservation.paid? ? 'Payée' : 'Impayée'), I18n.l(reservation.created_at, format: :short), reservation.transaction_id,
                ActiveSupport::NumberHelper.number_to_currency(reservation.amount / 100), reservation.client.full_name, Rails.application.routes.url_helpers.rails_blob_url(reservation.invoice)]
      end
    end
  end

  def self.find_by_private_key(key)
    all.each do |reservation|
      if reservation.private_key == key
        return reservation
      end
    end
    raise ActiveRecord::RecordNotFound
  end

  def self.paid
    ids = []
    all.includes(:payment).each do |reservation|
      ids << reservation.id if reservation.paid?
    end
    all.where(id: ids)
  end

  def self.by_time(time)
    data = []
    all.each do |reservation|
      hour = reservation.start_time.hour.to_i
      minutes = reservation.start_time.strftime('%M').to_i
      hour_2, minutes_2 = time.split(':').map(&:to_i)
      if (hour == hour_2) && (minutes == minutes_2)
        data << reservation
      end
    end
    data
  end

  def paid?
    (payment.present? && payment.successful?) || paid_by_credit?
  end

  def generate_amount
    amount = product_price.total * 100
    #if self.coupon
    #  amount = amount - (coupon.discount_amount(self) * 100)
    #end
    amount
  end

  def slots_for(date_string)
    hours = []
    for i in 8..20
      hour = i < 10 ? "0#{i}": i
      hours << "#{hour}:00"
      hours << "#{hour}:30" if i < 20
    end

    date = date_string.to_time

    reservations = Reservation.where(product_price: product_price, start_time: date.beginning_of_day..date.end_of_day)
    reservations.each do |reservation|
      hours = hours - ["#{reservation.start_time.strftime('%H')}:#{reservation.start_time.strftime('%M')}"]
    end
    franchise = client.present? ? client.franchise : company_client.franchise
    blockers = Blocker.where(franchise: franchise, start_time: date.beginning_of_day..date.end_of_day, blocking: true)
    blockers.each do |blocker|
      found = hours.find { |x| x == "#{blocker.start_time.strftime('%H')}:#{blocker.start_time.strftime('%M')}" }
      found_index = hours.index(found)
      next_hours_to_delete = (blocker.duration / 30) - 1
      elements_to_delete = []
      for i in 1..(next_hours_to_delete)
        element = hours[found_index+i]
        elements_to_delete << element
      end
      elements_to_delete.each do |element|
        hours = hours - [element]
      end
      hours = hours - [found]
    end

    if product_price.product.duration == 60
      hours = hours.select { |x| !x.include?('30') } 
    end
    hours
  end

  def private_key
    Base64.urlsafe_encode64("#{id}-#{created_at}")
  end

  def refund(type = nil)
    return if refunded?

    if type == 'credit'
      client.credits.create!(product: product_price.product)
    elsif type == 'money'
      refund_with_money
    else
      if paid_by_credit
        client.credits.create!(product: product_price.product)
      else
        refund_with_money
      end
    end
    update!(refunded: true)
  end

  private

  def belongs_to_client_or_company_client
    errors.add(:base, :invalid) if client.nil? && company_client.nil?
  end

  def check_room_availability
    if (new_record? && start_time.present?) || start_time_changed?
      reservations = product_price.product.reservations.where(start_time: start_time)
      maximum_capacity = user.present? ? product_price.product.room.capacity + 1 : product_price.product.room.capacity
      if reservations.count >= maximum_capacity
        raise ActiveRecord::RecordInvalid
      end
    end
  end

  def check_coupon
    return if coupon.nil?
    if !coupon.applicable?(self)
      errors.add(:coupon, :invalid)
    end
  end

  def generate_first_time
    person = client ? client : company_client
    product_prices = product_price.product.product_prices
    if person.reservations.scheduled.where(product_price: product_prices).any?
      self.first_time = false
    else
      self.first_time = true
    end
  end

  def generate_invoice
    #invoice_file = open("http://www.africau.edu/images/default/sample.pdf")
    invoice.attach io: File.open(Rails.root.join("public", "sample.pdf")), filename: "facture-#{id}.pdf"
  end

  def refund_with_money
    one_session_price = product_price.product.product_prices.find_by(
      session_count: 1,
      professionnal: false
    )
    Payment.create!(
      client: client,
      amount: -one_session_price.total*100,
      product_name: product_price.product.name,
      as_paid: true
    )
  end

  def round_minutes
    return if start_time.blank?
    if new_record? || start_time_changed?
      time = start_time.to_time.to_s
      minutes = time.split(':')[1].to_i
      if minutes <= 15
        new_start_time = start_time.beginning_of_hour
      end
      if minutes > 15
        new_start_time = start_time.beginning_of_hour + 30.minutes
      end
      if minutes > 30
        new_start_time = start_time.beginning_of_hour + 30.minutes
      end
      if minutes >= 45
        new_start_time = (start_time + 1.hour).beginning_of_hour
      end
      self.start_time = new_start_time
    end
  end
end
