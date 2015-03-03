class Podcast < ActiveRecord::Base
  has_many :episodes, dependent: :destroy
  has_many :reviews, through: :episodes
end
