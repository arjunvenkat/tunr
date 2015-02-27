class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :reviews, dependent: :destroy
  has_many :upvotes, dependent: :destroy

  def followers
    Following.where(followed_id: self.id).map { |following| following.follower }
  end

  def follows
    Following.where(follower_id: self.id).map { |following| following.followed}
  end

  paginates_per 10


  validates :username, :email, presence: true
  validates :username, :email, uniqueness: true
end
