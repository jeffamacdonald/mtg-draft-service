require 'rails_helper'

RSpec.describe CardSanitizer do
	describe '.sanitize_card' do
		subject { described_class.sanitize_card(card_data, name) }

		context 'when card is default' do
			let(:card_data) do
				{
					:name => name,
					:layout => 'normal',
					:mana_cost => '{R}',
					:cmc => 1,
					:type_line => 'Instant',
					:oracle_text => 'Deal 3 damage to any target.',
					:color_identity => ['R'],
					:set => 'LEB',
					:image_uris => {
						:normal => 'normal_image.png'
					}
				}
			end
			let(:name) { 'Lightning Bolt' }
			let(:expected_response) do
				{
					:name => name,
					:layout => 'normal',
					:mana_cost => '{R}',
					:cmc => 1,
					:type_line => 'Instant',
					:oracle_text => 'Deal 3 damage to any target.',
					:color_identity => ['R'],
					:set => 'LEB',
					:image_uri => 'normal_image.png'
				}
			end

			it 'returns expected_response' do
				expect(subject).to eq expected_response
			end
		end

		context 'when card is split' do
			let(:card_data) do
				{
					:name => name,
					:layout => 'split',
					:image_uris => {
						:normal => 'normal_image.png'
					},
					:card_faces => [{
						:name => 'fire',
						:mana_cost => '{1}{R}',
						:oracle_text => 'Deal two damage split'
					}, {
						:name => 'ice',
						:mana_cost => '{1}{U}',
						:oracle_text => 'tap/untap something and draw'
					}]
				}
			end
			let(:name) { 'Fire // Ice' }
			let(:expected_response) do
				{
					:name => name,
					:layout => 'split',
					:cmc => 2,
					:oracle_text => "#{card_data[:card_faces][0][:oracle_text]}\n#{card_data[:card_faces][1][:oracle_text]}",
					:image_uri => 'normal_image.png'
				}
			end

			it 'returns expected_response' do
				expect(subject).to eq expected_response
			end
		end

		context 'when card is transform' do
			let(:card_data) do
				{
					:name => name + ' // Ormendahl, Profane Prince',
					:layout => 'transform',
					:card_faces => [{
						:name => 'Westvale Abbey',
						:oracle_text => 'Tap add mana make dudes sac dudes',
						:mana_cost => '',
						:colors => [],
						:type_line => 'Legendary Land',
						:image_uris => {
							:normal => 'normal_front_image.png'
						}
					}, {
						:name => 'Ormendahl, Profane Prince',
						:oracle_text => 'flying trample lifelink haste',
						:mana_cost => '',
						:colors => ['B'],
						:type_line => 'Legendary Creature',
						:image_uris => {
							:normal => 'normal_back_image.png'
						}
					}]
				}
			end
			let(:name) { 'Westvale Abbey' }
			let(:expected_response) do
				{
					:name => name,
					:layout => 'transform',
					:mana_cost => '',
					:cmc => 0,
					:type_line => 'Legendary Land',
					:oracle_text => "#{card_data[:card_faces][0][:oracle_text]}\n#{card_data[:card_faces][1][:oracle_text]}",
					:color_identity => [],
					:image_uri => 'normal_front_image.png'
				}
			end

			it 'returns expected_response' do
				expect(subject).to eq expected_response
			end
		end

		context 'when card is adventure' do
			let(:card_data) do
				{
					:name => name + ' // Petty Theft',
					:layout => 'adventure',
					:image_uris => {
						:normal => 'normal_image.png'
					},
					:card_faces => [{
						:name => name,
						:mana_cost => '{1}{U}{U}',
						:oracle_text => 'flying flash'
					}, {
						:name => 'Petty Theft',
						:mana_cost => '{1}{U}',
						:oracle_text => 'bounce something'
					}]
				}
			end
			let(:name) { 'Brazen Borrower' }
			let(:expected_response) do
				{
					:name => name,
					:layout => 'adventure',
					:cmc => 2,
					:oracle_text => "#{card_data[:card_faces][0][:oracle_text]}\n#{card_data[:card_faces][1][:oracle_text]}",
					:image_uri => 'normal_image.png'
				}
			end

			it 'returns expected_response' do
				expect(subject).to eq expected_response
			end
		end

		context 'when card is flip' do
			let(:card_data) do
				{
					:name => name + " // Erayo's Essence",
					:layout => 'flip',
					:image_uris => {
						:normal => 'normal_image.png'
					},
					:card_faces => [{
						:name => name,
						:oracle_text => 'flying',
						:type_line => 'Creature - Wizard'
					}, {
						:name => "Erayo's Essence",
						:oracle_text => 'counter stuff',
						:type_line => 'Legendary Enchantment'
					}]
				}
			end
			let(:name) { 'Erayo, Soratami Ascendant' }
			let(:expected_response) do
				{
					:name => name,
					:layout => 'flip',
					:type_line => 'Creature - Wizard',
					:oracle_text => "#{card_data[:card_faces][0][:oracle_text]}\n#{card_data[:card_faces][1][:oracle_text]}",
					:image_uri => 'normal_image.png'
				}
			end

			it 'returns expected_response' do
				expect(subject).to eq expected_response
			end
		end
	end
end