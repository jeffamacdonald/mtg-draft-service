require 'rails_helper'

RSpec.describe DckParser do
	describe '#get_parsed_list' do
		let(:line1) { '1 [LEB:123] Lightning Bolt' }
		let(:line2) { '1 [RAV:321] Dark Confidant' }
		let(:file) do
			Tempfile.new(['test', '.dck']).tap do |f|
				f.puts line1
				f.puts line2
				f.close
			end
		end

		after do
			file.unlink
		end

		let(:expected_response) do
			[expected_array, expected_error]
		end

		subject { described_class.new(file.path).get_parsed_list }

		context 'when file is valid' do
			let(:expected_array) do
				[{
					:count => 1,
					:set => "LEB",
					:card_name => "Lightning Bolt"
				}, {
					:count => 1,
					:set => "RAV",
					:card_name => "Dark Confidant"
				}]
			end
			let(:expected_error) { [] }

			it 'raises no errors' do
				expect{subject}.to_not raise_error
			end

			it 'adds card hashes to array' do
				expect(subject).to eq expected_response
			end
		end

		context 'when one line has invalid count' do
			let(:card_name) {"Some Card"}
			let(:line1) { "0 [SET:123] #{card_name}" }
			let(:expected_array) do
				[{
					:count => 1,
					:set => "RAV",
					:card_name => "Dark Confidant"
				}]
			end
			let(:expected_error) do
				[{
					:error => "Count Invalid",
					:card_name => "#{card_name}"
				}]
			end

			it 'adds errors to the array' do
				expect(subject).to eq expected_response
			end

			context 'when two lines have invalid count' do
				let(:card_name2) { "Some Other Card" }
				let(:line2) { "A [SET:345] #{card_name2}"}
				let(:expected_array) { [] }
				let(:expected_error) do
					[{
						:error => "Count Invalid",
						:card_name => "#{card_name}"
					}, {
						:error => "Count Invalid",
						:card_name => "#{card_name2}"
					}]
				end

				it 'adds errors to the array' do
					expect(subject).to eq expected_response
				end
			end
		end

		context 'when one line has invalid set' do
			let(:card_name) {"Some Card"}
			let(:line1) { "1 [SE:123] #{card_name}" }
			let(:expected_array) do
				[{
					:count => 1,
					:set => "RAV",
					:card_name => "Dark Confidant"
				}]
			end
			let(:expected_error) do
				[{
					:error => "Set Invalid",
					:card_name => "#{card_name}"
				}]
			end

			it 'adds errors to the array' do
				expect(subject).to eq expected_response
			end
		end

		context 'when name is empty string' do
			let(:line1) { "1 [SET:123]  " }
			let(:expected_array) do
				[{
					:count => 1,
					:set => "RAV",
					:card_name => "Dark Confidant"
				}]
			end
			let(:expected_error) { [] }

			it 'does not get added to array' do
				expect(subject).to eq expected_response
			end
		end

		context 'when one line is malformed' do
			let(:line1) { "1[SET:123]Card" }
			let(:expected_error) { "Malformed File" }

			it 'raises error' do
				expect{subject}.to raise_error(DckParser::ParseError).with_message(expected_error)
			end
		end
	end
end