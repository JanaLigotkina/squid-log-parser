#!/usr/bin/env ruby

require_relative 'lib/log_data'
require_relative 'lib/parser'

LOG_FILE_PATH = '/Users/jana/Downloads/access.log'.freeze

parser = Parser.new(LOG_FILE_PATH, 3)
puts parser.inspect

