class AddBlockingToBlockers < ActiveRecord::Migration[6.1]
  def change
    add_column :blockers, :blocking, :boolean, default: true
  end
end
