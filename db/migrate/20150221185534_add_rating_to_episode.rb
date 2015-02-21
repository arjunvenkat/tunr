class AddRatingToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :rating, :float
  end
end
