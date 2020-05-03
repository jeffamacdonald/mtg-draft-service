class Cube < ApplicationRecord
	class CreationError < StandardError;end

	belongs_to :user
	has_many :cube_cards
	has_many :cards, :through => :cube_cards
	include CubeHelper

	def create_cube_cards(cube_list)
		@cube_list = cube_list
		# TODO Clean up this garbage and write tests
		errors, enriched_cards = [], []
		new_card_hashes = cube_list.reject do |c|
			existing_cards_array.map { |card| card.attributes['name']}.include? c[:name]
		end
		new_card_hashes.each_slice(75) do |group|
			card_enricher_response = CardEnricher.get_enriched_list(group)
			errors += card_enricher_response[:errors]
			enriched_cards += card_enricher_response[:card_list]
		end
		raise CreationError.new(errors.to_json) unless errors.empty?
		enriched_cards.each do |card|
			existing_cards_array << create_card(card)
		end
		(cube_list + existing_cards_array.map { |card| card.attributes.symbolize_keys })
		.group_by { |card|
			card[:name]
		}.reject { |k,v|
			v.length < 2
		}.map { |_, hsh|
			hsh.reduce(:merge)
		}.each do |card_hash|
			create_cube_card(card_hash)
		end
	end

	def display_cube
		get_sorted_active_cube_cards.chunk_while { |bef, aft|
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
			card.default_image = card_hash[:image_uri]
			card.color_identity = get_color_identity(card_hash)
			card.default_set = card_hash[:set]
			card.type_line = card_hash[:type_line]
		end
	end

	def create_cube_card(card_hash)
		custom_set = card_hash[:default_set].upcase != card_hash[:set]&.upcase ? card_hash[:set] : nil
		CubeCard.create! do |cube_card|
			cube_card.cube_id = id
			cube_card.card_id = card_hash[:id]
			cube_card.count = card_hash[:count]
			cube_card.custom_set = card_hash[:set]
			cube_card.custom_image = get_custom_image(card_hash, custom_set) || card_hash[:default_image]
			cube_card.custom_color_identity = card_hash[:custom_color_identity] || card_hash[:color_identity]
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

	def get_custom_image(card_hash, set)
		return if set.nil?
		CubeCard.find_by(card_id: card_hash[:id], custom_set: set)&.custom_image ||
			Clients::Scryfall.new.get_card(card_hash[:name], set)[:image_uri]
	end

	def get_sorted_active_cube_cards
		cube_cards.joins(:card)
			.where(soft_delete: false)
			.order(:custom_color_identity, :converted_mana_cost)
	end
end