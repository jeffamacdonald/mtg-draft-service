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
		let(:enriched_card_1) do
			{
				"name": card_name,
				"layout": layout,
				"image_uris": {
			    "small": "httpblah",
			    "normal": image
			  },
			  "mana_cost": mana_cost,
			  "cmc": cmc,
			  "type_line": type_line,
			  "oracle_text": card_text,
			  "color_identity": color_identity,
			  "set": set,
			  "count": 1
			}
		end
		let(:enriched_card_2) do
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
			  "set": "rav",
			  "count": 1
			}
		end
		let(:enriched_list) do
			[enriched_card_1, enriched_card_2]
		end

		subject { cube.create_cube_cards(enriched_list) }

		context 'no cards exist yet' do
			it 'creates card records' do
				subject
				expect(Card.all.count).to eq 2
				lightning_bolt = Card.find_by(name: card_name)
				expect(lightning_bolt.layout).to eq layout
				expect(lightning_bolt.default_image).to eq image
				expect(lightning_bolt.cost).to eq mana_cost
				expect(lightning_bolt.converted_mana_cost).to eq cmc
				expect(lightning_bolt.type_line).to eq type_line
				expect(lightning_bolt.card_text).to eq card_text
				expect(lightning_bolt.color_identity).to eq color_identity.join
				expect(lightning_bolt.default_set).to eq set
			end

			it 'creates cube card records' do
				subject
				expect(CubeCard.all.count).to eq 2
				card_id = Card.find_by(name: card_name).id
				cube_card_ref = CubeCard.find_by(card_id: card_id)
				expect(cube_card_ref.cube_id).to eq cube.id
				expect(cube_card_ref.count).to eq 1
				expect(cube_card_ref.custom_set).to eq set
				expect(cube_card_ref.custom_color_identity).to be_nil
				expect(cube_card_ref.custom_image).to be_nil
				expect(cube_card_ref.soft_delete).to be_nil
			end
		end

		context 'card already exists' do
			let!(:lightning_bolt) { create :card, name: card_name }

			it 'does not create a new card record' do
				subject
				expect(Card.all.count).to eq 2
			end

			it 'creates cube card records' do
				subject
				expect(CubeCard.all.count).to eq 2
			end
		end

		context 'card already exists with different default set' do
			let!(:lightning_bolt) { create :card, name: card_name, default_set: "M10" }
			let(:custom_image) {"http://custom.image"}
			let(:scryfall_response) do
				{
					name: card_name,
					img_uris: {
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
end