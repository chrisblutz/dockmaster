module DockmasterTheme
  # This module helps retrieve
  # internal files from the theme
  # gem
  module FileHelper
    module_function

    def relative_path(name)
      File.join(DockmasterTheme.gem_source, name)
    end

    def load_relative(name)
      IO.read(relative_path(name))
    end
  end
end
