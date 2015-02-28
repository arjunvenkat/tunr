class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :reviews, dependent: :destroy
  has_many :upvotes, dependent: :destroy

  before_create :add_profile_pic

  def followers
    Following.where(followed_id: self.id).map { |following| following.follower }
  end

  def follows
    Following.where(follower_id: self.id).map { |following| following.followed}
  end

  paginates_per 10


  validates :username, :email, presence: true
  validates :username, :email, uniqueness: true

  def add_profile_pic
    if self.image_url.blank?
      self.image_url = Faker::Avatar.image(self.username)
    end
  end
end
