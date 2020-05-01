require 'rails_helper'

RSpec.describe Cube do
	let(:cube) { create :cube}

	describe '#create_cube_cards' do
		let(:card_name) {"Lightning Bolt"}
		let(:layout) {"something"}
		let(:image) {"httpblah2"}
		let(:mana_cost) {"{R}"}
		let(:cmc) {1}
		let(:type_line) {"Instant"}
		let(:color_identity) {["R"]}
		let(:card_text) {"Deal 3 damage to any target."}
		let(:set) {"LEB"}
		let(:card_1) do
			{
				:name => card_name,
			  :set => set,
			  :count => 1
			}
		end
		let(:card_2) do
			{
				:name => "Watchwolf",
			  :set => "RAV",
			  :count => 1
			}
		end
		let(:card_3) do
			{
				:name => "Tundra",
			  :set => "LEB",
			  :count => 1
			}
		end
		let(:card_4) do
			{
				:name => "Ensnaring Bridge",
			  :set => "SGH",
			  :count => 1
			}
		end
		let(:card_list) do
			[card_1, card_2, card_3, card_4]
		end
		let(:bolt_status) { 200 }
		let(:bolt_response) do
			{
				"name": card_name,
				"layout": layout,
				"image_uris": {
			    "small": "httpblahsmall",
			    "normal": image
			  },
			  "mana_cost": mana_cost,
			  "cmc": cmc,
			  "type_line": type_line,
			  "oracle_text": card_text,
			  "color_identity": color_identity,
			  "set": set
			}
		end
		let(:watchwolf_response) do
			{
				"name": "Watchwolf",
				"layout": "something",
				"image_uris": {
			    "small": "httpblah",
			    "normal": "httpblah"
			  },
			  "mana_cost": "{G}{W}",
			  "cmc": 2,
			  "type_line": "Create - Wolf",
			  "oracle_text": "",
			  "color_identity": ["G","W"],
			  "power": 3,
			  "toughness": 3,
			  "set": "RAV"
			}
		end
		let(:tundra_response) do
			{
				"name": "Tundra",
				"layout": "normal",
				"image_uris": {
			    "small": "httpblahsmall",
			    "normal": "something"
			  },
			  "mana_cost": "",
			  "cmc": 0,
			  "type_line": "Land",
			  "oracle_text": "something",
			  "color_identity": "UW",
			  "set": "LEB"
			}
		end
		let(:bridge_response) do
			{
				"name": "Ensnaring Bridge",
				"layout": "normal",
				"image_uris": {
			    "small": "httpblahsmall",
			    "normal": "image"
			  },
			  "mana_cost": "{3}",
			  "cmc": 3,
			  "type_line": "Artifact",
			  "oracle_text": "card_text",
			  "color_identity": "",
			  "set": "SGH"
			}
		end

		before do
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Lightning+Bolt&set=LEB")
				.to_return(status: bolt_status, body: bolt_response.to_json, headers: {})
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Watchwolf&set=RAV")
				.to_return(status: 200, body: watchwolf_response.to_json, headers: {})
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Tundra&set=LEB")
				.to_return(status: 200, body: tundra_response.to_json, headers: {})
			stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=Ensnaring+Bridge&set=SGH")
				.to_return(status: 200, body: bridge_response.to_json, headers: {})
		end

		subject { cube.create_cube_cards(card_list) }

		context 'no cards exist yet' do
			it 'creates card records' do
				subject
				expect(Card.all.count).to eq 4
				lightning_bolt = Card.find_by(name: card_name)
				expect(lightning_bolt.layout).to eq layout
				expect(lightning_bolt.default_image).to eq image
				expect(lightning_bolt.cost).to eq mana_cost
				expect(lightning_bolt.converted_mana_cost).to eq cmc
				expect(lightning_bolt.type_line).to eq type_line
				expect(lightning_bolt.card_text).to eq card_text
				expect(lightning_bolt.color_identity).to eq color_identity.join
				expect(lightning_bolt.default_set).to eq set
				expect(Card.find_by(name: "Tundra").color_identity).to eq "C"
				expect(Card.find_by(name: "Ensnaring Bridge").color_identity).to eq "C"
			end

			it 'creates cube card records' do
				subject
				expect(CubeCard.all.count).to eq 4
				card_id = Card.find_by(name: card_name).id
				cube_card_ref = CubeCard.find_by(card_id: card_id)
				expect(cube_card_ref.cube_id).to eq cube.id
				expect(cube_card_ref.count).to eq 1
				expect(cube_card_ref.custom_set).to eq set
				expect(cube_card_ref.custom_color_identity).to eq color_identity.join
				expect(cube_card_ref.custom_image).to eq image
				expect(cube_card_ref.soft_delete).to eq false
			end

			context 'scryfall cannot find a card' do
				let(:bolt_status) { 404 }

				it 'raises error' do
					expect{subject}.to raise_error(Cube::CreationError)
				end
			end
		end

		context 'card already exists' do
			let!(:lightning_bolt) { create :card, name: card_name }

			it 'does not create a new card record' do
				subject
				expect(Card.all.count).to eq 4
			end

			it 'creates cube card records' do
				subject
				expect(CubeCard.all.count).to eq 4
			end
		end

		context 'card already exists with different default set' do
			let!(:lightning_bolt) { create :card, name: card_name, default_set: "M10" }
			let(:custom_image) {"http://custom.image"}
			let(:scryfall_response) do
				{
					name: card_name,
					image_uris: {
						normal: custom_image
					}
				}
			end
			let!(:scryfall_stub) do
				stub_request(:get, "#{Clients::Scryfall::BASE_URL}/cards/named?fuzzy=#{card_name}&set=#{set}")
					.to_return(status: 200, body: scryfall_response.to_json, headers: {})
			end

			it 'calls scryfall to get image' do
				subject
				expect(scryfall_stub).to have_been_requested
				cube_card_ref = CubeCard.find_by(card_id: lightning_bolt.id)
				expect(cube_card_ref.custom_image).to eq custom_image
			end

			context 'cube card already exists with custom image and set' do
				let!(:cube_2) { create :cube }

				let(:custom_image_2) {"http://LEB.bolt"}
				let!(:cube_2_card) do
					create :cube_card,
						cube_id: cube_2.id,
						card_id: lightning_bolt.id,
						custom_set: set,
						custom_image: custom_image_2
				end

				it 'creates cube card with custom set and image from existing card' do
					subject
					cube_card_ref = CubeCard.find_by(cube_id: cube.id, card_id: lightning_bolt.id)
					expect(cube_card_ref.custom_set).to eq set
					expect(cube_card_ref.custom_image).to eq custom_image_2
				end
			end
		end
	end

	describe '#display_cube' do
		let!(:cube) { create :cube }
		let!(:card_1) { create :card, converted_mana_cost: 4, color_identity: 'B' }
		let!(:card_2) { create :card, converted_mana_cost: 0, color_identity: 'C' }
		let!(:card_3) { create :card, converted_mana_cost: 3, color_identity: 'C' }
		let!(:card_4) { create :card, converted_mana_cost: 2, color_identity: 'C' }
		let!(:card_5) { create :card, converted_mana_cost: 5, color_identity: 'UG' }
		let!(:card_6) { create :card, converted_mana_cost: 4, color_identity: 'UG' }
		let!(:cube_card_1) { create :cube_card, cube_id: cube.id, card_id: card_1.id, custom_color_identity: 'B', soft_delete: true }
		let!(:cube_card_2) { create :cube_card, cube_id: cube.id, card_id: card_2.id, custom_color_identity: 'C' }
		let!(:cube_card_3) { create :cube_card, cube_id: cube.id, card_id: card_3.id, custom_color_identity: 'C' }
		let!(:cube_card_4) { create :cube_card, cube_id: cube.id, card_id: card_4.id, custom_color_identity: 'R' }
		let!(:cube_card_5) { create :cube_card, cube_id: cube.id, card_id: card_5.id, custom_color_identity: 'UG' }
		let!(:cube_card_6) { create :cube_card, cube_id: cube.id, card_id: card_6.id, custom_color_identity: 'UG' }
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

		subject { cube.display_cube }

		it 'returns active, sorted, chunked, and hashed' do
			expect(subject).to eq expected_response
		end
	end
end