class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @reviews = @user.reviews.order('created_at DESC').page params[:page]

    if params[:tab] == 'recommendations'
      lists_of_reviews = @user.follows.map do |followed|
        followed.reviews.where('rating >= 4')
      end
      unsorted_reviews = lists_of_reviews.flatten
      unsorted_episodes = unsorted_reviews.map {|review| review.episode }
      already_listened_to = @user.reviews.map {|review| review.episode }
      left_to_listen_to = (unsorted_episodes - already_listened_to).uniq
      @recommendations = left_to_listen_to.sort_by { |episode| episode.rating }.reverse.take(10)

    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :fname, :lname, :sex, :desc, :image_url, :age_range)
    end
end
