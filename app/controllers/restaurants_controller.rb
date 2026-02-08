class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show update destroy]

  def index
    restaurants = Restaurant.all
    render json: { data: restaurants }
  end

  def show
    render json: { data: @restaurant }
  end

  def create
    restaurant = Restaurant.create!(restaurant_params)
    render json: { data: restaurant }, status: :created
  end

  def update
    @restaurant.update!(restaurant_params)
    render json: { data: @restaurant }
  end

  def destroy
    @restaurant.destroy!
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :address, :phone)
  end
end
