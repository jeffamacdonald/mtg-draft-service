require 'faraday'
require 'cgi'

module Clients
	class Scryfall
		BASE_URL = "https://api.scryfall.com"

		def initialize
			@client = Faraday.new BASE_URL do |faraday|
				faraday.use Faraday::Response::RaiseError
				faraday.response :json, :parser_options => { :symbolize_names => true }
			end
		end

		def get_card(name, set = nil)
			@client.headers['Content-Type'] = 'application/x-www-form-urlencoded'
			response = @client.get("/cards/named?exact=#{card_params(name, set)}")
			CardSanitizer.sanitize_card(response.body, name)
		end

		def get_card_list(card_list)
			@client.headers['Content-Type'] = 'application/json'
			response = @client.post("/cards/collection", card_list_params(card_list).to_json)
			sanitize_list(response.body, card_list)
		end

		private

		def sanitize_list(list_data, card_list)
			errors = list_data[:not_found].map do |error|
				error.merge({:message => "Card Not Found"})
			end
			cards = list_data[:data].map do |card_data|
				CardSanitizer.sanitize_card(card_data, card_list.find { |card|
					card_data[:name].include? card[:name] }[:name])
			end
			[errors, cards]
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