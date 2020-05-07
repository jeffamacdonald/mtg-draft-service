class Cube < ApplicationRecord
	class CreationError < StandardError;end

	belongs_to :user
	has_many :cube_cards
	has_many :cards, :through => :cube_cards
	include CubeHelper

	def setup_cube_from_list(cube_list)
		@cube_list = cube_list
		errors, enriched_cards = get_new_enriched_cards
		raise CreationError.new(errors.to_json) unless errors.empty?
		create_new_cards(enriched_cards)
		errors = create_cube_cards_and_return_errors(self)
		raise CreationError.new(errors.to_json) unless errors.empty?
	end

	def display_cube
		get_sorted_active_cube_cards.chunk_while { |bef, aft|
			bef[:custom_color_identity] == aft[:custom_color_identity]
		}.each_with_object({}) { |sect, hsh|
			hsh[sect[0][:custom_color_identity]] = sect
		}
	end

	private

	def get_sorted_active_cube_cards
		cube_cards.joins(:card)
			.where(soft_delete: false)
			.order(:custom_color_identity, :cmc)
	end
end