class Upvote < ActiveRecord::Base
  belongs_to :review
  belongs_to :user

  validate :one_upvote_per_user_per_episode
  after_create :increment_user_upvoted_count
  after_create :increment_review_upvoted_count
  before_destroy :decrement_user_upvoted_count
  before_destroy :decrement_review_upvoted_count

  # validates_uniqueness_of :user_id, :scope => :review_id
  validates_associated :review, :user


  def one_upvote_per_user_per_episode
    episode_upvotes = self.review.episode.upvotes
    episode_upvotes_for_user = episode_upvotes.where(user_id: self.user_id)
    if episode_upvotes_for_user.count > 0
      errors.add(:user, "can only have one upvote per episode")
    end
  end

  private
    def increment_user_upvoted_count
      user = self.review.user
      user.upvoted_count += 1
      user.save
    end

    def increment_review_upvoted_count
      review = self.review
      review.upvoted_count += 1
      review.save
    end

    def decrement_user_upvoted_count
      user = self.review.user
      user.upvoted_count -= 1
      user.save
    end

    def decrement_review_upvoted_count
      review = self.review
      review.upvoted_count -= 1
      review.save
    end
end
