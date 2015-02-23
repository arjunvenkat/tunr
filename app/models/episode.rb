class Episode < ActiveRecord::Base
  belongs_to :podcast
  has_many :reviews

  paginates_per 15
end
