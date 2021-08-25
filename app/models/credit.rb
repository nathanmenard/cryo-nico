class Credit < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :company_client, optional: true
  belongs_to :product
end
