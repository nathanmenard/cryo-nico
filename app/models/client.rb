class Client < ApplicationRecord
  attr_accessor :password_2, :redirect_to_reservations, :redirect_to_payments
  
  has_secure_password :password, validations: false

  belongs_to :client, optional: true
  belongs_to :franchise
  belongs_to :user, optional: true

  has_many :comments
  has_many :credits
  has_many :coupons
  has_many :payments
  has_many :reservations
  has_many :reviews
  has_many :subscriptions

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :male, inclusion: { in: [true, false] }

  validates :email, format: { with: /[a-z0-9\-_.]+@[a-z0-9_-]+\.[a-z0-9_\-]+/i }#, allow_blank: true
  validates :phone, numericality: true, length: { is: 10 }, allow_blank: true
  validates :zip_code, numericality: true, length: { is: 5 }, allow_blank: true

  before_save :format_objectives

  scope :male, -> { where(male: true) }
  scope :female, -> { where(male: false) }
  scope :birthday_today, -> { where('EXTRACT(month FROM birth_date::date) = ? AND EXTRACT(day FROM birth_date::date) = ?', Date.today.month, Date.today.day) }

  def self.to_csv
    attributes = {
      type: "Type d'utilisateur",
      first_name: 'Prénom',
      last_name: 'Nom',
      male: 'Genre',
      birth_date: 'Date de naissance',
      objectives: 'Objectifs',
      newsletter: 'Inscription à la newsletter ?',
      email: 'Email',
      phone: 'N° de téléphone',
      address: 'Adresse postale',
      zip_code: 'Code postal',
      city: 'Ville',
      created_at: 'Date de création du compte',
      last_logged_at: 'Date de dernière connexion',
    }
    CSV.generate(headers: true) do |csv|
      csv << attributes.values
      all.each do |client|
        csv << ['Particulier', client.first_name, client.last_name, client.male ? 'Homme' : 'Femme', 
                client.birth_date, client.objectives.any? ? client.objectives_french.join(' / ') : nil,
                client.newsletter ? 'Oui' : 'Non', client.email, "=\"#{client.phone}\"", 
                client.address, "=\"#{client.zip_code}\"", client.city,
                I18n.l(client.created_at, format: :short),
                client.last_logged_at ? I18n.l(client.last_logged_at, format: :short) : nil,
        ]
      end
    end
  end

  def self.subscribers
    subscriber_ids = []
    all.find_each do |client|
      subscriber_ids << client.id if client.subscriber?
    end
    Client.where(id: subscriber_ids)
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

  def self.objective_french(value)
    case value
    when 'sport'
      'Sport'
    when 'health'
      'Santé'
    when 'well-being'
      'Bien-être'
    when 'look'
      'Esthétique'
    end
  end

  def private_key
    Base64.urlsafe_encode64("#{id}-#{first_name}-#{last_name}")
  end

  def full_name
    "#{first_name.capitalize} #{last_name.upcase}"
  end

  def credits_for(product)
    credits.where(product: product).size
  end

  def subscriber?
    subscriptions.any?
  end

  private

  def format_objectives
    return if objectives.empty?
    self.objectives = self.objectives.reject { |objective| objective.empty? }
  end
end
