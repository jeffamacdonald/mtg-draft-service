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
			count, set, num, name = split_line(line)
			unless [count, set, name].any? { |item| item.nil? }
				@hash_array << {
					:count => count.to_i,
					:set => set,
					:name => name
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
			item[:name].strip.empty? ||
			!validate_count(item[:count], item[:name]).nil? ||
			!validate_set(item[:set], item[:name]).nil?
		end
	end

	def validate_count(count, name)
		if count < 1
			@errors << {
				:name => "#{name}",
				:error => "Count Invalid"
			}
		end
	end

	def validate_set(set, name)
		if !set.length.between?(3,4)
			@errors << {
				:name => "#{name}",
				:error => "Set Invalid"
			}
		end
	end
end