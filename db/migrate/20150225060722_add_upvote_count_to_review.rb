class AddUpvoteCountToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :upvoted_count, :integer
  end
end
