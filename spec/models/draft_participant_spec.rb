require 'rails_helper'

RSpec.describe DraftParticipant do
	describe '#pick_card' do
		let(:cube) { create :cube }
		let(:draft) { create :draft, cube_id: cube.id }
		let(:cube_card) { create :cube_card, cube_id: cube.id }
		let!(:participants) do
			14.times{ |i| create :draft_participant, draft_id: draft.id, draft_position: i+1 }
			DraftParticipant.all
		end

		subject { participants.first.pick_card(cube_card.id) }

		context 'when no cards are picked yet' do
			it 'picks card at round 1 pick 1' do
				subject
				pick = ParticipantPick.find_by(draft_participant_id: participants.first.id, cube_card_id: cube_card.id)
				expect(pick.round).to eq 1
				expect(pick.pick_number).to eq 1
			end
		end

		context 'when cards are previously picked' do
			let(:previous_cube_card) { create :cube_card, cube_id: cube.id }
			let!(:participant_pick) do
				create :participant_pick,
				draft_participant_id: participants.first.id,
				cube_card_id: previous_cube_card.id,
				round: 1,
				pick_number: 1
			end

			it 'picks card at round 2 pick 28' do
				subject
				pick = ParticipantPick.find_by(draft_participant_id: participants.first.id, cube_card_id: cube_card.id)
				expect(pick.round).to eq 2
				expect(pick.pick_number).to eq 28
			end

			context 'when participant is skipped' do
				before do
					participants.first.skipped = true
					participants.first.save
				end

				it 'after pick participant is no longer skipped' do
					subject
					expect(participants.first.skipped).to be false
				end

				context 'when participant is behind multiple picks' do
					let(:previous_cube_card_1) { create :cube_card, cube_id: cube.id }
					let(:previous_cube_card_2) { create :cube_card, cube_id: cube.id }
					let(:previous_cube_card_3) { create :cube_card, cube_id: cube.id }
					let!(:participant_pick_1) do
						create :participant_pick,
						draft_participant_id: participants.last.id,
						cube_card_id: previous_cube_card_1.id,
						round: 1,
						pick_number: 14
					end
					let!(:participant_pick_2) do
						create :participant_pick,
						draft_participant_id: participants.last.id,
						cube_card_id: previous_cube_card_2.id,
						round: 2,
						pick_number: 15
					end
					let!(:participant_pick_3) do
						create :participant_pick,
						draft_participant_id: participants.last.id,
						cube_card_id: previous_cube_card_3.id,
						round: 3,
						pick_number: 42
					end

					it 'after pick participant is still skipped' do
						subject
						expect(participants.first.skipped).to be true
					end
				end
			end
		end
	end

	describe '#next_pick_number' do
		let(:cube) { create :cube }
		let(:draft) { create :draft, cube_id: cube.id }
		let(:cube_card) { create :cube_card, cube_id: cube.id }
		let!(:participants) do
			10.times{ |i| create :draft_participant, draft_id: draft.id, draft_position: i+1 }
			DraftParticipant.all
		end

		subject { participants.last.next_pick_number }

		context 'when no cards are picked yet' do
			it 'next pick number is 10' do
				expect(subject).to eq 10
			end
		end

		context 'when cards are previously picked' do
			let(:previous_cube_card_1) { create :cube_card, cube_id: cube.id }
			let(:previous_cube_card_2) { create :cube_card, cube_id: cube.id }
			let(:previous_cube_card_3) { create :cube_card, cube_id: cube.id }
			let!(:participant_pick_1) do
				create :participant_pick,
				draft_participant_id: participants.last.id,
				cube_card_id: previous_cube_card_1.id,
				round: 1,
				pick_number: 10
			end
			let!(:participant_pick_2) do
				create :participant_pick,
				draft_participant_id: participants.last.id,
				cube_card_id: previous_cube_card_2.id,
				round: 2,
				pick_number: 11
			end
			let!(:participant_pick_3) do
				create :participant_pick,
				draft_participant_id: participants.last.id,
				cube_card_id: previous_cube_card_3.id,
				round: 3,
				pick_number: 30
			end

			it 'next pick number is 31' do
				expect(subject).to eq 31
			end
		end
	end
end