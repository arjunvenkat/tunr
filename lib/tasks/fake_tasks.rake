namespace :fake do
  desc "create fake review data"
  task :reviews => :environment do

    50.times do
      500.times do |count|
        user = User.offset(rand(User.count)).first
        podcast = Podcast.offset(rand(Podcast.count)).first
        episode = podcast.episodes.offset(rand(podcast.episodes.count)).first
        review = Review.new
        review.user_id = user.id
        review.episode_id = episode.id
        review.rating = rand(1..5)
        review.contents = Faker::Lorem.paragraph(5)
        review.save
        puts "#{count}: review created for #{podcast.name} - #{episode.episode_num}"
      end
      puts "500 fake reviews created"
    end

  end

  desc "create fake upvote data"
  task :upvotes => :environment do
    50.times do
      100.times do
        user = User.offset(rand(User.count)).first
        review = Review.offset(rand(Review.count)).first
        upvote = Upvote.new
        upvote.user_id = user.id
        upvote.review_id = review.id
        upvote.save
      end
      puts "100 fake upvotes created"
    end


  end

  desc "create fake follows"
  task :follows => :environment do
    400.times do
      user1 = User.offset(rand(User.count)).first
      user2 = User.offset(rand(User.count)).first
      following = Following.new
      following.follower_id = user1.id
      following.followed_id = user2.id
      following.save
    end
    puts "400 fake follows created"
  end

end
