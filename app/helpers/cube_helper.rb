module CubeHelper
	def existing_cards_array
		@existing_cards ||= Card.get_cards_by_cube_list(@cube_list).to_a
	end
end