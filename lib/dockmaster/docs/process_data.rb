module Dockmaster
  # This class holds data for the documentation processor
  class ProcessData
    attr_accessor :level, :intern, :final, :final_line, :cache_final, :cache_intern
    attr_accessor :intern_line, :activity
  end
end
