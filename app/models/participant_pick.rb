class ParticipantPick < ApplicationRecord
	belongs_to :draft_participant
	belongs_to :card
	delegate :draft, :to => :draft_participant
	validate :availability

	private

	def availability
		draft.draft_participants.each do |participant|
			unless participant.participant_picks.select { |pick| pick.cube_card_id == cube_card_id }.empty?
				errors.add(:cube_card_id, 'Card Is Not Available')
			end
		end
	end
end