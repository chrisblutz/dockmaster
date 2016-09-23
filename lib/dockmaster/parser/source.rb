module Dockmaster
  # Finds source files
  # and sorts out the ones
  # excluded by the
  # .dockmaster.yml file
  module Store
    module_function

    def find_all_source_files
      # TODO: Allow changing source folder
      Dir["#{Dir.pwd}/**/*.rb"]
    end

    def sort_source_files(files)
      included = []
      excluded = []

      files.each do |file|
        if Dockmaster::CONFIG.excluded?(file)
          excluded << file
        else
          included << file
        end
      end

      if Dockmaster.debug?
        puts 'Excluding files:'
        excluded.each do |file|
          puts " - #{file.sub(Dir.pwd, '')}"
        end
      end

      included
    end
  end
end
