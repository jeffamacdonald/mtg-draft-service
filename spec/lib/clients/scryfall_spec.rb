require 'rails_helper'

RSpec.describe Clients::Scryfall do
	describe '#get_card' do
		let(:card_name) { "Austere Command" }
		let(:scryfall_response) do
			{
				"name": card_name,
				"layout": "normal",
				"image_uris": {
			    "small": "httpblah",
			    "normal": "httpblah"
			  },
			  "mana_cost": "{4}{W}{W}",
			  "cmc": 6,
			  "type_line": "Sorcery",
			  "oracle_text": "Choose two —\n• Destroy all artifacts.\n• Destroy all enchantments.\n• Destroy all creatures with converted mana cost 3 or less.\n• Destroy all creatures with converted mana cost 4 or greater.",
			  "color_identity": ["W"],
			  "set": "LRW"
			}
		end
		let(:expected_response) do
			scryfall_response.select { |k,v| CardSanitizer::CARD_FIELDS.include? k.to_s }
		end
		let(:status_code) {200}
		let!(:scryfall_stub) do
			stub_request(:get, "#{described_class::BASE_URL}/cards/named?#{scryfall_params}")
				.to_return(status: status_code, body: scryfall_response.to_json, headers: {})
		end

		context 'when params contains only name' do
			let(:scryfall_params) { "exact=#{card_name}" }
			let(:encoded_faraday_params) {"/cards/named?exact=Austere+Command"}

			subject { described_class.new.get_card(card_name) }

			it 'calls scryfall with only name' do
				subject
				expect(scryfall_stub).to have_been_requested
			end

			it 'name is encoded' do
				expect_any_instance_of(Faraday::Connection).to receive(:get)
					.with(encoded_faraday_params).and_call_original
				subject
			end

			it 'sanitizes response' do
				expect(CardSanitizer).to receive(:sanitize_card).with(scryfall_response, card_name)
				subject
			end

			context 'when scryfall returns 404 status' do
				let(:status_code) {404}

				it 'returns nil' do
					expect{subject}.to raise_error Faraday::ResourceNotFound
				end
			end
		end

		context 'when params contain both name and set' do
			let(:set) {'leb'}
			let(:scryfall_params) { "exact=#{card_name}&set=#{set}" }

			subject { described_class.new.get_card(card_name, set) }

			it 'calls scryfall with name and set' do
				subject
				expect(scryfall_stub).to have_been_requested
			end
		end
	end

	describe '#get_card_list' do
		let(:bolt_card_hash) do
			{
				"name": "Lightning Bolt",
				"layout": "something",
				"image_uris": {
			    "small": "httpblah",
			    "normal": "httpblah"
			  },
			  "mana_cost": "{R}",
			  "cmc": 1,
			  "type_line": "Instant",
			  "oracle_text": "Deal 3 damage to any target.",
			  "color_identity": ["R"],
			  "set": "LEB"
			}
		end
		let(:bob_card_hash) do
			{
				"name": "Dark Confidant",
				"layout": "normal",
				"image_uris": {
			    "small": "httpblahsmall",
			    "normal": "httpblahnormal"
			  },
			  "mana_cost": "{1}{B}",
			  "cmc": 2,
			  "type_line": "Creature - Human Wizard",
			  "oracle_text": "At the beginning of your upkeep, reveal the top card of your library and put that card into your hand. You lose life equal to its converted mana cost.",
			  "color_identity": ["B"],
			  "power": 2,
			  "toughness": 1,
			  "set": "RAV"
			}
		end
		let(:scryfall_response) do
			{
				"not_found": [bad_query_data],
				"data": [bolt_card_hash,bob_card_hash]
			}
		end
		let!(:scryfall_stub) do
			stub_request(:post, "#{described_class::BASE_URL}/cards/collection").with(body: params)
				.to_return(status: 200, body: scryfall_response.to_json, headers: {})
		end
		let(:bolt) do
			{
				"name": "Lightning Bolt",
				"set": "LEB"
			}
		end
		let(:bob) do
			{
				"name": "Dark Confidant",
				"set": "RAV"
			}
		end
		let(:bad_query_data) do
			{
				"name": "Some Garbage",
				"set": "LEB"
			}
		end
		let(:params) do
			{
				"identifiers": [bolt, bob, bad_query_data]
			}
		end
		let(:cube_list) do
			[bolt, bob, bad_query_data].map {|card| card.merge({"count": 1})}
		end
		let(:expected_response) do
			[
				[bad_query_data.merge({:message => "Card Not Found"})],
				[CardSanitizer.sanitize_card(bolt_card_hash, 'Lightning Bolt'),
					CardSanitizer.sanitize_card(bob_card_hash, 'Dark Confidant')
				]
			]
		end

		subject { described_class.new.get_card_list(cube_list) }

		it 'calls scryfall stub with expected params' do
			subject
			expect(scryfall_stub).to have_been_requested
		end

		it 'returns expected response' do
			expect(subject).to eq expected_response
		end
	end
end