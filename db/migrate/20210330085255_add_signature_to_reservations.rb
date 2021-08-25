class AddSignatureToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :signature, :text
    remove_column :products, :disclaimer
  end
end
