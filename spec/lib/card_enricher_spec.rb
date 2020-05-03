require 'rails_helper'

RSpec.describe CardEnricher do
	describe '.get_enriched_list' do
		let(:cube_list) do
			[{
				"name": "Lightning Bolt",
				"set": "LEB",
				"count": 1
			}, {
				"name": "Channel",
				"set": "LEB",
				"count": 1
			}]
		end
		let(:scryfall_response) do
			[[], [{
				"name": "Lightning Bolt",
				"cmc": 1
			}, {
				"name": "Channel",
				"cmc": 2
			}]]
		end

		subject { described_class.get_enriched_list(cube_list) }

		before do
			allow_any_instance_of(Clients::Scryfall).to receive(:get_card_list).with(cube_list)
				.and_return(scryfall_response)
		end

		context 'when scryfall returns no errors' do
			let(:expected_response) do
				{
					:errors => [],
					:card_list => [{
						"name": "Lightning Bolt",
						"cmc": 1,
						"set": "LEB",
						"count": 1
					}, {
						"name": "Channel",
						"cmc": 2,
						"set": "LEB",
						"count": 1
					}]
				}
			end

			it 'returns all cards with combined keys with no errors' do
				expect(subject).to eq expected_response
			end
		end

		context 'when scryfall returns some errors' do
			let(:scryfall_response) do
				[[{
					"name": "Channel",
					"set": "LEB"
				}], [{
					"name": "Lightning Bolt",
					"cmc": 1
				}]]
			end
			let(:expected_response) do
				{
					:errors => [{
						"name": "Channel",
						"set": "LEB"
					}],
					:card_list => [{
						"name": "Lightning Bolt",
						"cmc": 1,
						"set": "LEB",
						"count": 1
					}]
				}
			end

			it 'returns cards with combined keys as well as errors' do
				expect(subject).to eq expected_response
			end
		end
	end

	describe '.get_enriched_card' do
		let(:card) do
			{
				"name": "Shock",
				"set": set
			}.merge(user_provided_params)
		end
		let(:user_provided_params) do
			{
				"count": 1,
				"custom_color_identity": "R"
			}
		end
		let(:set) { "SHD" }
		let(:set_param) { "&set=#{set}" }
		let(:scryfall_response) do
			{
				"name": "shock",
				"layout": "something",
				"cmc": 1,
				"image_uris": {
					"normal": "image"
				}
			}
		end
		let(:status) { 200 }
		let(:expected_response) do
			CardSanitizer.sanitize_card(scryfall_response, 'shock').merge(user_provided_params)
		end
		let!(:scryfall_stub) do
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?exact=Shock" + set_param)
				.to_return(status: status, body: scryfall_response.to_json, headers: {})
		end

		subject { described_class.get_enriched_card(card) }

		context 'when scryfall finds card' do
			it 'returns card hash with merged scryfall data' do
				expect(subject).to eq expected_response
			end
		end

		context 'when scryfall cannot find card' do
			let(:status) { 404 }
			let(:set_error) { " or Card Not Found in Set" }
			let(:expected_response) do
				{
					:name => "Shock",
					:error => "Invalid Card Name" + set_error
				}
			end

			it 'returns error' do
				expect(subject).to eq expected_response
			end

			context 'when set is nil' do
				let(:set) { nil }
				let(:set_param) { "" }
				let(:set_error) { "" }

				it 'returns error' do
					expect(subject).to eq expected_response
				end
			end
		end
	end
end