module Users
	module V1
		class SessionsAPI < Grape::API
			version 'v1'
			prefix :api
			format :json

			resource :users do
				desc 'log in a user with JWT'
				params do
					requires :email, type: String
					requires :password, type: String
				end
				post 'login' do
					user = User.find_by_email(params[:email])
    			if user && user.authenticate(params[:password])
    				header 'Authorization', "Bearer #{JsonWebToken.encode(user_id: user.id)}"
    				status 200
    				return user
    			end
    			error!('Invalid Credentials', 401)
				end
			end
		end
	end
end