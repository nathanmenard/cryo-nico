class AddToBeCanceledAtToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :to_be_canceled_at, :datetime
  end
end
