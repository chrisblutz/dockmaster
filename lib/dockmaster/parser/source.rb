module Dockmaster
  # Finds source files and sorts out the ones excluded by the {@code .dockmaster.yml} file
  module Source
    module_function

    # Locates all source files inside of the working directory.  Source files are defined
    # as any file with the {@code .rb} file extension.
    #
    # @return An array containing all located source file paths
    def find_all_source_files
      Dir["#{Dir.pwd}/**/*.rb"]
    end

    # Determines which files should be processed and which should not, as determined by
    # the configuration value of {@code exclude}.
    #
    # @param files The array of files to sort
    # @return The files to process (not excluded in {@code .dockmaster.yml})
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
