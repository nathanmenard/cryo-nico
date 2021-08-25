class AddFacebookChatSnippetToFranchises < ActiveRecord::Migration[6.0]
  def change
    add_column :franchises, :facebook_chat_snippet, :text
  end
end
