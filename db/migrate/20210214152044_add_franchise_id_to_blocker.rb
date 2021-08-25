class AddFranchiseIdToBlocker < ActiveRecord::Migration[6.0]
  def change
    add_reference :blockers, :franchise, null: false, index: true, foreign_key: true
  end
end
