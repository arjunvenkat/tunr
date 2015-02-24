namespace :fake do
  desc "create fake review data"
  task :reviews => :environment do

    40.times do
      user = User.find :first, :offset => rand(User.count)
      episode = Episode.find :first, :offset => rand(Episode.count)
      review = Review.new
      review.user_id = user.id
      review.episode_id = episode.id
      review.rating = rand(1..5)
      review.contents = Faker::Lorem.paragraph(5)
    end

  end

  desc "create fake upvote data"
  task :upvotes => :environment do

    100.times do
      user = User.find :first, :offset => rand(User.count)
      review = Review.find :first, :offset => rand(Review.count)
      upvote = Upvote.new
      upvote.user_id = user.id
      upvote.review_id = review.id
    end

  end
end
