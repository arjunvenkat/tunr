# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.destroy_all

u1 = User.new
u1.email = "a@a.com"
u1.password = "12341234"
u1.password_confirmation = "12341234"
u1.save

puts "#{User.count} users in the database"


Podcast.destroy_all
p1 = Podcast.new
p1.name = "99% Invisible"
p1.desc = "99% Invisible is a tiny radio show about design, architecture & the 99% invisible activity that shapes our world."
p1.image_url = "http://upload.wikimedia.org/wikipedia/en/7/71/99%25_Invisible.jpg"
p1.save




