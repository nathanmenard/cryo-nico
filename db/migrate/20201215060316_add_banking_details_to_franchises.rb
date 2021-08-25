class AddBankingDetailsToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :banking_provider, :string
    add_column :franchises, :banking_secret_key, :text
  end
end
