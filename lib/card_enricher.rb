class CardEnricher
	def initialize(card_hash)
		@card_hash = card_hash
	end

	def get_enriched_card
		scryfall_hash = scryfall_card(@card_hash[:card_name], @card_hash[:set])
		return scryfall_hash if scryfall_hash.has_key? :error
		scryfall_hash.merge({
			"count" => @card_hash[:count],
			"custom_color_identity" => @card_hash[:custom_color_identity]
		}).with_indifferent_access
	end

	private

	def scryfall_card(card, set)
		begin
			Clients::Scryfall.new.get_card(card, set)
		rescue Faraday::ResourceNotFound
			appended_set_message = set.nil? ? "" : " or Card Not Found in Set"
			{
				:card_name => @card_hash[:card_name],
				:error => "Invalid Card Name" + appended_set_message
			}
		end
	end
end