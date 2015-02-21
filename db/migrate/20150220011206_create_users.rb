class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :fname
      t.string :lname
      t.string :sex
      t.text :desc
      t.string :image_url
      t.string :age_range

      t.timestamps null: false
    end
  end
end
