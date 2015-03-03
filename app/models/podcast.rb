class Podcast < ActiveRecord::Base
  has_many :episodes, dependent: :destroy
  has_many :reviews, through: :episodes

  def avg_rating
    total_rating = self.episodes.inject(0) do |sum, ep|
      sum + ep.rating
    end

    return total_rating/(self.episodes.count)
  end
end
