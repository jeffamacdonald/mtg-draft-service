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

	describe '#update_cube' do
		let(:cube) { create :cube }

		subject { cube.update_cube(params) }

		context 'when name is present' do
			let(:name) { 'new_name' }
			let(:params) do
				{:name => name}
			end

			it 'cube name is updated' do
				subject
				expect(cube.name).to eq name
			end
		end

		context 'when cube list is present' do
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
			let(:enriched_bolt) do
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
			let(:enriched_bob) do
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
			let(:cube_list) do
				[bolt, bob]
			end
			let(:params) do
				{:cube_list => cube_list}
			end

			it 'adds new cards and cube_cards' do
				expect(CardEnricher).to receive(:get_enriched_card).with(bolt)
					.and_return(enriched_bolt)
				expect(CardEnricher).to receive(:get_enriched_card).with(bob)
					.and_return(enriched_bob)
				subject
				expect(Card.all.count).to be 2
				expect(CubeCard.all.count).to be 2
			end

			context 'when card enricher returns an error' do
				let(:enriched_bolt) do
					{
						:error => {
							:name => 'Lightning Bolt',
							:message => 'Card Not Found'
						}
					}
				end

				it 'raises error' do
					allow(CardEnricher).to receive(:get_enriched_card).with(bolt)
						.and_return(enriched_bolt)
					allow(CardEnricher).to receive(:get_enriched_card).with(bob)
						.and_return(enriched_bob)
					expect{subject}.to raise_error(Cube::CreationError)
				end
			end

			context 'when cards exist but cube cards do not' do
				let!(:bolt_card) { create :card, name: 'Lightning Bolt', default_set: 'LEB' }
				let!(:bob_card) { create :card, name: 'Dark Confidant', default_set: 'RAV' }

				it 'adds new cube cards' do
					subject
					expect(Card.all.count).to be 2
					expect(CubeCard.all.count).to be 2
				end

				context 'when cube cards already exist' do
					let!(:bolt_cube_card) { create :cube_card, cube_id: cube.id, card_id: bolt_card.id }
					let!(:bolt_cube_card_2) { create :cube_card, card_id: bolt_card.id, custom_set: custom_set, custom_image: custom_image }
					let!(:bob_cube_card) { create :cube_card, cube_id: cube.id, card_id: bob_card.id, custom_set: 'RAV', custom_color_identity: 'B', custom_cmc: 2 }
					let(:count) { 2 }
					let(:custom_set) { '3ED' }
					let(:custom_image) { 'new_image' }
					let(:custom_color_identity) { 'C' }
					let(:custom_cmc) { 2 }
					let(:bolt) do
						{
							:id => bolt_cube_card.id,
							:count => count,
							:set => custom_set,
							:custom_color_identity => custom_color_identity,
							:custom_cmc => custom_cmc
						}
					end
					let(:bob) do
						{
							:id => bob_cube_card.id,
							:soft_delete => true
						}
					end

					it 'updates existing cards' do
						subject
						card = CubeCard.find(bolt_cube_card.id)
						expect(card.count).to eq 2
						expect(card.custom_set).to eq custom_set
						expect(card.custom_image).to eq custom_image
						expect(card.custom_color_identity).to eq custom_color_identity
						expect(card.custom_cmc).to eq custom_cmc
						expect(CubeCard.find(bob_cube_card.id).soft_delete).to eq true
					end
				end
			end
		end
	end

	describe '#display_cube' do
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