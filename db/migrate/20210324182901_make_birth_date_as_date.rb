class MakeBirthDateAsDate < ActiveRecord::Migration[6.1]
  def change
    remove_column :clients, :birth_date
    add_column :clients, :birth_date, :date
    remove_column :company_clients, :birth_date
    add_column :company_clients, :birth_date, :date
  end
end
