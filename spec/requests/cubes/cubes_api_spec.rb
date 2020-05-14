require 'rails_helper'

RSpec.describe 'Cubes API Requests' do
	let(:user) { create :user }
	let(:decoded_token) do
		{:user_id => user.id}
	end
	let(:bolt) do
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
	let(:bob) do
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
	let(:not_found) do
		[]
	end
	let(:scryfall_response) do
		{
			:not_found => not_found,
			:data => [bolt, bob]
		}
	end

	before do
		stub_request(:post, "#{Clients::Scryfall::BASE_URL}/cards/collection")
			.to_return(status: 200, body: scryfall_response.to_json, headers: {})
	end

	describe 'GET /' do
		let(:url) { "/api/v1/cubes" }
		let!(:cube1) { create :cube }
		let!(:cube2) { create :cube }
		let!(:cube3) { create :cube }

		subject { get url }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			let(:expected_response) { [cube1,cube2,cube3] }

			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'returns expected response body' do
				subject
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	describe 'GET /id' do
		let(:url) { "/api/v1/cubes/#{cube_id}" }
		let!(:cube) { create :cube }
		let!(:card_1) { create :card, cmc: 4, color_identity: 'B' }
		let!(:card_2) { create :card, cmc: 5, color_identity: 'C' }
		let!(:card_3) { create :card, cmc: 3, color_identity: 'C' }
		let!(:card_4) { create :card, cmc: 2, color_identity: 'C' }
		let!(:card_5) { create :card, cmc: 5, color_identity: 'UG' }
		let!(:card_6) { create :card, cmc: 4, color_identity: 'UG' }
		let!(:cube_card_1) { create :cube_card, cube_id: cube.id, card_id: card_1.id, custom_cmc: 4, custom_color_identity: 'B', soft_delete: true }
		let!(:cube_card_2) { create :cube_card, cube_id: cube.id, card_id: card_2.id, custom_cmc: 0, custom_color_identity: 'C' }
		let!(:cube_card_3) { create :cube_card, cube_id: cube.id, card_id: card_3.id, custom_cmc: 3, custom_color_identity: 'C' }
		let!(:cube_card_4) { create :cube_card, cube_id: cube.id, card_id: card_4.id, custom_cmc: 2, custom_color_identity: 'R' }
		let!(:cube_card_5) { create :cube_card, cube_id: cube.id, card_id: card_5.id, custom_cmc: 5, custom_color_identity: 'UG' }
		let!(:cube_card_6) { create :cube_card, cube_id: cube.id, card_id: card_6.id, custom_cmc: 4, custom_color_identity: 'UG' }
		let(:cube_id) { cube.id }

		subject { get url }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			let(:colorless_cards) { [cube_card_2,cube_card_3] }
			let(:red_cards) { [cube_card_4] }
			let(:gold_cards) { [cube_card_6,cube_card_5] }
			let(:expected_response) do
				{
					"C" => colorless_cards,
					"R" => red_cards,
					"UG" => gold_cards
				}
			end

			it 'returns expected response body' do
				subject
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end

			context 'when cube does not exist' do
				let(:cube_id) { 100 }

				it 'returns 404' do
					subject
					expect(response.status).to eq 404
				end
			end
		end
	end

	describe 'POST /create', type: :request do
		let(:url) { "/api/v1/cubes/create" }
		let(:cube_list) do
			[{
				:count => 1,
				:set => 'LEB',
				:name => 'Lightning Bolt'
			}, {
				:count => 1,
				:set => 'RAV',
				:name => 'Dark Confidant'
			}]
		end
		let(:params) do
			{
				:name => "my cube",
				:cube_list => cube_list
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
			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			it 'cube is created' do
				subject
				expect(response.status).to eq 201
				cube = Cube.find_by(user_id: user.id)
				expect(cube).to be_present
				expect(CubeCard.where(cube_id: cube.id).count).to eq 2
				expect(Card.all.count).to eq 2
			end

			context 'scryfall cannot find a card' do
				let(:cube_list) do
					[{
						:count => 1,
						:set => 'LEB',
						:name => 'Lightning Bolt'
					}, {
						:count => 1,
						:set => 'RAV',
						:name => 'Dark Confidant'
					}, {
						:name => "Counterspall",
						:set => "LEB",
						:count => 1
					}]
				end
				let(:not_found) do
					[{
						:name => "Counterspall",
						:set => "LEB"
					}]
				end
				let(:expected_body) do
					{
						"error": [{
							"name": "Counterspall",
							"set": "LEB",
							"message": "Card Not Found"
						}]
					}
				end

				it 'returns errors in body' do
					subject
					expect(response.status).to eq 422
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
						:cube_list => [
							{
								:count => 1,
								:set => 'LEB',
								:name => 'Lightning Bolt'
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
						:name => "some name"
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
						:name => "a name",
						:cube_list => [
							{
								:count => 1,
								:set => 'LEB'
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

	describe 'POST /import', type: :request do
		let(:url) { "/api/v1/cubes/import" }
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
						:error => [{:name => "Lightning Bolt",:message => "Count Invalid"},
							{:name => "Dark Confidant",:message => "Set Invalid"}]
					}
				end

				it 'body contains errors' do
					subject
					expect(response.status).to eq 422
					expect(response.body).to eq expected_errors.to_json
				end
			end

			context 'when file has dck parse and scryfall errors' do
				let(:not_found) do
					[{
						:name => "Counterspall",
						:set => "LEB"
					}]
				end
				let(:file) do
					fixture_file_upload('files/count_set_name_errors.dck')
				end
				let(:expected_errors) do
					{
						:error => [{:name => "Counterspall",:set => "LEB",:message => "Card Not Found"},
							{:name => "Channel",:message => "Set Invalid"}]
					}
				end

				it 'body contains errors' do
					subject
					expect(response.status).to eq 422
					expect(response.body).to eq expected_errors.to_json
				end
			end
		end
	end

	describe 'PUT /:cube_id' do
		let(:url) { "/api/v1/cubes/#{cube.id}" }
		let(:cube) { create :cube, user_id: user.id }
		let(:cube_name) { 'updated name' }
		let(:params) do
			{
				:name => cube_name,
				:cube_list => cube_list
			}
		end
		let(:cube_list) { [bolt, bob] }
		let(:bolt) do
			{
				:name => 'Lightning Bolt',
				:set => 'LEB',
				:count => 1
			}
		end
		let(:bob) do
			{
				:name => 'Dark Confidant',
				:set => 'RAV',
				:count => 1
			}
		end

		subject { put url, params: params }

		context 'when user is not signed in' do
			it 'returns 403' do
				subject
				expect(response.status).to eq 403
			end
		end

		context 'when user is signed in' do
			before do
				allow(JsonWebToken).to receive(:decode).and_return(decoded_token)
			end

			context 'when cube is currently being drafted' do
				let!(:draft) { create :draft, cube_id: cube.id }
				let(:expected_response) do
					{
						:message => 'Cannot edit a cube being actively drafted'
					}
				end

				it 'body contains error message' do
					subject
					expect(response.status).to eq 403
					expect(response.body).to eq expected_response.to_json
				end
			end

			context 'when cards do not exist' do
				let(:scryfall_bolt) do
					{
						"name": "Lightning Bolt",
						"layout": "normal",
						"image_uris": {
							"normal": "normalimage"
						},
					  "mana_cost": "{R}",
					  "cmc": 1,
					  "type_line": "Instant",
					  "oracle_text": "Deal 3 damage to any target.",
					  "color_identity": ["R"],
					  "set": "LEB"
					}
				end
				let(:scryfall_bob) do
					{
						"name": "Dark Confidant",
						"layout": "normal",
						"image_uris": {
							"normal": "normalimage"
						},
					  "mana_cost": "{1}{B}",
					  "cmc": 2,
					  "type_line": "Create - Human Wizard",
					  "oracle_text": "At the beginning of your upkeep, reveal the top card of your library and put that card into your hand. You lose life equal to its converted mana cost.",
					  "color_identity": ["B"],
					  "power": 2,
					  "toughness": 1,
					  "set": "RAV"
					}
				end
				let!(:bolt_stub) do
					stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?exact=Lightning+Bolt&set=LEB")
						.to_return(status: 200, body: scryfall_bolt.to_json, headers: {})
				end
				let!(:bob_stub) do
					stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?exact=Dark+Confidant&set=RAV")
						.to_return(status: 200, body: scryfall_bob.to_json, headers: {})
				end

				it 'cards and cube cards are created' do
					subject
					expect(response.status).to eq 200
					expect(Card.all.count).to eq 2
					expect(Card.all.count).to eq 2
				end
			end

			context 'when cards exist but cube cards do not' do
				let!(:bolt_card) { create :card, name: 'Lightning Bolt', default_set: 'LEB' }
				let!(:bob_card) { create :card, name: 'Dark Confidant', default_set: 'RAV' }

				it 'only cube cards are created' do
					subject
					expect(response.status).to eq 200
					expect(Card.all.count).to eq 2
					expect(Card.all.count).to eq 2
				end

				context 'when cube cards exist' do
					let!(:bolt_cube_card) { create :cube_card, cube_id: cube.id, card_id: bolt_card.id }
					let!(:bob_cube_card) { create :cube_card, cube_id: cube.id, card_id: bob_card.id }
					let!(:bolt_update_stub) do
						stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?exact=Lightning+Bolt&set=3ED")
							.to_return(status: 200, body: scryfall_bolt_update.to_json, headers: {})
					end
					let(:scryfall_bolt_update) do
						{
							"name": "Lightning Bolt",
							"layout": "normal",
							"image_uris": {
								"normal": "updatedimage"
							},
						  "mana_cost": "{R}",
						  "cmc": 1,
						  "type_line": "Instant",
						  "oracle_text": "Deal 3 damage to any target.",
						  "color_identity": ["R"],
						  "set": "3ED"
						}
					end
					let(:bolt) do
						{
							:id => bolt_cube_card.id,
							:name => 'Lightning Bolt',
							:set => '3ED',
							:count => 1,
							:custom_cmc => 2,
							:custom_color_identity => 'G'
						}
					end
					let(:bob) do
						{
							:id => bob_cube_card.id,
							:name => 'Dark Confidant',
							:set => 'RAV',
							:count => 1,
							:soft_delete => true						}
					end

					it 'cube cards are updated' do
						subject
						expect(response.status).to eq 200
						bolt_cc = CubeCard.find(bolt_cube_card.id)
						expect(bolt_cc.custom_set).to eq bolt[:set]
						expect(bolt_cc.custom_cmc).to eq bolt[:custom_cmc]
						expect(bolt_cc.custom_color_identity).to eq bolt[:custom_color_identity]
						expect(CubeCard.find(bob_cube_card.id).soft_delete).to eq true
					end
				end
			end
		end
	end
end