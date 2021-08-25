class AddBlockerIdToBlockers < ActiveRecord::Migration[6.1]
  def change
    add_reference :blockers, :blocker, null: true, index: true, foreign_key: true
  end
end
