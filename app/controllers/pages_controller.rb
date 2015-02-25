require 'csv'

class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def home
    @episodes = Episode
                  .where.not(rating: nil)
                  .order('rating DESC')
                  .limit(12)
  end
end

