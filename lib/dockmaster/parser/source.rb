module Dockmaster
  # Finds source files
  # and sorts out the ones
  # excluded by the
  # .dockmaster.yml file
  module Source
    module_function

    def find_all_source_files
      Dir["#{Dir.pwd}/**/*.rb"]
    end

    def sort_source_files(files)
      included = []
      excluded = []

      files.each do |file|
        if Dockmaster::Configuration.excluded?(file)
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
