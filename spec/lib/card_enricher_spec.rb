require 'rails_helper'

RSpec.describe CardEnricher do
	describe '#get_enriched_card' do
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
			scryfall_response.merge(user_provided_params).with_indifferent_access
		end
		let!(:scryfall_stub) do
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Shock" + set_param)
				.to_return(status: status, body: scryfall_response.to_json, headers: {})
		end

		subject { described_class.new(card).get_enriched_card }

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