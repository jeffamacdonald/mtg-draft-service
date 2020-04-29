class Card < ApplicationRecord
	has_many :cube_cards
	has_many :cubes, :through => :cube_cards
end