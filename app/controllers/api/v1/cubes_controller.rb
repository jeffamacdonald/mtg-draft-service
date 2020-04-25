class API::V1::CubesController < ApplicationController
	before_action :authenticate_app_user!
	respond_to :json

	# def authenticate_app_user!
	# 	binding.pry
	# 	super
	# end

	def create
		begin
			ActiveRecord::Base.transaction do
				cube = Cube.create!(user_id: current_app_user.id, name: name_param)
				cube.create_cube_cards(cube_list_param)
			end
			render json: {"message": "success"}, status: :created
		rescue Cube::CreationError => ex
			render json: {"message": JSON.parse(ex.message)}, status: :unprocessable_entity
		rescue ActionController::ParameterMissing => ex
			render json: {"error": ex.message}, status: :bad_request
		end
	end

	def import
		begin
			ActiveRecord::Base.transaction do
				cube = Cube.create!(user_id: current_app_user.id, name: name_param)
				cube_list, errors = parsed_dck_file
				cube.create_cube_cards(cube_list)
			end
			if errors.empty?
				render json: {"message": "success"}, status: :created
			else
				render json: {"message": errors}, status: :unprocessable_entity
			end
		rescue Cube::CreationError => ex
			render json: {"message": JSON.parse(ex.message) + errors}, status: :unprocessable_entity
		rescue DckParser::ParseError => ex
			render json: {"error": ex.message}, status: :bad_request
		rescue ActionController::ParameterMissing => ex
			render json: {"error": ex.message}, status: :bad_request
		end
	end

	private

	def name_param
		params.require(:name)
	end

	def cube_list_param
		params.permit(cube_list: [:count, :set, :card_name]).tap { |list_params|
			params.require(:cube_list)
			list_params["cube_list"].each do |param|
				param.require([:count, :card_name])
			end
		}.to_h["cube_list"]
	end

	def dck_file_param
		params.require(:dck_file)
	end

	def cube
		@cube ||= Cube.create!(user_id: current_app_user.id, name: name_param)
	end

	def parsed_dck_file
		cube.dck_file = dck_file_param
		cube.save!
		binding.pry
		DckParser.new(cube.dck_file).get_parsed_list
	end
end