class AddClientIdToCoupons < ActiveRecord::Migration[6.1]
  def change
    add_reference :coupons, :client, null: true, index: true, foreign_key: true
    add_reference :coupons, :company_client, null: true, index: true, foreign_key: true
  end
end
