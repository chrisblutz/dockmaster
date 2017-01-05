require 'rainbow'

require 'dockmaster/cli/cli'
require 'dockmaster/quality/quality_check'

module Dockmaster
  # This class holds information about quality of documentation for objects
  class Criteria
    def define_scope(name)
      @name = name
    end

    def define_new(sym, desc)
      internal[sym] = false
      internal_desc[sym] = desc
    end

    def set(sym, value)
      internal[sym] = value
    end

    def evaluate
      num_true = 0
      grade = 3

      internal.values.each do |value|
        num_true += 1 if value
        grade -= 1 unless value
      end

      grade = 0 if grade < 0
      grade = 0 unless num_true.nonzero?

      grade
    end

    def print_evaluation
      grade = evaluate

      return unless grade < 3

      CLI.output("#{name} (#{QualityCheck.grade_to_letter(grade)})")
      CLI.output('Missing:')
      internal.each do |sym, value|
        unless value
          desc = internal_desc[sym]
          CLI.output("\t#{Rainbow(desc).red}")
        end
      end
    end

    def name
      @name ||= 'UNDEFINED SCOPE NAME'
    end

    def internal_desc
      @internal_desc ||= {}
    end

    private

    attr_writer :name

    def internal
      @internal ||= {}
    end
  end
end
