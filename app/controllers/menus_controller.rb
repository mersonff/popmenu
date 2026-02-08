class MenusController < ApplicationController
  before_action :set_menu, only: %i[show update destroy]

  def index
    menus = Menu.all
    render json: { data: menus }
  end

  def show
    render json: { data: @menu }
  end

  def create
    menu = Menu.create!(menu_params)
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

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description, :active)
  end
end
