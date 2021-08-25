class Product < ApplicationRecord
  attr_accessor :purge_thumbnail, :purge_disclaimer

  belongs_to :room

  has_many :credits
  has_many :product_prices, dependent: :destroy
  has_many :reservations, through: :product_prices
  has_many :reviews
  has_many :subscription_plans
  has_many :surveys

  has_one_attached  :thumbnail
  has_one_attached :disclaimer
  has_many_attached :images

  validates :name, presence: true
  validates :description, presence: true
  validates :duration, presence: true
  validates :active, inclusion: { in: [true, false] }

  def self.find_by_slug(slug)
    all.each do |product|
      if product.slug == slug
        return product
      end
    end
    raise ActiveRecord::RecordNotFound
  end

  def self.has_unit_price
    ids = []
    all.each do |product|
      ids << product.id if product.product_prices.where(professionnal: false, session_count: 1).any?
    end
    Product.where(id: ids)
  end

  def self.active
    ids = []
    all.each do |product|
      ids << product.id if product.active? && product.product_prices.size > 0
    end
    Product.where(id: ids)
  end

  def self.to_csv
    attributes = {
      name: 'Prestation',
      male: 'Hommes',
      female: 'Femmes',
      client: 'Client Particuliers',
      company_client: 'Clients Salariés Entreprise',
      subscriber: 'Abonnés',
      non_subscriber: 'Non-Abonnés',
    }
    first_product = Product.first
    first_product.group_by_hour.keys.each { |time| attributes[time] = time }
    CSV.generate(headers: true) do |csv|
      csv << attributes.values
      all.each do |product|
        hours = product.group_by_hour.values.map { |x| "#{x}%" }
        csv << [product.name, "#{product.male_vs_female[:male]}%", "#{product.male_vs_female[:female]}%", "#{product.client_vs_company_client[:client]}%", "#{product.client_vs_company_client[:company_client]}%", "#{product.subscriber_vs_non_subscriber[:subscriber]}%", "#{product.subscriber_vs_non_subscriber[:non_subscriber]}%", *hours]
      end
    end
  end

  def slug
    name.parameterize
  end

  def name_with_franchise
    "[#{room.franchise.name}] #{name}"
  end

  def payments
    Payment.where('id IN (?)', reservations.pluck(:payment_id))
  end

  def unique_clients_count
    clients_count = reservations.paid.pluck(:client_id).compact.uniq.length
    company_clients_count = reservations.paid.pluck(:company_client_id).compact.uniq.length
    clients_count + company_clients_count
  end

  def average_payments_amount
    sum = payments.successful.sum(:amount) / 100
    count = payments.successful.count
    sum / count rescue 0
  end

  # TODO: include company clients
  def average_session_count_per_client
    sums = []
    client_ids = reservations.paid.pluck(:client_id).compact.uniq
    client_ids.each do |client_id|
      sum = 0
      client = Client.find(client_id)
      sum += client.reservations.scheduled.paid.count
      sums << sum
    end
    (sums.sum / client_ids.count).to_i rescue 0
  end

  def opening_slots
    hours = []
    for i in 8..20
      hour = i < 10 ? "0#{i}": i
      if duration == 30
        hours << "#{hour}:00"
        hours << "#{hour}:30" if i < 20
      else
        hours << "#{hour}:00"
      end
    end
    hours
  end

  def ever_bought_by?(person)
    person.payments.successful.where(product_name: name).any?
  end

  def male_vs_female
    all_count = reservations.count.to_f
    male_count = reservations.joins(:client).where('clients.male = ?', true).count.to_f
    female_count = reservations.joins(:client).where('clients.male = ?', false).count.to_f
    {
      male: male_count.zero? ? 0 : (male_count / all_count * 100).ceil,
      female: female_count.zero? ? 0 : (female_count / all_count * 100).ceil,
    }
  end

  def client_vs_company_client
    all_count = reservations.count.to_f
    client_count = reservations.where('company_client_id IS NULL').where('client_id IS NOT NULL').count.to_f
    company_client_count = reservations.where('client_id IS NULL').where('company_client_id IS NOT NULL').count.to_f
    {
      client: client_count.zero? ? 0 : (client_count / all_count * 100).ceil,
      company_client: company_client_count.zero? ? 0 : (company_client_count / all_count * 100).ceil,
    }
  end

  def subscriber_vs_non_subscriber
    all_count = reservations.count.to_f
    subscriber_ids = room.franchise.clients.subscribers.pluck(:id)
    subscriber_count = reservations.where(client_id: subscriber_ids).count.to_f
    non_subscriber_count = all_count - subscriber_count
    {
      subscriber: subscriber_count.zero? ? 0 : (subscriber_count / all_count * 100).ceil,
      non_subscriber: non_subscriber_count.zero? ? 0 : (non_subscriber_count / all_count * 100).ceil,
    }
  end
  
  def group_by_hour
    all_count = reservations.count.to_f
    times = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00']
    data = {}
    times.each do |time|
      hour = time.split(':')[0]
      minutes = time.split(':')[1]
      count = reservations.where("date_part('hour', start_time) = ?", hour).where("date_part('minute', start_time) = ?", minutes).count.to_f
      data[time] = count.zero? ? 0 : (count / all_count * 100).ceil
    end
    data
  end
end
