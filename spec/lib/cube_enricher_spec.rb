require 'rails_helper'

RSpec.describe CubeEnricher do
	describe '#get_enriched_cube_list' do
		let(:cube_list) do
			[{
				"name": "shock",
				"set": "SHD"
			}.merge(user_provided_params), {
				"name": "channel",
				"set": "LEB"
			}.merge(user_provided_params), {
				"name": "tundra",
				"set": "3ED"
			}.merge(user_provided_params)]
		end
		let(:user_provided_params) do
			{
				"count": 1,
				"custom_color_identity": "R"
			}
		end
		let(:shock_response) do
			{
				"name": "shock",
				"layout": "something",
				"cmc": 1
			}
		end
		let(:channel_response) do
			{
				"name": "channel",
				"layout": "something",
				"cmc": 2
			}
		end
		let(:tundra_response) do
			{
				"name": "tundra",
				"layout": "something",
				"cmc": 0
			}
		end
		let(:expected_response) do
			[shock_response.merge(user_provided_params).stringify_keys,
				channel_response.merge(user_provided_params).stringify_keys,
				tundra_response.merge(user_provided_params).stringify_keys]
		end

		before do
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=shock&set=SHD")
				.to_return(status: 200, body: shock_response.to_json, headers: {})
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=channel&set=LEB")
				.to_return(status: 200, body: channel_response.to_json, headers: {})
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=tundra&set=3ED")
				.to_return(status: 200, body: tundra_response.to_json, headers: {})
		end

		subject { described_class.new(cube_list).get_enriched_cube_list }

		it 'transforms cube list' do
			expect(subject).to eq expected_response
		end
	end
end