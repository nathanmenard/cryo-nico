class AddSendinblueApiKeyToFranchises < ActiveRecord::Migration[6.1]
  def change
    add_column :franchises, :sendinblue_api_key, :text
  end
end
