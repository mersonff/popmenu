class MenusController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu, only: %i[show update destroy]

  def index
    menus = @restaurant.menus
    render json: { data: menus }
  end

  def show
    render json: { data: @menu }
  end

  def create
    menu = @restaurant.menus.create!(menu_params)
    render json: { data: menu }, status: :created
  end

  def update
    @menu.update!(menu_params)
    render json: { data: @menu }
  end

  def destroy
    @menu.destroy!
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_menu
    @menu = @restaurant.menus.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description, :active)
  end
end
