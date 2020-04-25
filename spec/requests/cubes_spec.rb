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
	end

	describe 'POST /create', type: :request do
		let(:url) { "/api/v1/cubes/create" }
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
			it 'returns 401' do
				subject
				expect(response.status).to eq 401
			end
		end

		context 'when user is signed in' do
			let(:user) { create :user }

			before do
				sign_in user
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
		let(:url) { "/api/v1/cubes/import" }
		let(:line1) { '1 [LEB:123] Lightning Bolt' }
		let(:line2) { '1 [RAV:321] Dark Confidant' }
		let(:file) do
			Tempfile.new(['test', '.dck']).tap do |f|
				f.puts line1
				f.puts line2
				f.close
			end
		end
		let(:params) do
			{
				name: "my cube",
				dck_file: file
			}
		end

		subject { post url, params: params}

		context 'when user is not signed in' do
			it 'returns 401' do
				subject
				expect(response.status).to eq 401
			end
		end

		context 'when user is signed in' do
			let(:user) { create :user }

			before do
				sign_in user
			end

			it 'returns 201' do
				subject
				expect(response.status).to eq 201
			end
		end
	end
end