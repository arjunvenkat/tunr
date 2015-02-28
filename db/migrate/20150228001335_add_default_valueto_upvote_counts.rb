class AddDefaultValuetoUpvoteCounts < ActiveRecord::Migration
  def change
    change_column :users, :upvoted_count, :integer, :default => 0
    change_column :reviews, :upvoted_count, :integer, :default => 0
  end
end
