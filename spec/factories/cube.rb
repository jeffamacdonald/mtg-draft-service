FactoryBot.define do
  factory :cube do
  	transient do
  		user { create :user }
  	end
  	user_id { user.id }
    name { "factory cube" }
  end
end