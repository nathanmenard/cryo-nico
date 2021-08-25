class AddCompanyClientToCredits < ActiveRecord::Migration[6.0]
  def change
    add_reference :credits, :company_client, null: true, index: true, foreign_key: true
  end
end
