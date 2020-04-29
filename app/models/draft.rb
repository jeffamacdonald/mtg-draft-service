class Draft < ApplicationRecord
	belongs_to :cube
	has_many :draft_participants
	has_many :users, :through => :draft_participants

	def create_participants(user_ids)
		users = User.find(user_ids)
		draft_participant_hashes = users.shuffle.map.with_index do |user, idx|
			{
				:draft_id => self.id,
				:user_id => user.id,
				:display_name => user.username,
				:draft_position => idx + 1,
				:created_at => Time.now,
				:updated_at => Time.now
			}
		end
		DraftParticipant.insert_all(draft_participant_hashes)
	end
end