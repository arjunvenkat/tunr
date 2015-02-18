class CreatePodcasts < ActiveRecord::Migration
  def change
    create_table :podcasts do |t|
      t.string :name
      t.string :published_by
      t.text :desc
      t.string :update_freq
      t.string :update_day
      t.string :image_url
      t.string :host
      t.string :created_by

      t.timestamps null: false
    end
  end
end
