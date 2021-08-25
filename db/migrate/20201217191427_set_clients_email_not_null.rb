class SetClientsEmailNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :clients, :email, false
  end
end
