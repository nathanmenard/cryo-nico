class AddBankingSecretIdToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :banking_secret_id, :text
  end
end
