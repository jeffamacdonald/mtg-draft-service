class Card < ApplicationRecord
	has_many :cube_card
	has_many :cube, :through => :cube_card
end