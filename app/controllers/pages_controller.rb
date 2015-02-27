require 'csv'

class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def home
    @recent_reviews = current_user.follows.map do |user|
      user.reviews.order('created_at DESC').limit(3)
    end.flatten.sort_by{ |review| review.created_at }.take(24)

    @episodes = Episode
                  .where.not(rating: nil)
                  .order('rating DESC')
                  .limit(8)
  end
end

