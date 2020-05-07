require 'rails_helper'

shared_examples 'CubeHelper' do
	describe '#existing_cards_array' do
		let!(:card1) { create :card }
		let!(:card2) { create :card }
		let(:cards) { Card.all }
		let(:card_array) { [card1,card2] }

		before do
			allow(Card).to receive(:get_cards_by_cube_list).and_return(cards)
		end

		subject { described_class.new.existing_cards_array }

		it 'returns expected array' do
			expect(subject).to eq card_array
		end
	end

	describe '#new_card_hashes' do
		let!(:card1) { create :card, name: 'Lightning Bolt' }
		let!(:card2) { create :card }
		let(:card_array) { [card1,card2] }
		let(:cube_list) do
			[{
				:name => "Lightning Bolt"
			}, {
				:name => "Dark Confidant"
			}]
		end
		let(:expected_list) do
			[{
				:name => "Dark Confidant"
			}]
		end

		subject { @class_object.new_card_hashes }

		before do
			@class_object = described_class.new
			@class_object.instance_variable_set(:@cube_list, cube_list)
			allow(@class_object).to receive(:existing_cards_array).and_return(card_array)
		end

		it 'returns expected card list' do
			expect(subject).to eq expected_list
		end
	end

	describe '#get_new_enriched_cards' do
		let(:card_list) do
			[{
				:name => "Lightning Bolt",
			}, {
				:name => "Dark Confidant"
			}]
		end
		let(:errors) do
			[{
				:name => "Counterspall"
			}]
		end
		let(:card_enricher_response) do
			{
				:errors => errors,
				:card_list => card_list
			}
		end
		let(:new_card_hashes_response) do
			[{
				:name => "Lightning Bolt"
			}, {
				:name => "Dark Confidant"
			}, {
				:name => "Counterspall"
			}]
		end
		let(:expected_response) do
			[errors, card_list]
		end

		subject { described_class.new.get_new_enriched_cards }

		before do
			allow_any_instance_of(described_class).to receive(:new_card_hashes)
				.and_return(new_card_hashes_response)
			allow(CardEnricher).to receive(:get_enriched_list)
				.with(new_card_hashes_response).and_return(card_enricher_response)
		end

		it 'returns expected errors and card list' do
			expect(subject).to eq expected_response
		end
	end

	describe '#create_new_cards' do
		let!(:card1) { create :card, name: "existing" }
		let(:cards) { Card.where(name: "existing") }
		let(:card2) { create :card, name: "Lightning Bolt" }
		let(:card3) { create :card, name: "Dark Confidant" }
		let(:bolt) do
			{
				:name => "Lightning Bolt"
			}
		end
		let(:bob) do
			{
				:name => "Dark Confidant"
			}
		end
		let(:enriched_cards) do
			[bolt, bob]
		end
		let(:expected_response) do
			[card1, card2, card3]
		end

		subject { @class_object.create_new_cards(enriched_cards) }

		before do
			@class_object = described_class.new
			allow(Card).to receive(:get_cards_by_cube_list).and_return(cards)
			allow(Card).to receive(:create_card_from_hash).with(bolt).and_return(card2)
			allow(Card).to receive(:create_card_from_hash).with(bob).and_return(card3)
		end

		it 'creates cards and adds them to existing cards array' do
			subject
			expect(@class_object.existing_cards_array).to eq expected_response
		end
 	end

	describe '#create_cube_cards_and_return_errors' do
		let(:cube) { create :cube }
		let(:bolt) do
			{
				:name => "Lightning Bolt",
				:id => "1"
			}
		end
		let(:bob) do
			{
				:name => "Dark Confidant",
				:id => "1"
			}
		end
		let(:card_hashes) do
			[bolt, bob]
		end

		subject { described_class.new.create_cube_cards_and_return_errors(cube) }

		before do
			allow_any_instance_of(described_class).to receive(:merged_cards_and_cube_list)
				.and_return(card_hashes)
		end

		it 'creates a cube card for each card hash and returns empty array' do
			expect(CubeCard).to receive(:create_cube_card_from_hash).with(cube, bolt)
			expect(CubeCard).to receive(:create_cube_card_from_hash).with(cube, bob)
			expect(subject).to eq []
		end

		context 'when cube card raises creation error' do
			let(:error1) {"error1"}
			let(:error2) {"error2"}

			it 'returns errors' do
				expect(CubeCard).to receive(:create_cube_card_from_hash).with(cube, bolt)
					.and_raise(CubeCard::CreationError, error1)
				expect(CubeCard).to receive(:create_cube_card_from_hash).with(cube, bob)
					.and_raise(CubeCard::CreationError, error2)
				expect(subject).to eq [error1, error2]
			end
		end
	end

	describe '#cards_and_cube_list_array' do
		let!(:card1) { create :card }
		let!(:card2) { create :card }
		let(:card_array) { [card1,card2] }
		let(:cube_list) do
			[{
				:name => "Lightning Bolt"
			}, {
				:name => "Dark Confidant"
			}]
		end
		let(:expected_response) do
			cube_list + [card1.attributes.symbolize_keys, card2.attributes.symbolize_keys]
		end

		subject { @class_object.cards_and_cube_list_array }

		before do
			@class_object = described_class.new
			@class_object.instance_variable_set(:@cube_list, cube_list)
			allow(@class_object).to receive(:existing_cards_array).and_return(card_array)
		end

		it 'returns expected array' do
			expect(subject).to eq expected_response
		end
	end

	describe '#merged_cards_and_cube_list' do
		let(:cube_list) do
			[{
				:name => "Lightning Bolt",
				:count => 1
			}, {
				:name => "Dark Confidant",
				:count => 1
			}]
		end
		let(:card_list) do
			[{
				:name => "Lightning Bolt",
				:id => 1
			}, {
				:name => "Dark Confidant",
				:id => 2
			}]
		end
		let(:merged_list) { cube_list + card_list }
		let(:expected_response) do
			[{
				:name => "Lightning Bolt",
				:count => 1,
				:id => 1
			}, {
				:name => "Dark Confidant",
				:count => 1,
				:id => 2
			}]
		end

		subject { described_class.new.merged_cards_and_cube_list }

		before do
			allow_any_instance_of(described_class).to receive(:cards_and_cube_list_array)
				.and_return(merged_list)
		end

		it 'returns expected array' do
			expect(subject).to eq expected_response
		end
	end
end