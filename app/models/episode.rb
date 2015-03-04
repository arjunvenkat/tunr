class Episode < ActiveRecord::Base
  belongs_to :podcast
  has_many :reviews
  has_many :upvotes, through: :reviews

  paginates_per 15


end
