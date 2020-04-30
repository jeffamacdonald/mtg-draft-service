module Drafts
	module V1
		class DraftsAPI < Grape::API
			version 'v1'
			prefix :api
			format :json
			helpers AuthHelper

			before do
				set_authenticated_user
			end

			resources :drafts do

				desc 'get draft by id'
				params do
					requires :draft_id, type: Integer
				end
				get ':draft_id' do
					begin
						Draft.find(params[:draft_id])
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				desc 'create draft and draft participants'
				params do
					requires :name, type: String
					requires :cube_id, type: Integer
					requires :rounds, type: Integer
					requires :user_ids, type: Array
					optional :timer_minutes, type: Integer
				end
				post 'create' do
					begin
						ActiveRecord::Base.transaction do
							Draft.create!(cube_id: params[:cube_id],
														name: params[:name],
														rounds: params[:rounds],
														active_status: true,
														timer_minutes: params[:timer_minutes])
								.create_participants(params[:user_ids])
						end
						{ 'message': 'success' }
					rescue ActiveRecord::RecordNotFound => ex
						error!('Invalid Draft Participants', :bad_request)
					end
				end
			end
		end
	end
end