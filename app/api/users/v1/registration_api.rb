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
				  	error!('User already exists', :unprocessable_entity)
				  rescue ActiveRecord::RecordInvalid => ex
				  	error!(ex.message, :bad_request)
				  end
				end

			end
		end
	end
end