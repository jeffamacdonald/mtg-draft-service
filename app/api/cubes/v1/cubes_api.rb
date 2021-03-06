module Cubes
	module V1
		class CubesAPI < Grape::API
			version 'v1'
			prefix :api
			format :json
			helpers AuthHelper
			helpers do
				def create_cube
					Cube.create!(user_id: @user.id, name: params[:name])
				end

				def parsed_dck_file
					DckParser.new(params[:dck_file][:tempfile]).get_parsed_list
				end
			end

			before do
				set_authenticated_user
			end

			resource :cubes do

				desc 'get all cubes'
				get '' do
					Cube.all
				end

				desc 'get all cube cards by id'
				params do
					requires :cube_id, type: Integer
				end
				get ':cube_id' do
					begin
						cube = Cube.find(params[:cube_id])
						cube.display_cube
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				desc 'update cube'
				params do
					requires :cube_id, type: Integer
					optional :name, type: String
					optional :cube_list, type: Array do
						optional :id, type: String
						optional :count, type: String
						optional :set, type: String
						optional :custom_color_identity, type: String
						optional :custom_cmc, type: String
					end
				end
				put ':cube_id' do
					if Draft.where(cube_id: params[:cube_id], status: 'ACTIVE').first
						error!({:message => "Cannot edit a cube being actively drafted"}, :forbidden)
					end
					begin
						@user.cubes.find(params[:cube_id]).update_cube(params)
					rescue ActiveRecord::RecordNotFound => ex
						error!(ex.message, :not_found)
					end
				end

				desc 'Create a cube from JSON list'
				params do
					requires :name, type: String
					requires :cube_list, type: Array do
						requires :count, type: Integer
						requires :name, type: String
						optional :set, type: String
					end
				end
				post 'create' do
					begin
						ActiveRecord::Base.transaction do
							create_cube.setup_cube_from_list(params[:cube_list])
						end
						{"message": "success"}
					rescue Cube::CreationError => ex
						error!(JSON.parse(ex.message), :unprocessable_entity)
					end
				end

				desc 'Import a cube from .dck file'
				params do
					requires :name, type: String
					requires :dck_file, type: File
				end
				post 'import' do
					errors = []
					begin
						ActiveRecord::Base.transaction do
							cube_list, errors = parsed_dck_file
							create_cube.setup_cube_from_list(cube_list)
						end
						if errors.empty?
							{"message": "success"}
						else
							error!(errors, :unprocessable_entity)
						end
					rescue Cube::CreationError => ex
						error!(JSON.parse(ex.message) + errors, :unprocessable_entity)
					rescue DckParser::ParseError => ex
						error!(ex.message, :bad_request)
					end
				end
			end
		end
	end
end