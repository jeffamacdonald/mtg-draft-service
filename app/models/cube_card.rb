class CubeCard < ApplicationRecord
	class CreationError < StandardError;end
	belongs_to :cube
	belongs_to :card

	def self.create_cube_card_from_hash(cube, card_hash)
		need_image = !card_hash[:set].nil? &&
									card_hash[:default_set].upcase != card_hash[:set]&.upcase
		CubeCard.create! do |cube_card|
			cube_card.cube_id = cube.id
			cube_card.card_id = card_hash[:id]
			cube_card.count = card_hash[:count]
			cube_card.custom_set = card_hash[:set]
			cube_card.custom_image = need_image ? get_custom_image(card_hash) : card_hash[:default_image]
			cube_card.custom_color_identity = card_hash[:custom_color_identity] || card_hash[:color_identity]
			cube_card.custom_cmc = card_hash[:custom_cmc] || card_hash[:cmc]
			cube_card.soft_delete = false
		end
	end

	def self.get_custom_image(card_hash)
		cube_card_with_set = CubeCard.find_by(card_id: card_hash[:id], custom_set: card_hash[:set])
		if cube_card_with_set
			CubeCard.find_by(card_id: card_hash[:id], custom_set: card_hash[:set]).custom_image
		else
			scryfall_card = Clients::Scryfall.new.get_card(card_hash[:name], card_hash[:set])
			if scryfall_card[:error].present?
				raise CreationError.new(scryfall_card[:error].to_json)
			else
				scryfall_card[:image_uri]
			end
		end
	end
end