class API::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
  	begin
	    build_resource(sign_up_params)

	    resource.save
	    render_resource(resource)
	  rescue ActiveRecord::RecordNotUnique => ex
	  	if ['Key (email)', 'already exists'].any? { |substring| ex.message.include? substring }
	  		raise ActionController::BadRequest.new(), "User already exists"
	  	else
	  		raise ex
	  	end
	  end
  end
end