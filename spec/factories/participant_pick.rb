FactoryBot.define do
  factory :participant_pick do
  	transient do
  		draft_participant { create :draft_participant }
      cube_card { create :cube_card }
  	end
  	draft_participant_id { draft_participant.id }
    cube_card_id { cube_card.id }
    sequence(:pick_number) { |n| n }
    round { 1 }
  end
end