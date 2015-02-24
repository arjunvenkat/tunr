namespace :fake do
  desc "create fake review data"
  task :reviews => :environment do

    50.times do
      500.times do
        user = User.offset(rand(User.count)).first
        episode = Episode.offset(rand(Episode.count)).first
        review = Review.new
        review.user_id = user.id
        review.episode_id = episode.id
        review.rating = rand(1..5)
        review.contents = Faker::Lorem.paragraph(5)
        review.save
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
end
