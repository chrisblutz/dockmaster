$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

# External dependencies
require 'colorize'

# Internal dependencies
require 'dockmaster/version'

# Dockmaster commands
require 'dockmaster/cli/command'
require 'dockmaster/cli/commands/build'
require 'dockmaster/cli/commands/serve'

# Test docs
module Dockmaster
  autoload :CLI, 'dockmaster/cli/cli'
  autoload :Configuration, 'dockmaster/configuration'
  autoload :Data, 'dockmaster/parser/data'
  autoload :DocParser, 'dockmaster/parser/doc_parser'
  autoload :External, 'dockmaster/external'
  autoload :Output, 'dockmaster/output/output'
  autoload :Store, 'dockmaster/parser/store'

  CONFIG = Configuration.load_file
end

# Silence Parser version warnings
Dockmaster::External.require_without_warnings('parser')
Dockmaster::External.require_without_warnings('parser/current')
