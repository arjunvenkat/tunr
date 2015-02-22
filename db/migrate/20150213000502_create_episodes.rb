class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.integer :podcast_id
      t.string :season
      t.integer :episode_num
      t.string :title
      t.text :desc
      t.integer :duration
      t.date :published_date
      t.string :url
      t.boolean :explicit

      t.timestamps null: false
    end
  end
end
