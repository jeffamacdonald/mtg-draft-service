require 'rails_helper'

RSpec.describe Draft do
	describe '#validations' do
		let(:draft) { create :draft, status: status }

		subject { draft }

		context 'when status is not valid' do
			let(:status) { 'BAD_STATUS' }

			it 'throws validation error' do
				expect{subject}.to raise_error ActiveRecord::RecordInvalid
			end
		end

		context 'when status is valid' do
			Draft::STATUSES.each do |s|
				context "#{s}" do
					let(:status) { s }

					it 'creates the draft' do
						expect(subject).to eq draft
					end
				end
			end
		end
	end

	describe '#create_participants' do
		let(:user1) { create :user }
		let(:user2) { create :user }
		let(:user_ids) { [user1.id, user2.id] }
		let(:draft) { create :draft }

		subject { draft.create_participants(user_ids) }

		context 'when all users exist' do
			it 'participants are created for each user' do
				subject
				participants = DraftParticipant.all
				expect(participants.count).to eq 2
				expect(participants.find { |p| p[:draft_id] == draft.id }).to be_present
				expect(participants.find { |p| p[:user_id] == user1.id }).to be_present
				expect(participants.find { |p| p[:display_name] == user1.username }).to be_present
				expect(participants.find { |p| p[:draft_position] == 1 }).to be_present
				expect(participants.find { |p| p[:draft_position] == 2 }).to be_present
			end
		end

		context 'when a user does not exist' do
			let(:user_ids) { [user1.id, user2.id, 100] }

			it 'raises RecordNotFound exception' do
				expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
			end
		end
	end

	describe '#display_draft' do
		let(:draft) { create :draft }
		let!(:draft_participant_1) { create :draft_participant, draft_id: draft.id, draft_position: 1 }
		let!(:draft_participant_2) { create :draft_participant, draft_id: draft.id, draft_position: 2 }
		let(:expected_response) { draft.attributes.merge({:active_participant => draft_participant_1}) }

		subject { draft.display_draft }

		it 'displays draft attributes with active participant' do
			expect(subject).to eq expected_response
		end
	end

	describe '#display_card_pool' do
		let!(:cube) { create :cube }
		let!(:cube_card_1) { create :cube_card, cube_id: cube.id, custom_color_identity: 'R' }
		let!(:cube_card_2) { create :cube_card, cube_id: cube.id, custom_color_identity: 'G' }
		let!(:cube_card_3) { create :cube_card, cube_id: cube.id, custom_color_identity: 'U' }
		let!(:draft) { create :draft, cube_id: cube.id }
		let!(:draft_participant) { create :draft_participant, draft_id: draft.id }
		let!(:participant_pick) { create :participant_pick, draft_participant_id: draft_participant.id, cube_card_id: cube_card_1.id }

		let(:expected_response) do
			{
				"R" => [cube_card_1.attributes.merge({:is_drafted => true})],
				"G" => [cube_card_2.attributes.merge({:is_drafted => false})],
				"U" => [cube_card_3.attributes.merge({:is_drafted => false})]
			}
		end

		subject { draft.display_card_pool }

		it 'returns expected response' do
			expect(subject).to eq expected_response
		end
	end

	describe '#active_participant' do
		let(:draft) { create :draft }
		let!(:draft_participant_1) { create :draft_participant, draft_id: draft.id, draft_position: 1 }
		let!(:draft_participant_2) { create :draft_participant, draft_id: draft.id, draft_position: 2 }
		let!(:draft_participant_3) { create :draft_participant, draft_id: draft.id, draft_position: 3 }

		subject { draft.active_participant }

		context 'when no picks have been made' do
			it 'draft position one is active drafter' do
				expect(subject).to eq draft_participant_1
			end
		end

		context 'when picks have been made' do
			let!(:participant_pick_1) do
				create :participant_pick,
					draft_participant_id: draft_participant_1.id,
					round: 1,
					pick_number: 1
			end
			let!(:participant_pick_2) do
				create :participant_pick,
					draft_participant_id: draft_participant_2.id,
					round: 1,
					pick_number: 2
			end
			let!(:participant_pick_3) do
				create :participant_pick,
					draft_participant_id: draft_participant_3.id,
					round: 1,
					pick_number: 3
			end

			it 'drafter with pick_number 4 as next pick is active' do
				expect(subject).to eq draft_participant_3
			end

			context 'multiple drafters are skipped' do
				before do
					draft_participant_3.skipped = true
					draft_participant_3.save
					draft_participant_2.skipped = true
					draft_participant_2.save
				end

				it 'active drafter is the first that is not skipped' do
					expect(subject).to eq draft_participant_1
				end
			end
		end
	end
end