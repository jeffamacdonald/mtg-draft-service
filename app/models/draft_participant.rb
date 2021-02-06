class DraftParticipant < ApplicationRecord
	belongs_to :draft
	belongs_to :user
	has_many :participant_picks
	has_many :cards, :through => :participant_picks

	def pick_card(cube_card_id)
		round = next_pick_round
		pick_number = calculate_pick_number(round)
		ParticipantPick.create!(draft_participant_id: self.id, cube_card_id: cube_card_id,
			round: round, pick_number: pick_number)
		if self.skipped && draft.participant_picks.maximum(:pick_number) < next_pick_number
			self.skipped = false
			self.save!
		end
	end

	def next_pick_number
		calculate_pick_number(next_pick_round)
	end

	private

	def next_pick_round
		last_pick = participant_picks.last
		last_pick.nil? ? 1 : last_pick.round + 1
	end

	def calculate_pick_number(round)
		total_drafters = draft.draft_participants.count
		if round % 2 == 1
			((round-1) * total_drafters + draft_position)
		else
			round * total_drafters - draft_position + 1
		end
	end
end