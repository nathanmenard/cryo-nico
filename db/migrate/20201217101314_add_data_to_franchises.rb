class AddDataToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :address, :text
    add_column :franchises, :zip_code, :string
    add_column :franchises, :city, :string
    add_column :franchises, :siret, :string
    add_column :franchises, :tax_id, :string
  end
end
