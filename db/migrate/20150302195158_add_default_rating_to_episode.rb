class AddDefaultRatingToEpisode < ActiveRecord::Migration
  def change
    change_column :episodes, :rating, :float, :default => 0
  end
end
