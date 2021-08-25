class Company < ApplicationRecord
  belongs_to :franchise
  has_many :company_clients

  validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :address, presence: true
  validates :zip_code, presence: true
  validates :city, presence: true
  validates :siret, presence: true

  validates :email, format: { with: /[a-z0-9\-_.]+@[a-z0-9_-]+\.[a-z0-9_\-]+/i }
  validates :phone, numericality: true, length: { is: 10 }, allow_blank: true
  validates :zip_code, numericality: true, length: { is: 5 }, allow_blank: true
  validates :siret, numericality: true, length: { is: 14 }

  def self.to_csv
    attributes = {
      type: "Professionnel",
      name: 'Nom',
      email: 'Email',
      phone: 'N° de téléphone',
      address: 'Adresse postale',
      zip_code: 'Code postal',
      city: 'Ville',
      siret: 'SIRET',
      created_at: 'Date de création du compte',
    }
    CSV.generate(headers: true) do |csv|
      csv << attributes.values
      all.each do |client|
        csv << ['Professionnel', client.name, client.email, "=\"#{client.phone}\"", client.address, "=\"#{client.zip_code}\"", client.city, "=\"#{client.siret}\"", I18n.l(client.created_at, format: :short)]
      end
    end
  end
end
