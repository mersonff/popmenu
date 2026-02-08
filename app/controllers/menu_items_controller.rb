class MenuItemsController < ApplicationController
  before_action :set_menu
  before_action :set_menu_item, only: %i[show update destroy]

  def index
    menu_items = @menu.menu_items
    render json: { data: menu_items }
  end

  def show
    render json: { data: @menu_item }
  end

  def create
    menu_item = @menu.menu_items.create!(menu_item_params)
    render json: { data: menu_item }, status: :created
  end

  def update
    @menu_item.update!(menu_item_params)
    render json: { data: @menu_item }
  end

  def destroy
    @menu_item.destroy!
    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:menu_id])
  end

  def set_menu_item
    @menu_item = @menu.menu_items.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price)
  end
end
