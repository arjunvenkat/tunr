class ChangeEpisodeNumToInteger < ActiveRecord::Migration
  def change
    change_column :episodes, :episode_num, :integer
  end
end
