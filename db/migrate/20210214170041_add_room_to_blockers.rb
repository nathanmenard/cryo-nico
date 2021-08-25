class AddRoomToBlockers < ActiveRecord::Migration[6.0]
  def change
    add_reference :blockers, :room, null: false, index: true, foreign_key: true
  end
end
