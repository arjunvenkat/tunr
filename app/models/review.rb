class Review < ActiveRecord::Base
  belongs_to :episode
  belongs_to :user
  has_many :upvotes
  after_save :calcuate_average_rating

  validates_uniqueness_of :user_id, :scope => :episode_id

  paginates_per 12

  private
    def calcuate_average_rating
      episode = self.episode
      ep_ratings = episode.reviews.map do |review|
        review.rating
      end.compact

      episode.rating = ep_ratings.sum / ep_ratings.size.to_f
      episode.save
    end
end


