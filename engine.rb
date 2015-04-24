#! /usr/bin/env ruby
require 'debugger'
# debugger
require 'json'
require './parser'

class TemplateEngine 
	attr_accessor :template_path, :data_path, :output_path, :data, :template_content
				:output

	def initialize(argv)
		# 3 arguments
		# templater template.panoramatemplate data.json output.html
		if argv.size != 3
			puts "Wrong arguments"
			exit 1
		end
		@template_path, @data_path, @output_path = argv
		# Robust, generic, recusive/iterative method.
		# line object which contains children lines?.
		# mapping between 'each' keyword and json/html
		@template_content = File.readlines(@template_path)
		@data = File.read(@data_path)
		@output = nil 
	end

	def parse 
		@output = File.open(@output_path, "w")
		 # parse json into hash object
		root_node = JSON.parse(@data)
		data_stack = []
		index_stack = []
		loop_start_index_stack = []

		data_stack.push(root_node)

		line = ""
		parsed_line = ""
		template_line_index = 0
		parser = LineParser.new

		while template_line_index < @template_content.length
			line = @template_content[template_line_index]

			if parser.loop_start?(line)
				# push current object onto stack
				# record total children size with procesed_items size
				# keep the starting index of current block
				# parse 'each' keyword
				keys = parser.parse_loop_start(line)
				# debugger
				data_node = nil
				if data_stack.last.class == Array
					keys = keys.last
					data_node = data_stack.last[index_stack.last][keys]
				else
					data_node = data_stack.last
					if keys.class == Array
						keys.each_with_index do |key, index|
			  				data_node = data_node[key]
			  			end
			  		else
			  			data_node = data_node[keys]
			  		end
					# data_node = data_stack.last[key]
				end

				# debugger

				index_stack.push(0)
				data_stack.push(data_node)
				loop_start_index_stack.push(template_line_index + 1)

				parsed_line = ""
				# output.write new_line
				# i += 1

		  	elsif parser.loop_end?(line)
				# padding with empty line
				# check if total children size is equal to processed_items size
				# if so keep index going
				# else go back to record index

				if index_stack.last == data_stack.last.length - 1
					data_stack.pop()
					index_stack.pop()
					loop_start_index_stack.pop()
				else
					index_stack[index_stack.size - 1] = index_stack.last + 1
					template_line_index = loop_start_index_stack.last - 1
				end

				parsed_line = ""

		  	elsif parser.sub?(line)
		  		# fetch key from current hash object or array element.
		  		# parse the current line

		  		# Ensure keys should always be array
		  		keys = parser.parse_substitution(line)

		  		# debugger
		  		if data_stack.last.class == Array
		  			# If top of stack is Array
		  			# pick last key
		  			# process with inner_line_index
		  			# 
		  			# Val still can be either hash or elements!!
		  			val = data_stack.last[index_stack.last]
		  			# debugger
		  			if val.class == Hash
		  				keys.shift
		  				keys.each_with_index do |key, index|
			  				val = val[key]
			  			end
			  		end

		  			# inner_line_index += 1
		  			# ??
		  			# Only Keep last keys
		  			# student.name --> name
		  			# student.name.lastname --> lastname
		  		else 
		  			# top of stack is hash
		  			# debugger
		  			val = data_stack.last
		  			keys.each_with_index do |key, index|
		  				val = val[key]
		  			end
		  			# output.write val
		  		end

		  		parsed_line = val

		  	else
		  		# do not need to be substitude.
		  		parsed_line = line
		    end
		    # if line doesnt contains '<*', just remain unchanged
		    # debugger
			@output.write line.gsub(/<\*[^\*]*\*>/, parsed_line)
			template_line_index += 1

		end

		@output.close
	end
end
