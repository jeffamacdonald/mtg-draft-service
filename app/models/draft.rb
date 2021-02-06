class Draft < ApplicationRecord
	STATUSES = %w[ACTIVE INACTIVE PENDING]
	belongs_to :cube
	has_many :draft_participants
	has_many :users, :through => :draft_participants
	has_many :participant_picks, :through => :draft_participants
	validates :status, :inclusion => {:in => STATUSES}

	STATUSES.each do |s|
		define_method "#{s.downcase}?" do
			status == s
		end
	end

	def create_participants(user_ids)
		users = User.find(user_ids)
		draft_participant_hashes = users.shuffle.map.with_index do |user, i|
			{
				:draft_id => id,
				:user_id => user.id,
				:display_name => user.username,
				:draft_position => i + 1,
				:created_at => Time.now,
				:updated_at => Time.now
			}
		end
		DraftParticipant.insert_all(draft_participant_hashes)
	end

	def display_draft
		self.attributes.merge({
			:active_participant => self.active_participant
		})
	end

	def display_card_pool
		cube.display_cube.map { |k,v|
			[k,v.map do |card|
				card.attributes.merge({:is_drafted => participant_picks.find_by(cube_card_id: card.id).present? })
			end]
		}.to_h
	end

	def active_participant(skipped = 0)
		last_pick = participant_picks.maximum(:pick_number).to_i + skipped
		if last_pick == 0
			return draft_participants.find_by(draft_position: 1)
		end
		draft_participants.find do |drafter|
			if drafter.next_pick_number == last_pick + 1
				if drafter.skipped
					active_drafter = active_participant(skipped+1)
				else
					active_drafter = drafter
				end
				break active_drafter
			end
		end
	end
end