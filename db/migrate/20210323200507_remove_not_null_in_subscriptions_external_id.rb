class RemoveNotNullInSubscriptionsExternalId < ActiveRecord::Migration[6.1]
  def change
    change_column_null :subscriptions, :external_id, true
  end
end
