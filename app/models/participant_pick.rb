class ParticipantPick < ApplicationRecord
	belongs_to :draft_participant
	belongs_to :card

end