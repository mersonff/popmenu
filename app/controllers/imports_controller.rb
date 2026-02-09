class ImportsController < ApplicationController
  def create
    data = JSON.parse(request.raw_post)

    import = Import.create!(input_data: data)
    ImportJob.perform_later(import.id)

    render json: { data: { id: import.id, status: import.status } }, status: :accepted
  end

  def show
    import = Import.find(params[:id])

    body = { id: import.id, status: import.status, created_at: import.created_at }
    body[:result] = import.result_data if import.completed?
    body[:error_message] = import.error_message if import.failed?

    render json: { data: body }
  end
end
