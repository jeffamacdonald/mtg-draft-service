class CardSanitizer
	class << self
		CARD_FIELDS = %w[name layout image_uri mana_cost cmc type_line oracle_text color_identity set power toughness]

		def sanitize_card(card_data, name)
			case card_data[:layout]
			when 'split'
				sanitize_split(card_data)
			when 'transform'
				sanitize_transform(card_data, name)
			when 'adventure'
				sanitize_adventure(card_data)
			when 'flip'
				sanitize_flip(card_data)
			else
				sanitize_default(card_data)
			end

			card_data.select { |k,v| CARD_FIELDS.include? k.to_s }
		end

		private

		def sanitize_default(card_data)
			card_data[:image_uri] = card_data[:image_uris][:normal]
			card_data
		end

		def sanitize_split(card_data)
			left_side, right_side = card_data[:card_faces]
			left_side[:cmc] = parse_cmc(left_side[:mana_cost])
			right_side[:cmc] = parse_cmc(right_side[:mana_cost])

			card_data[:image_uri] = card_data[:image_uris][:normal]
			card_data[:cmc] = left_side[:cmc] > right_side[:cmc] ? right_side[:cmc] : left_side[:cmc]
			card_data[:oracle_text] = "#{left_side[:oracle_text]}\n#{right_side[:oracle_text]}"
			card_data
		end

		def sanitize_transform(card_data, name)
			front, back = card_data[:card_faces]
			selected_face = front[:name] == name ? front : back

			card_data[:name] = selected_face[:name]
			card_data[:mana_cost] = selected_face[:mana_cost]
			card_data[:cmc] = parse_cmc(selected_face[:mana_cost])
			card_data[:type_line] = selected_face[:type_line]
			card_data[:color_identity] = selected_face[:colors]
			card_data[:image_uri] = selected_face[:image_uris][:normal]
			card_data[:oracle_text] = "#{front[:oracle_text]}\n#{back[:oracle_text]}"
			card_data[:power] = selected_face[:power]
			card_data[:toughness] = selected_face[:toughness]
			card_data.compact!
		end

		def sanitize_adventure(card_data)
			creature, adventure = card_data[:card_faces]
			creature[:cmc] = parse_cmc(creature[:mana_cost])
			adventure[:cmc] = parse_cmc(adventure[:mana_cost])

			card_data[:name] = creature[:name]
			card_data[:image_uri] = card_data[:image_uris][:normal]
			card_data[:cmc] = creature[:cmc] > adventure[:cmc] ? adventure[:cmc] : creature[:cmc]
			card_data[:oracle_text] = "#{creature[:oracle_text]}\n#{adventure[:oracle_text]}"
			card_data
		end

		def sanitize_flip(card_data)
			top, bottom = card_data[:card_faces]

			card_data[:name] = top[:name]
			card_data[:image_uri] = card_data[:image_uris][:normal]
			card_data[:type_line] = top[:type_line]
			card_data[:oracle_text] = "#{top[:oracle_text]}\n#{bottom[:oracle_text]}"
			card_data
		end

		def parse_cmc(mana_cost)
			mana_cost.split(Regexp.union(['{','}'])).reject(&:empty?).map { |mana|
				mana.to_i == 0 ? 1 : mana.to_i
			}.sum
		end
	end
end