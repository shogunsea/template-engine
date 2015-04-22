
class TemplateEngine 
	attr_accessor :val

	def initialize
		@val = 100
	end

	def yolo
		puts @val
	end

end


engine = TemplateEngine.new
puts engine.val
engine.yolo
