class RemoveClientNotNullInCredits < ActiveRecord::Migration[6.0]
  def change
    change_column_null :credits, :client_id, true
  end
end
