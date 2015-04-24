require './engine'
# Digest module to check md5sum of output file
require 'digest'


path = Dir.entries('./test_input')
# remove "." and ".."
path.delete(".")
path.delete("..")

for folder in path
	template_path = Dir.pwd + "/test_input/" + folder + "/template.html"
	data_path = Dir.pwd + "/test_input/" + folder + "/data.json"
	output_path = Dir.pwd + "/test_input/" + folder + "/actual_output.html"
	expected_file_path = Dir.pwd + "/test_input/" + folder + "/expected_output.html"

	argv = [template_path, data_path, output_path]
	template_engine = TemplateEngine.new(argv)
	
	puts "Starting to parse file at: " + template_path + " ..."
	template_engine.parse()
	puts "Done."
	# validation
	expected = Digest::MD5.file(expected_file_path).hexdigest 
	actual = Digest::MD5.file(output_path).hexdigest 
	puts "Expected output md5sum: \n" + expected
	puts "Generated output md5sum: \n" + actual 
	puts "Correct output: " + (expected == actual).to_s
	puts 
end






