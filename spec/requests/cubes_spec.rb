require 'rails_helper'

RSpec.describe 'Cubes Requests' do
	let(:bolt_status) { 200 }
	let(:bolt_response) do
		{
			"name": "Lightning Bolt",
			"layout": "normal",
			"image_uris": {
		    "small": "httpblahsmall",
		    "normal": "httpblahnormal"
		  },
		  "mana_cost": "{R}",
		  "cmc": 1,
		  "type_line": "Instant",
		  "oracle_text": "Deal 3 damage to any target.",
		  "colors": ["R"],
		  "color_identity": ["R"],
		  "set": "LEB"
		}
	end
	let(:bob_response) do
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
		  "colors": ["B"],
		  "color_identity": ["B"],
		  "power": 2,
		  "toughness": 1,
		  "set": "RAV"
		}
	end

	before do
		stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Lightning+Bolt&set=LEB")
			.to_return(status: bolt_status, body: bolt_response.to_json, headers: {})
		stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Dark+Confidant&set=RAV")
			.to_return(status: 200, body: bob_response.to_json, headers: {})
		stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Nothing&set=LEB")
			.to_return(status: 404, body: {}.to_json, headers: {})
	end

	describe 'POST /create', type: :request do
		let(:url) { "/api/v1/users/cubes/create" }
		let(:params) do
			{
				name: "my cube",
				cube_list: [
					{
						count: 1,
						set: 'LEB',
						card_name: 'Lightning Bolt'
					}, {
						count: 1,
						set: 'RAV',
						card_name: 'Dark Confidant'
					}
				]
			}
		end

		subject { post url, params: params}

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let(:user) { create :user }
			let(:decoded_token) do
				{:user_id => user.id}
			end

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns 201' do
				subject
				expect(response.status).to eq 201
			end

			it 'cube is created' do
				subject
				cube = Cube.find_by(user_id: user.id)
				expect(cube).to be_present
				expect(CubeCard.where(cube_id: cube.id).count).to eq 2
				expect(Card.all.count).to eq 2
			end

			context 'scryfall cannot find a card' do
				let(:bolt_status) { 404 }
				let(:expected_body) do
					{
						"message": [{
							"card_name": "Lightning Bolt",
							"error": "Invalid Card Name or Card Not Found in Set"
						}]
					}
				end

				it 'returns 422' do
					subject
					expect(response.status).to eq 422
				end

				it 'returns errors in message' do
					subject
					expect(response.body).to eq expected_body.to_json
				end

				it 'does not create cards' do
					subject
					expect(Card.all).to be_empty
					expect(CubeCard.all).to be_empty
				end
			end

			context 'missing name attribute' do
				let(:params) do
					{
						cube_list: [
							{
								count: 1,
								set: 'LEB',
								card_name: 'Lightning Bolt'
							}
						]
					}
				end

				it 'error is raised' do
					subject
					expect(response.status).to eq 400
				end
			end

			context 'missing cube list attribute' do
				let(:params) do
					{
						name: "some name"
					}
				end

				it 'error is raised' do
					subject
					expect(response.status).to eq 400
				end
			end

			context 'missing card name in list attribute' do
				let(:params) do
					{
						name: "a name",
						cube_list: [
							{
								count: 1,
								set: 'LEB'
							}
						]
					}
				end

				it 'error is raised' do
					subject
					expect(response.status).to eq 400
				end
			end
		end
	end

	describe 'POST /import' do
		let(:url) { "/api/v1/users/cubes/import" }
		let(:file) do
			fixture_file_upload('files/success.dck')
		end
		let(:params) do
			{
				name: "my cube",
				dck_file: file
			}
		end

		subject { post url, params: params}

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let(:user) { create :user }
			let(:decoded_token) do
				{:user_id => user.id}
			end

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns 201' do
				subject
				expect(response.status).to eq 201
			end

			context 'when file has invalid format' do
				let(:file) do
					fixture_file_upload('files/malformed.dck')
				end

				it 'returns 400' do
					subject
					expect(response.status).to eq 400
				end
			end

			context 'when file has dck parse errors' do
				let(:file) do
					fixture_file_upload('files/count_set_errors.dck')
				end
				let(:expected_errors) do
					{
						:message => [{:card_name => "Lightning Bolt",:error => "Count Invalid"},
							{:card_name => "Dark Confidant",:error => "Set Invalid"}]
					}.with_indifferent_access
				end

				it 'returns 422' do
					subject
					expect(response.status).to eq 422
				end

				it 'message contains errors' do
					subject
					expect(JSON.parse(response.body)).to eq expected_errors
				end
			end

			context 'when file has dck parse and scryfall errors' do
				let(:file) do
					fixture_file_upload('files/count_set_name_errors.dck')
				end
				let(:expected_errors) do
					{
						:message => [{:card_name => "Nothing",:error => "Invalid Card Name or Card Not Found in Set"},
							{:card_name => "Lightning Bolt",:error => "Count Invalid"},
							{:card_name => "Dark Confidant",:error => "Set Invalid"}]
					}.with_indifferent_access
				end

				it 'returns 422' do
					subject
					expect(response.status).to eq 422
				end

				it 'message contains errors' do
					subject
					expect(JSON.parse(response.body)).to eq expected_errors
				end
			end
		end
	end
end