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
  autoload :Storage, 'dockmaster/parser/storage'
end

storage_ary = Dockmaster::DocParser.begin
storage_ary.each { |s| Dockmaster::Output.start_processing(s) }
