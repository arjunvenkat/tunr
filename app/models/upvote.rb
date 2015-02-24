class Upvote < ActiveRecord::Base
  belongs_to :review
  belongs_to :user

  validate :one_upvote_per_user_per_episode

  # validates_uniqueness_of :user_id, :scope => :review_id
  validates_associated :review, :user

  def one_upvote_per_user_per_episode
    episode_upvotes = self.review.episode.upvotes
    episode_upvotes_for_user = episode_upvotes.where(user_id: self.user_id)
    if episode_upvotes_for_user.count > 0
      errors.add(:user, "can only have one upvote per episode")
    end
  end
end
