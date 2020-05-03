class Card < ApplicationRecord
	has_many :cube_cards
	has_many :cubes, :through => :cube_cards

	def self.get_cards_by_cube_list(cube_list)
		where(name: cube_list.map { |c| c[:name] })
	end
end