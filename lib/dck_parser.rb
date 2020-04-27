class DckParser
	class ParseError < StandardError;end

	def initialize(dck_file)
		@dck_file = dck_file
		@hash_array = []
		@errors = []
	end

	def get_parsed_list
		[map_to_hash_array, @errors]
	end

	private

	def map_to_hash_array
		File.open(@dck_file).each do |line|
			count, set, num, card_name = split_line(line)
			unless [count, set, card_name].any? { |item| item.nil? }
				@hash_array << {
					:count => count.to_i,
					:set => set,
					:card_name => card_name
				}
			else
				raise ParseError.new("Malformed File")
			end
		end
		reject_bad_records
	end

	def split_line(line)
		line.gsub("\n","").gsub("\r","").split(Regexp.union([' [',':','] ']))
	end

	def reject_bad_records
		@hash_array.reject do |item|
			item[:card_name].strip.empty? ||
			!validate_count(item[:count], item[:card_name]).nil? ||
			!validate_set(item[:set], item[:card_name]).nil?
		end
	end

	def validate_count(count, card_name)
		if count < 1
			@errors << {
				:card_name => "#{card_name}",
				:error => "Count Invalid"
			}
		end
	end

	def validate_set(set, card_name)
		if set.length != 3
			@errors << {
				:card_name => "#{card_name}",
				:error => "Set Invalid"
			}
		end
	end
end