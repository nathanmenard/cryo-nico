class Room < ApplicationRecord
  belongs_to :franchise

  has_many :blockers, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :reservations, through: :products

  validates :name, presence: true
  validates :capacity, presence: true, numericality: true

  def self.has_active_products
    data = []
    all.each do |room|
      data << room if room.products.has_unit_price.active.any?
    end
    data
  end

  def name_with_franchise
    "[#{franchise.name}] #{name}"
  end
end
