module CubeHelper
	def existing_cards_array
		@existing_cards ||= Card.get_cards_by_cube_list(@cube_list).to_a
	end

	def new_card_hashes
		@new_card_hashes ||= @cube_list.reject do |c|
			existing_cards_array.map { |card|
				card.attributes['name']}.include? c[:name]
		end
	end

	def get_new_enriched_cards
		errors, enriched_cards = [], []
		new_card_hashes.each_slice(75) do |group|
			card_enricher_response = CardEnricher.get_enriched_list(group)
			errors += card_enricher_response[:errors]
			enriched_cards += card_enricher_response[:card_list]
		end
		[errors, enriched_cards]
	end

	def create_new_cards(enriched_cards)
		enriched_cards.each do |card|
			existing_cards_array << Card.create_card_from_hash(card)
		end
	end

	def create_cube_cards_and_return_errors(cube)
		errors = []
		merged_cards_and_cube_list.each do |card_hash|
			begin
				CubeCard.create_cube_card_from_hash(cube, card_hash)
			rescue CubeCard::CreationError => ex
				errors << ex.message
			end
		end
		errors
	end

	def cards_and_cube_list_array
		@cube_list + existing_cards_array.map do |card|
			card.attributes.symbolize_keys
		end
	end

	def merged_cards_and_cube_list
		cards_and_cube_list_array.group_by { |card|
				card[:name]
			}.reject { |k,v|
				v.length < 2
			}.map { |_, hsh|
				hsh.reduce(:merge)
			}
	end
end