require 'faraday'

class Scryfall
	BASE_URL = "https://api.scryfall.com"
	CARD_FIELDS = %w[name layout img_uris mana_cost cmc type_line oracle_text color_identity set power toughness]

	def initialize
		@client = Faraday.new BASE_URL do |faraday|
			faraday.headers['Content-Type'] = 'application/json'
		end
	end

	def get_card(card_name, set = nil)
		params = set.nil? ? card_name : card_name + "&set=" + set
		response = @client.get("/cards/named?fuzzy=" + params)
		response.status == 200 ? sanitize(response) : nil
	end

	private

	def sanitize(response)
		parsed_response = JSON.parse(response.body)
		parsed_response.select { |k,v| CARD_FIELDS.include? k }
	end
end