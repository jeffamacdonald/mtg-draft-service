module Users
	module V1
		class CubesAPI < Grape::API
			version 'v1'
			prefix :api
			format :json
			helpers AuthHelper
			helpers do
				def cube
					@cube ||= Cube.create!(user_id: @user.id, name: params[:name])
				end

				def parsed_dck_file
					DckParser.new(params[:dck_file][:tempfile]).get_parsed_list
				end
			end

			before do
				set_authenticated_user
			end

			resource :users do
				resource :cubes do

					desc 'Create a cube from JSON list'
					params do
						requires :name, type: String
						requires :cube_list, type: Array do
							requires :count, type: Integer
							requires :card_name, type: String
							optional :set, type: String
						end
					end
					post 'create' do
						begin
							ActiveRecord::Base.transaction do
								cube.create_cube_cards(params[:cube_list])
							end
							{"message": "success"}
						rescue Cube::CreationError => ex
							status :unprocessable_entity
							{"message": JSON.parse(ex.message)}
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
								cube = Cube.create!(user_id: @user.id, name: params[:name])
								cube_list, errors = parsed_dck_file
								cube.create_cube_cards(cube_list)
							end
							if errors.empty?
								{"message": "success"}
							else
								status :unprocessable_entity
								{"message": errors}
							end
						rescue Cube::CreationError => ex
							status :unprocessable_entity
							{"message": JSON.parse(ex.message) + errors}
						rescue DckParser::ParseError => ex
							status :bad_request
							{"error": ex.message}
						end
					end
				end
			end
		end
	end
end