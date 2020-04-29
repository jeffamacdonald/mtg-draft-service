FactoryBot.define do
  factory :draft_participant do
  	transient do
  		draft { create :draft }
      user { create :user }
  	end
  	draft_id { draft.id }
    user_id { user.id }
    sequence(:display_name) { |n| "participant#{n}" }
    sequence(:draft_position) { |n| n }
  end
end