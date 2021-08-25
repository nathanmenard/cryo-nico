class User < ApplicationRecord
  has_secure_password :password, validations: false

  belongs_to :franchise

  has_many :clients
  has_many :comments, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, format: { with: /[a-z0-9\-_.]+@[a-z0-9_-]+\.[a-z0-9_\-]+/i }

  def private_key
    Base64.urlsafe_encode64("#{id}-#{first_name}-#{last_name}")
  end

  def full_name
    "#{first_name.capitalize} #{last_name.upcase}"
  end
end
