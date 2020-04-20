FactoryBot.define do
	factory :cube_card do
		transient do
			cube { create :cube }
			card { create :card }
		end
		cube_id { cube.id }
		card_id { card.id }
		count {1}
	end
end