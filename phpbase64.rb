#!/usr/bin/env ruby
##########################################
#         PHP/Base64 Encoder 1.1         #
# A script that will encode any binary   #
# file and output a self-extracting php. #
##########################################

require 'base64'
require 'optparse'

options = {
:output => false,
:execute => false,
:verbose => false
}

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
    puts "[*] Output is set to: #{f}"
  end
  
  opts.on('-x', '--execute', 'Auto execute extracted file') do
    options[:execute] = true
    puts "[*] Auto execution after extraction set to on."
  end
  
  opts.on('-v', '--verbose', 'PHP script in verbose mode') do
    options[:verbose] = true
    puts "[*] Verbose mode set to on."
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
encoded += "\");$a=file_put_contents(\"#{name}\",$i);"

encoded += "if ($a) echo 'file written successfully. '; else echo 'error writing file. ';" if options[:verbose]
encoded += "if(PHP_OS == 'WINNT' || PHP_OS == 'WIN32') pclose(popen('start /b #{name}', 'r')); else pclose(popen(#{name}.' >> /dev/null &', 'r'));" if options[:execute]
encoded += "echo 'file executed.';" if options[:verbose] and options[:execute]
encoded+= " ?>"

#if :output is set just write out the encoded file
if options[:output] then
  File.open(options[:output], "w") do |file| file.write(encoded) end
  puts "#{File.size(options[:output])} bytes written in #{options[:output]}"
  exit
end

#else, let's just output it on screen
$stdout.puts encoded
