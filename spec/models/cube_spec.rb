require 'rails_helper'
require_rel '../helpers/cube_helper_spec'

RSpec.describe Cube do
	it_behaves_like "CubeHelper"

	describe '#setup_cube_from_list' do
		let(:cube) { create :cube }
		let(:cube_list) do
			[{
				:name => "Lightning Bolt",
				:count => 1,
				:custom_set => "3ED"
			}, {
				:name => "Dark Confidant",
				:count => 1
			}]
		end
		let(:bolt) do
			{
				"name": "Lightning Bolt",
				"layout": "normal",
				"image_uri": "normalimage",
			  "mana_cost": "{R}",
			  "cmc": 1,
			  "type_line": "Instant",
			  "oracle_text": "Deal 3 damage to any target.",
			  "color_identity": ["R"],
			  "set": "LEB",
			  "count": 1,
			  "custom_set": "3ED"
			}
		end
		let(:bob) do
			{
				"name": "Dark Confidant",
				"layout": "normal",
				"image_uri": "httpblah",
			  "mana_cost": "{1}{B}",
			  "cmc": 2,
			  "type_line": "Create - Human Wizard",
			  "oracle_text": "At the beginning of your upkeep, reveal the top card of your library and put that card into your hand. You lose life equal to its converted mana cost.",
			  "color_identity": ["B"],
			  "power": 2,
			  "toughness": 1,
			  "set": "RAV",
			  "count": 1
			}
		end
		let(:enriched_cards) { [bolt, bob] }
		let(:errors) { [] }
		let(:get_new_enriched_cards_response) { [errors, enriched_cards] }


		before do
			allow(cube).to receive(:get_new_enriched_cards).and_return(get_new_enriched_cards_response)
		end

		subject { cube.setup_cube_from_list(cube_list) }

		context 'scryfall returned no errors on bulk call' do
			it 'creates cards and cube cards in list' do
				expect(cube).to receive(:create_new_cards).with(enriched_cards)
				expect(cube).to receive(:create_cube_cards_and_return_errors).with(cube)
					.and_return([])
				subject
			end

			context 'scryfall returned errors on create cube cards' do
				let(:errors) { ["error"] }

				before do
					allow(cube).to receive(:create_new_cards).with(enriched_cards)
					allow(cube).to receive(:create_cube_cards_and_return_errors).with(cube)
						.and_return(errors)
				end

				it 'raises error' do
					expect{subject}.to raise_error(Cube::CreationError)
				end
			end
		end

		context 'scryfall returned errors' do
			let(:errors) do
				[{
					:name => "Dark Confidant"
				}]
			end
			let(:enriched_cards) { [bolt] }

			it 'raises error' do
				expect{subject}.to raise_error(Cube::CreationError)
			end
		end
	end

	describe '#display_cube' do
		let!(:cube) { create :cube }
		let!(:card_1) { create :card, cmc: 4, color_identity: 'B' }
		let!(:card_2) { create :card, cmc: 0, color_identity: 'C' }
		let!(:card_3) { create :card, cmc: 3, color_identity: 'C' }
		let!(:card_4) { create :card, cmc: 2, color_identity: 'C' }
		let!(:card_5) { create :card, cmc: 5, color_identity: 'UG' }
		let!(:card_6) { create :card, cmc: 4, color_identity: 'UG' }
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