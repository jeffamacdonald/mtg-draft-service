require 'rails_helper'

RSpec.describe Card do
	describe '.get_cards_by_cube_list' do
		let(:name1) { 'name1' }
		let(:name2) { 'name2' }
		let!(:card1) { create :card, name: name1 }
		let!(:card2) { create :card, name: name2 }
		let(:cube_list) do
			[{
				:name => name1
			}, {
				:name => name2
			}, {
				:name => 'name3'
			}]
		end

		subject { described_class.get_cards_by_cube_list(cube_list) }

		it 'returns cards in list' do
			expect(subject.to_a).to eq [card1,card2]
		end
	end

	describe '.create_card_from_hash' do
		let(:name) { 'Lightning Bolt' }
		let(:mana_cost) { '{R}' }
		let(:cmc) { 1 }
		let(:oracle_text) { 'Deal 3 damage to any target.' }
		let(:layout) { 'normal' }
		let(:image_uri) { 'www.lightningbolt.png' }
		let(:set) { 'LEB' }
		let(:type_line) { 'Instant' }
		let(:color_identity) { ['R'] }
		let(:card_hash) do
			{
				:name => name,
				:mana_cost => mana_cost,
				:cmc => cmc,
				:oracle_text => oracle_text,
				:layout => layout,
				:image_uri => image_uri,
				:set => set,
				:type_line => type_line,
				:color_identity => color_identity
			}
		end

		subject { described_class.create_card_from_hash(card_hash) }

		it 'creates card with expected values' do
			subject
			card = Card.find_by(name: name)
			expect(card.cost).to eq mana_cost
			expect(card.cmc).to eq cmc
			expect(card.card_text).to eq oracle_text
			expect(card.layout).to eq layout
			expect(card.default_image).to eq image_uri
			expect(card.default_set).to eq set
			expect(card.type_line).to eq type_line
			expect(card.color_identity).to eq color_identity.join
			expect(card.power).to be_nil
			expect(card.toughness).to be_nil
		end

		context 'when color identity is blank' do
			let(:color_identity) { [] }
			it 'creates card with color identity as C' do
				subject
				expect(Card.find_by(name: name).color_identity).to eq 'C'
			end
		end

		context 'when type_line includes land' do
			let(:type_line) { 'Legendary Land' }
			it 'creates card with color identity as C' do
				subject
				expect(Card.find_by(name: name).color_identity).to eq 'C'
			end
		end
	end
end