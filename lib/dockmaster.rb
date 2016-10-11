$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

# Internal dependencies
require 'dockmaster/version'

# Dockmaster commands
require 'dockmaster/cli/command'
require 'dockmaster/cli/commands/theme_command'

# Dockmaster is a Ruby documentation tool
# that converts source code documentation
# into HTML webpages.
#
# Dockmaster is licensed under the MIT license:
#
# Copyright (c) 2016 Christopher Lutz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module Dockmaster
  autoload :CLI, 'dockmaster/cli/cli'
  autoload :Configuration, 'dockmaster/configuration'
  autoload :Data, 'dockmaster/parser/data'
  autoload :DocParser, 'dockmaster/parser/doc_parser'
  autoload :External, 'dockmaster/external'
  autoload :Output, 'dockmaster/output/output'
  autoload :Source, 'dockmaster/parser/source'
  autoload :Store, 'dockmaster/parser/store'

  CONFIG = Configuration.load_file

  module_function

  def debug=(debug)
    @debug = debug
  end

  def debug?
    @debug ||= false
  end

  def serve_at_end
    @serve_at_end = true
  end

  def serve_at_end?
    @serve_at_end ||= false
  end
end

# Silence Parser version warnings
Dockmaster::External.require_without_warnings('parser')
Dockmaster::External.require_without_warnings('parser/current')
