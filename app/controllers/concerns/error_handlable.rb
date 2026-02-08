module ErrorHandlable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  end

  private

  def render_not_found(exception)
    render json: { error: { message: exception.message } }, status: :not_found
  end

  def render_unprocessable(exception)
    render json: {
      error: {
        message: "Validation failed",
        details: exception.record.errors.full_messages
      }
    }, status: :unprocessable_entity
  end

  def render_parameter_missing(exception)
    render json: { error: { message: exception.message } }, status: :unprocessable_entity
  end
end
