class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActionController::BadRequest, with: :bad_request

	def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '400',
          title: 'Bad Request',
          detail: resource.errors,
          code: '100'
        }
      ]
    }, status: :bad_request
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :phone])
  end

  private

  def bad_request(exception)
    render status: 400, json: {:error => exception.message}.to_json
  end
end
