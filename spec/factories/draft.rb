FactoryBot.define do
  factory :draft do
  	transient do
  		cube { create :cube }
  	end
  	cube_id { cube.id }
    sequence(:name) { |n| "draft#{n}" }
    status { 'PENDING' }
    rounds { 40 }
    timer_minutes { 120 }
  end
end