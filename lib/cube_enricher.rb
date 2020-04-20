class CubeEnricher
	def initialize(cube_list)
		@cube_list = cube_list
	end

	def get_enriched_cube_list
		@cube_list.map { |card|
			scryfall_card(card[:name], card[:set]).merge({
				"count" => card[:count],
				"custom_color_identity" => card[:custom_color_identity]})
		}
	end

	private

	def scryfall_card(card, set)
		Clients::Scryfall.new.get_card(card, set)
	end
end