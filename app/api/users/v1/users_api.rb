module Users
	module V1
		class UsersAPI < Grape::API
			version 'v1'
			prefix :api
			format :json
			helpers AuthHelper

			before do
				set_authenticated_user
			end

			resource :users do

				desc 'get all users'
				get '' do
					User.all.map { |user| user.display_user }
				end

				desc 'get all cubes for authenticated user'
				get 'cubes' do
					@user.cubes
				end

				desc 'get all drafts for authenticated user'
				get 'drafts' do
					@user.display_drafts
				end

			end
		end
	end
end