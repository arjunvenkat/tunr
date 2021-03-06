# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.destroy_all

u1 = User.new
u1.username = "arjun_o_0"
u1.fname = "Arjun"
u1.lname = "Venkataswamy"
u1.email = "a@a.com"
u1.image_url = Faker::Avatar.image(u1.username)
u1.desc = "he's just a guy"
u1.password = "12341234"
u1.password_confirmation = "12341234"
u1.save

u2 = User.new
u2.username = "kwyjibo312"
u2.fname = "Prashanth"
u2.lname = "Venkataramanujam"
u2.email = "p@p.com"
u2.image_url = Faker::Avatar.image(u2.username)
u2.desc = "Comedian. Writer. Polymath"
u2.password = "12341234"
u2.password_confirmation = "12341234"
u2.save


50.times do
  u = User.new
  u.fname = Faker::Name.first_name
  u.lname = Faker::Name.last_name
  u.username = Faker::Internet.user_name
  u.email = Faker::Internet.safe_email(u.username)
  u.image_url = Faker::Avatar.image(u.username)
  u.desc = Faker::Company.catch_phrase
  u.password = "12341234"
  u.password_confirmation = "12341234"
  u.save
end

puts "#{User.count} users in the database"


Podcast.destroy_all

p1 = Podcast.new
p1.name = "99% Invisible"
p1.desc = "99% Invisible is a tiny radio show about design, architecture & the 99% invisible activity that shapes our world."
p1.image_url = "http://upload.wikimedia.org/wikipedia/en/7/71/99%25_Invisible.jpg"
p1.save

p2 = Podcast.new
p2.name = "The Joe Rogan Experience"
p2.desc = "The Joe Rogan Experience podcast is a long form conversation hosted by comedian, UFC color commentator, and actor Joe Rogan with friends and guests that have included comedians, actors, musicians, MMA instructors and commentators, authors, artists, and porn stars. The Joe Rogan Experience was voted the Best Comedy Podcast of 2012 on iTunes. In addition online listening, fans can watch a videocast of the show live on Ustream or tune in on Sirius XM’s “The Virus” channel on Saturdays at Noon ET and Sundays at 5:00 AM and 6:00 PM ET."
p2.image_url = "https://yt3.ggpht.com/-Y4tjkwsR774/AAAAAAAAAAI/AAAAAAAAAAA/1kTUglFGXoU/s900-c-k-no/photo.jpg"
p2.save

p3 = Podcast.new
p3.name = "This American Life"
p3.desc = "This American Life is a weekly public radio show broadcast on more than 500 stations to about 2.2 million listeners. There's a theme to each episode of This American Life, and a variety of stories on that theme. It's mostly true stories of everyday people, though not always. There's lots more to the show, but it's sort of hard to describe. Probably the best way to understand the show is to start at our favorites page, though we do have longer guides to our radio show and our TV show. If you want to dive into the hundreds of episodes we've done over the years, there's an archive of all our old radio shows and listings for all our TV episodes, too."
p3.image_url = "http://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/This_American_Life_logo.svg/252px-This_American_Life_logo.svg.png"
p3.save

puts "#{Podcast.count} podcasts in the database"
