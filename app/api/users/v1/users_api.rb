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
					User.all.map(&:display_user)
				end

				desc 'search users'
				params do
					requires :term, type: String, allow_blank: false
				end
				get 'search' do
					User.where("username LIKE ?", "%#{params[:term]}%")
						.or(User.where("email LIKE ?","%#{params[:term]}%"))
						.all.map(&:display_user)
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
