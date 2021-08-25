class AddHomepageToReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :homepage, :boolean
  end
end
