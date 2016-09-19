$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

# External dependencies
require 'colorize'
require 'parser'
require 'parser/current'

# Internal dependencies
require 'dockmaster/version'

module Dockmaster
  autoload :Configuration, 'dockmaster/configuration'
  autoload :DocParser, 'dockmaster/parser/doc_parser'
  autoload :Storage, 'dockmaster/parser/storage'
end

puts Dockmaster::DocParser.find_all_source_files
Dockmaster::DocParser.parse('lib/dockmaster/configuration.rb')
