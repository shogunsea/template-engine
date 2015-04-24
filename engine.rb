#! /usr/bin/env ruby
# require 'debugger'
require 'json'
require './parser'

# Template Engine 
# Xiaokang Xin

# Template engine class, contains two methods: initialize and parse.
# Input file paths are set as instance variables so that different instances
# can run different tasks.
# The parse method works with instance of LineParser class, which I split the 
# line parsing logic into it so that if in the future we want add different 
# parsing feature we can just modify that class. 
# The parse method itself is 
# implemented in a iterative fashion, which basically scan the template once 
# then iterate over it baesd on line index, also I used three auxilary stacks 
# to store data, line index, and loop start index, so that using infomation 
# about states of top of stack elements we would be able to navigate in our 
# template file, as well as getting correct data from JSON file.


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
		@template_content = File.readlines(@template_path)
		@data = File.read(@data_path)
		@output = nil 
	end

	def parse 
		@output = File.open(@output_path, "w")
		 # parse json into hash object
		root_node = JSON.parse(@data)
		# last element is current hash/array to be filled
		# in template, at the loop start, new element
		# will be pushed onto the stack
		data_stack = []
		# keep the processed index during current loop
		# will only be used if current element is an arry
		index_stack = []
		# stores the starting index of loop
		loop_start_index_stack = []

		# variables initilization
		# while json data object as root node
		data_stack.push(root_node)
		line = ""
		parsed_line = ""
		template_line_index = 0
		# new line parser index
		parser = LineParser.new

		while template_line_index < @template_content.length
			line = @template_content[template_line_index]

			if parser.loop_start?(line)
				keys = parser.parse_loop_start(line)
				data_node = nil
				if data_stack.last.class == Array
					# iterate over an array of hashes
					# so we only need last element of keys
					keys = keys.last
					data_node = data_stack.last[index_stack.last][keys]
				else
					# current element is a hash
					data_node = data_stack.last
					if keys.class == Array
						# case for nested keys
						# example: page.title.subtitle
						#   will fetch ---> root_node["page"]["title"]["subtitle"]
						keys.each_with_index do |key, index|
			  				data_node = data_node[key]
			  			end
			  		else
			  			data_node = data_node[keys]
			  		end
				end
				# debugger
				index_stack.push(0)
				data_stack.push(data_node)
				# next line is where loop starts
				loop_start_index_stack.push(template_line_index + 1)
				parsed_line = ""

		  	elsif parser.loop_end?(line)

				if index_stack.last == data_stack.last.length - 1
					# if we have processed all array items for current
					# data, meaning this inner loop is finished.
					# pop out corresponding data from stacks
					data_stack.pop()
					index_stack.pop()
					loop_start_index_stack.pop()
				else
					# increase the index on index_stack
					index_stack[index_stack.size - 1] = index_stack.last + 1
					# this line decrease line index by one, since at the end of 
					# while loop, all cases increase line index by one
					template_line_index = loop_start_index_stack.last - 1
				end

				parsed_line = ""

		  	elsif parser.sub?(line)
		  		keys = parser.parse_substitution(line)
		  		# debugger
		  		if data_stack.last.class == Array

		  			val = data_stack.last[index_stack.last]
		  			# debugger
		  			if val.class == Hash
		  				keys.shift
		  				keys.each_with_index do |key, index|
			  				val = val[key]
			  			end
			  		end

		  		else 
		  			# debugger
		  			val = data_stack.last
		  			keys.each_with_index do |key, index|
		  				val = val[key]
		  			end
		  		end

		  		parsed_line = val

		  	else
		  		# do not need to be substitude.
		  		parsed_line = line
		    end
		    # if line doesnt contains '<*', just remain unchanged
		    # debugger
			@output.write(parser.substitute(line, parsed_line))
			template_line_index += 1
		end

		@output.close
	end
end
