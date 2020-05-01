require 'faraday'
require 'cgi'

module Clients
	class Scryfall
		BASE_URL = "https://api.scryfall.com"
		CARD_FIELDS = %w[name layout image_uris mana_cost cmc type_line oracle_text color_identity set power toughness card_faces]

		def initialize
			@client = Faraday.new BASE_URL do |faraday|
				faraday.use Faraday::Response::RaiseError
			end
		end

		def get_card(name, set = nil)
			@client.headers['Content-Type'] = 'application/x-www-form-urlencoded'
			response = @client.get("/cards/named?fuzzy=#{card_params(name, set)}")
			sanitize_card(JSON.parse(response.body))
		end

		def get_card_list(card_list)
			@client.headers['Content-Type'] = 'application/json'
			response = @client.post("/cards/collection", card_list_params(card_list).to_json)
			sanitize_list(JSON.parse(response.body))
		end

		private

		def sanitize_list(list_data)
			errors = list_data['not_found']
			cards = list_data['data'].map{ |card_data| sanitize_card(card_data) }
			[errors, cards]
		end

		def sanitize_card(card_data)
			unless card_data['image_uris']
				card_data['image_uris'] = card_data['card_faces'][0]['image_uris']
			end
			card_data.select { |k,v| CARD_FIELDS.include? k }
		end

		def card_params(name, set)
			encoded_name = CGI.escape name
			params = set.nil? ? encoded_name : encoded_name + "&set=#{set}"
		end

		def card_list_params(card_list)
			{
				:identifiers => card_list.map do |card|
					card.select do |k,_|
						[:name, :set].include? k
					end
				end
			}
		end
	end
end