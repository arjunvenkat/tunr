class Following < ActiveRecord::Base

  def follower
    User.find(self.follower_id)
  end

  def followed
    User.find(self.followed_id)
  end



  validate :cant_follow_yourself

  def cant_follow_yourself
    if self.follower_id == self.followed_id
      errors.add(:follower_id, "must be different than followed")
    end
  end
end
