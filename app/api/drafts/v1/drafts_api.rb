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
						Draft.find(params[:draft_id]).display_draft
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				desc 'add draft participants by id'
				params do
					requires :draft_id, type: Integer
					requires :user_ids, type: Array
				end
				post ':draft_id/add_participants' do
					begin
						draft = Draft.find(params[:draft_id])
						error!('Only draft owners can add participants', :bad_request) unless draft.user_id == @user.id
						error!('Can only add participants to a PENDING draft', :bad_request) unless draft.status == 'PENDING'
						draft.create_participants(params[:user_ids])
						{ 'message': 'success' }
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				desc 'start draft by id'
				params do
					requires :draft_id, type: Integer
				end
				patch ':draft_id/start' do
					begin
						draft = Draft.find(params[:draft_id])
						error!('Only draft owners can start the draft', :bad_request) unless draft.user_id == @user.id
						error!('Can only start a PENDING draft', :bad_request) unless draft.status == 'PENDING'
						draft.set_participant_positions
						draft.update(status: 'ACTIVE')
						{ 'message': 'success' }
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
							Cube.find(params[:cube_id])
							draft = Draft.create!(cube_id: params[:cube_id],
														user_id: @user.id,
														name: params[:name],
														rounds: params[:rounds],
														status: 'PENDING',
														timer_minutes: params[:timer_minutes])
								.create_participants(params[:user_ids])
						end
						{ 'message': 'success' }
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :bad_request)
					end
				end

				desc 'join a pending draft'
				params do
					requires :draft_id, type: Integer
				end
				post ':draft_id/join' do
					begin
						draft = Draft.find(params[:draft_id])
						error!('You have already joined', :bad_request) if draft.users.include? @user
						error!('Can only join a PENDING draft', :bad_request) unless draft.status == 'PENDING'
						draft.create_participants([@user.id])
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				resources :status do
					desc 'get all drafts by status'
					params do
						requires :status, type: String
					end
					get ':status' do
						error!('Invalid Status', :bad_request) unless Draft::STATUSES.include? params[:status]
						Draft.where(status: params[:status]).map(&:display_draft)
					end
				end
			end
		end
	end
end