class Cube < ApplicationRecord
	class CreationError < StandardError;end

	belongs_to :user
	has_many :cube_cards
	has_many :cards, :through => :cube_cards

	def create_cube_cards(cube_list)
		errors = []
		cube_list.each do |card_hash|
			card = Card.find_by(name: card_hash[:name])
			if card.nil?
				enriched_card_hash = CardEnricher.new(card_hash).get_enriched_card
				if enriched_card_hash.has_key? :error
					errors << enriched_card_hash
				else
					card = Card.find_by(name: enriched_card_hash[:name]) || create_card(enriched_card_hash)
				end
			end
			create_cube_card(card, card_hash)
		end
		unless errors.empty?
			raise CreationError.new(errors.to_json)
		end
	end

	def display_cube
		get_active_cube_cards_ordered.chunk_while { |bef, aft|
			bef[:custom_color_identity] == aft[:custom_color_identity]
		}.each_with_object({}) { |sect, hsh|
			hsh[sect[0][:custom_color_identity]] = sect
		}
	end

	private

	def create_card(card_hash)
		Card.create! do |card|
			card.name = card_hash[:name]
			card.cost = card_hash[:mana_cost]
			card.converted_mana_cost = card_hash[:cmc]
			card.card_text = card_hash[:oracle_text]
			card.layout = card_hash[:layout]
			card.power = card_hash[:power]
			card.toughness = card_hash[:toughness]
			card.default_image = card_hash[:image_uris][:normal]
			card.color_identity = get_color_identity(card_hash)
			card.default_set = card_hash[:set]
			card.type_line = card_hash[:type_line]
		end
	end

	def create_cube_card(card, card_hash)
		return if card.nil?
		custom_set = card.default_set != card_hash[:set] ? card_hash[:set] : nil
		CubeCard.create! do |cube_card|
			cube_card.cube_id = id
			cube_card.card_id = card.id
			cube_card.count = card_hash[:count]
			cube_card.custom_set = card_hash[:set]
			cube_card.custom_image = get_custom_image(card, custom_set) || card.default_image
			cube_card.custom_color_identity = card_hash[:custom_color_identity] || card.color_identity
			cube_card.soft_delete = false
		end
	end

	def get_color_identity(card_hash)
		if card_hash[:color_identity].empty? || card_hash[:type_line].include?('Land')
			'C'
		else
			card_hash[:color_identity].join
		end
	end

	def get_custom_image(card, set)
		return if set.nil?
		CubeCard.find_by(card_id: card.id, custom_set: set)&.custom_image ||
			Clients::Scryfall.new.get_card(card.name, set)['image_uris']['normal']
	end

	def get_active_cube_cards_ordered
		cube_cards.joins(:card)
			.where(soft_delete: false)
			.order(:custom_color_identity, :converted_mana_cost)
	end
end