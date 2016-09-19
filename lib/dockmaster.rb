$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

# External dependencies
require 'colorize'
require 'parser'
require 'parser/current'

# Internal dependencies
require 'dockmaster/version'

# Test docs
module Dockmaster
  autoload :Configuration, 'dockmaster/configuration'
  autoload :DocParser, 'dockmaster/parser/doc_parser'
  autoload :Output, 'dockmaster/output/output'
  autoload :Store, 'dockmaster/parser/store'
end

stores = Dockmaster::DocParser.begin
stores.each { |s| Dockmaster::Output.start_processing(s) }
