class Episode < ActiveRecord::Base
  belongs_to :podcast
  has_many :reviews

  self.per_page = 10
end
