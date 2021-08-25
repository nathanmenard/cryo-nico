class RenameExternalProductsTaxToTaxRate < ActiveRecord::Migration[6.0]
  def change
    rename_column :external_products, :tax, :tax_rate
  end
end
