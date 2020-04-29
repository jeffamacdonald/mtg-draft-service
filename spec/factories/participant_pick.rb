FactoryBot.define do
  factory :participant_pick do
  	transient do
  		draft_participant { create :draft_participant }
      card { create :card }
  	end
  	draft_participant_id { draft_participant.id }
    card_id { card.id }
    sequence(:pick_number) { |n| n }
    round { 1 }
  end
end