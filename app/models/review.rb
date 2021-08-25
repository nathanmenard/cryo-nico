class Review < ApplicationRecord
  belongs_to :product
  belongs_to :client, optional: true
  belongs_to :company_client, optional: true


  validate :belongs_to_client_or_company_client
  validates :body, presence: true

  scope :published, -> { where(published: true) }

  private

  def belongs_to_client_or_company_client
    errors.add(:base, :invalid) if client.nil? && company_client.nil?
  end
end
