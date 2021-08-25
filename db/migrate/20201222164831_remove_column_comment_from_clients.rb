class RemoveColumnCommentFromClients < ActiveRecord::Migration[6.0]
  def change
    remove_column :clients, :comment, :text
  end
end
