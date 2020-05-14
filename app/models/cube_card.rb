class CubeCard < ApplicationRecord
	class CreationError < StandardError;end
	belongs_to :cube
	belongs_to :card

	def update_from_hash(card_hash)
		card_hash[:id] = self.card_id
		card_hash[:name] = self.card.name
		need_image = card_hash[:set].present? &&
									self.card.default_set.upcase != card_hash[:set].upcase
		self.count = card_hash[:count] if card_hash[:count].present?
		self.custom_set = card_hash[:set] if card_hash[:set].present?
		self.custom_image = need_image ? CubeCard.get_custom_image(card_hash) : self.card.default_image
		self.custom_color_identity = card_hash[:custom_color_identity] if card_hash[:custom_color_identity].present?
		self.custom_cmc = card_hash[:custom_cmc] if card_hash[:custom_cmc].present?
		self.soft_delete = card_hash[:soft_delete] if !card_hash[:soft_delete].nil?
		save!
	end

	def self.create_cube_card_from_hash(cube, card_hash)
		need_image = card_hash[:set].present? &&
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
			scryfall_card = CardEnricher.get_enriched_card(card_hash)
			if scryfall_card[:error].present?
				raise CreationError.new(scryfall_card[:error].to_json)
			else
				scryfall_card[:image_uri]
			end
		end
	end
end