class API::V1::CubesController < ApplicationController
	before_action :authenticate_app_user!
	respond_to :json

	def create
		begin
			Cube.transaction do
				cube = Cube.create!(user_id: current_app_user.id, name: name_param)
				cube.create_cube_cards CubeEnricher.new(cube_list_param).get_enriched_cube_list
			end
			render json: {"message": "success"}, status: :created
		rescue ActionController::ParameterMissing => ex
			render json: {"error": "#{ex}"}, status: :bad_request
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
end