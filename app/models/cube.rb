class Cube < ApplicationRecord
	belongs_to :user
	has_many :cube_card
	has_many :card, :through => :cube_card

	def create_cube_cards(enriched_cube_list)
		enriched_cube_list.each do |card_hash|
			card = Card.find_by(name: card_hash[:name]) || create_card(card_hash)
			create_cube_card(card, card_hash)
		end
	end

	private

	def create_card(card_hash)
		Card.create do |card|
			card.name = card_hash[:name]
			card.cost = card_hash[:mana_cost]
			card.converted_mana_cost = card_hash[:cmc]
			card.card_text = card_hash[:oracle_text]
			card.layout = card_hash[:layout]
			card.power = card_hash[:power]
			card.toughness = card_hash[:toughness]
			card.default_image = card_hash[:image_uris][:normal]
			card.color_identity = card_hash[:color_identity].empty? ? "C" : card_hash[:color_identity].join
			card.default_set = card_hash[:set]
			card.type_line = card_hash[:type_line]
		end
	end

	def create_cube_card(card, card_hash)
		custom_set = card.default_set != card_hash[:set] ? card_hash[:set] : nil
		custom_image = get_custom_image(card, custom_set)
		CubeCard.create do |cube_card|
			cube_card.cube_id = self.id
			cube_card.card_id = card.id
			cube_card.count = card_hash[:count]
			cube_card.custom_set = card_hash[:set]
			cube_card.custom_image = custom_image
			cube_card.custom_color_identity = card_hash[:custom_color_identity]
		end
	end

	def get_custom_image(card, set)
		if set.nil?
			return
		end
		CubeCard.find_by(card_id: card.id, custom_set: set)&.custom_image ||
			Clients::Scryfall.new.get_card(card.name, set)['img_uris']['normal']
	end
end