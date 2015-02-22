class Review < ActiveRecord::Base
  belongs_to :episode
  belongs_to :user
  after_save :calcuate_average_rating

  private
    def calcuate_average_rating
      episode = self.episode
      ep_ratings = episode.reviews.map do |review|
        review.rating
      end

      episode.rating = ep_ratings.sum / ep_ratings.size.to_f
      episode.save
    end
end


