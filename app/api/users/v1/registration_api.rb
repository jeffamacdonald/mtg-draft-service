module Users
	module V1
		class RegistrationAPI < Grape::API
			version 'v1'
			prefix :api
			format :json

			resource :users do

				desc 'register a user'
				params do
					requires :email, type: String
					requires :password, type: String
					requires :password_confirmation, type: String
					requires :username, type: String
					optional :phone, type: String
				end
				post 'register' do
					begin
				    User.create!(params).display_user
				  rescue ActiveRecord::RecordNotUnique => ex
				  	status :unprocessable_entity
				  	{"message": "User already exists"}
				  rescue ActiveRecord::RecordInvalid => ex
				  	status :bad_request
				  	{"error": ex.message}
				  end
				end

			end
		end
	end
end