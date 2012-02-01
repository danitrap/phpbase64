#!/usr/bin/env ruby
##########################################
#         PHP/Base64 Encoder 1.0         #
# A script that will encode any binary   #
# file and output a self-extracting php. #
##########################################

require 'base64'
require 'optparse'

options = {:output => false}

optparse = OptionParser.new do|opts|
  script_name = File.basename($0)
  opts.banner = "Usage: #{script_name} [options] filename\n"
  opts.define_head "A script that will encode any given binary file into a self-extracting php script."
  opts.separator ""
  opts.separator "Example: #{script_name} -o selfextractor.php program.exe"
  opts.separator ""
  
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
  
  opts.on('-o filename', '--output filename', String, 'Path to output file') do|f|
    options[:output] = f
  end
end

begin optparse.parse! ARGV
  rescue OptionParser::InvalidOption => e
  puts e
  puts optparse
  exit 1
end

if (!(filename = ARGV.shift)) or (!(File.exists?(filename)))
  puts optparse
  exit
end

name = File.basename(filename)
content = IO.binread(filename)

enc = Base64.encode64(content)

encoded = "<?php $i=base64_decode(\""
enc.each_line {|l|
  encoded += l.chomp()
}
encoded += "\");file_put_contents(\"#{name}\",$i); ?>"

#if :output is set just write out the encoded file
if options[:output] then
  File.open(options[:output], "w") do |file| file.write(encoded) end
  puts "#{File.size(options[:output])} bytes written in #{options[:output]}"
  exit
end

#else, let's just output it on screen
$stdout.puts encoded
