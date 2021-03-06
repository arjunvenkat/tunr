class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, except: [:index, :show]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  def new_from_episode
    @review = Review.new
    @episode = Episode.find(params[:episode_id])
  end

  def edit_from_episode
    @review = Review.find(params[:review_id])
    @episode = @review.episode
  end

  # GET /reviews/1/edit
  def edit

  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review.episode, notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @review }
        format.js
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    @review.user_id = current_user.id
    respond_to do |format|
      if @review.update(review_params)
        if params[:redirect_controller] == 'users'
          format.html { redirect_to @review.user, notice: 'Review was successfully updated.' }
        elsif params[:redirect_controller] == 'episodes'
          format.html { redirect_to @review.episode, notice: 'Review was successfully updated.' }
        else
          format.html { redirect_to :back, notice: 'Review was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @review }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:user_id, :episode_id, :rating, :contents)
    end
end
