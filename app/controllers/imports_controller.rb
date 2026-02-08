class ImportsController < ApplicationController
  def create
    restaurant = Restaurant.find(params[:restaurant_id])
    data = params.permit!.to_h.except("controller", "action", "restaurant_id")

    result = JsonImportService.new(restaurant: restaurant, data: data).call

    if result.success?
      render json: { data: result.data }, status: :ok
    else
      render json: { error: { message: result.error } }, status: :unprocessable_entity
    end
  end
end
