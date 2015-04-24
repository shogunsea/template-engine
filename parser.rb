class LineParser
	def loop_start?(line)
		line.include? "<* EACH"
	end

	def loop_end?(line)
		line.include? "<* ENDEACH"
	end

	def sub?(line)
		line.include? "<*"
	end

	def parse_loop_start(line)
		keys = line.scan(/EACH[^\*]*/).first.split(" ")[1]
		if keys.include? '.'
			keys = keys.split(".")
		end
		keys
	end

	def parse_substitution(line) 
		line.scan(/<\*[^\*]*\*>/).first.split(" ")[1].split(".")
	end

	def substitute(original_line, parsed_line) 
		original_line.gsub(/<\*[^\*]*\*>/, parsed_line)
	end
end