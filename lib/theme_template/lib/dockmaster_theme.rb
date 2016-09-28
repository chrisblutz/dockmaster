$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__)) + '/../lib')

require 'dockmaster_theme/file_helper'

# This module represents a theme
# for Dockmaster
module DockmasterTheme
  autoload :FileHelper, 'dockmaster_theme/file_helper'
  autoload :ThemeBinding, 'dockmaster_theme/theme_binding'

  module_function

  def gem_source
    File.expand_path(File.join(File.dirname(__FILE__), '../'))
  end
end

puts DockmasterTheme::FileHelper.relative_path('test/test.txt')
