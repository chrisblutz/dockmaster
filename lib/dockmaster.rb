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
  autoload :Data, 'dockmaster/parser/data'
  autoload :DocParser, 'dockmaster/parser/doc_parser'
  autoload :Output, 'dockmaster/output/output'
  autoload :Store, 'dockmaster/parser/store'

  CONFIG = Configuration.load_file
end

store = Dockmaster::DocParser.begin
Dockmaster::Output.start_processing(store)
