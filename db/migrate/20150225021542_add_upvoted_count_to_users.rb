class AddUpvotedCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :upvoted_count, :integer
  end
end
