class AddGlobalToBlockers < ActiveRecord::Migration[6.1]
  def change
    add_column :blockers, :global, :boolean, default: false
  end
end
