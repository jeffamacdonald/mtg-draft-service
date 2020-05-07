class CardEnricher
	class << self
		def get_enriched_list(card_list)
			errors, scryfall_card_list = scryfall_list(card_list)
			{
				:errors => errors,
				:card_list => combine_card_data(card_list, scryfall_card_list)
			}
		end

		def get_enriched_card(card_hash)
			scryfall_hash = scryfall_card(card_hash)
			return scryfall_hash if scryfall_hash.has_key? :error
			scryfall_hash.merge({
				:count => card_hash[:count],
				:custom_color_identity => card_hash[:custom_color_identity]
			})
		end

		private

		def combine_card_data(card_list, scryfall_card_list)
			combined_lists = card_list + scryfall_card_list
			combined_lists.group_by { |card| card[:name] }
				.reject { |k,v| v.length < 2 }
				.map { |_, hsh| hsh.reduce(:merge)}
		end

		def scryfall_list(card_list)
			Clients::Scryfall.new.get_card_list(card_list)
		end

		def scryfall_card(card_hash)
			begin
				Clients::Scryfall.new.get_card(card_hash[:name], card_hash[:set])
			rescue Faraday::ResourceNotFound
				if card_hash[:set].nil?
					{:error => {:name => card_hash[:name], :message => "Card Not Found"}}
				else
					{:error => {:name => card_hash[:name], :set => card_hash[:set], :message => "Card Not Found in Set"}}
				end
			end
		end
	end
end