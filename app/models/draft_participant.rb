class DraftParticipant < ApplicationRecord
	belongs_to :draft
	belongs_to :user
	has_many :participant_picks
	has_many :cards, :through => :participant_picks

end