require 'faraday'
require 'cgi'

module Clients
	class Scryfall
		BASE_URL = "https://api.scryfall.com"
		CARD_FIELDS = %w[name layout image_uris mana_cost cmc type_line oracle_text color_identity set power toughness card_faces]

		def initialize
			@client = Faraday.new BASE_URL do |faraday|
				faraday.use Faraday::Response::RaiseError
				faraday.headers['Content-Type'] = 'application/x-www-form-urlencoded'
			end
		end

		def get_card(card_name, set = nil)
			encoded_name = CGI.escape card_name
			params = set.nil? ? encoded_name : encoded_name + "&set=#{set}"
			response = @client.get("/cards/named?fuzzy=#{params}")
			sanitize(response)
		end

		private

		def sanitize(response)
			parsed_response = JSON.parse(response.body)
			unless parsed_response['image_uris']
				parsed_response['image_uris'] = parsed_response['card_faces'][0]['image_uris']
			end
			parsed_response.select { |k,v| CARD_FIELDS.include? k }
		end
	end
end