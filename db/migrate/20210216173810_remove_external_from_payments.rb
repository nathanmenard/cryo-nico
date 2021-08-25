class RemoveExternalFromPayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :payments, :external
  end
end
