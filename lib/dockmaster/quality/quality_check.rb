require 'rainbow'

require 'dockmaster/cli/cli'
require 'dockmaster/quality/criteria'

require 'dockmaster/quality/enforcers/field_enforcer'
require 'dockmaster/quality/enforcers/method_enforcer'
require 'dockmaster/quality/enforcers/module_class_enforcer'

module Dockmaster
  # This class houses the quality check system, utilized by the check command
  class QualityCheck
    class << self
      def check(store)
        reset

        register_default_enforcers

        check_store(store)
        CLI.end_bar
      end

      def check_store(store)
        type = store.type
        c = Criteria.new
        matched = false
        base_enforcers.each do |enforcer|
          if enforcer.matches(type)
            matched = true
            c = enforcer.check(store, c)
          end
        end
        if matched
          criteria << c
          print_criteria(c)
        end

        check_data(store)

        store.children.each do |child|
          check_store(child)
        end
      end

      def check_data(store)
        store.data.each do |sym, data_arr|
          data_arr.each do |name, data|
            c = Criteria.new
            matched = false
            enforcers.each do |enforcer|
              next unless enforcer.matches(sym)
              matched = true
              c = enforcer.check(sym, name, data, store, c)
            end
            if matched
              criteria << c
              print_criteria(c)
            end
          end
        end
      end

      def print_results(suggestions)
        if suggestions
          criteria.each do |c|
            grade = c.evaluate
            if grade < 3
              CLI.output('')
              c.print_evaluation
            end
          end
        end
        CLI.output('')
        CLI.output("Checked #{Rainbow(criteria.length).yellow} documentation items")
        CLI.output("#{count(:a)} item(s) rated #{Rainbow('A').green} (documentation present)")
        CLI.output("#{count(:b)} item(s) rated #{Rainbow('B').cyan} (missing some documentation)")
        CLI.output("#{count(:c)} item(s) rated #{Rainbow('C').yellow} (missing most documentation)")
        CLI.output("#{count(:u)} item(s) rated #{Rainbow('U').magenta} (undocumented)")
      end

      def grade_to_letter_no_color(grade)
        letter = case grade
                 when 3
                   'A'
                 when 2
                   'B'
                 when 1
                   'C'
                 else
                   'U'
                 end
        letter
      end

      def grade_to_letter(grade)
        letter = case grade
                 when 3
                   Rainbow('A').green
                 when 2
                   Rainbow('B').cyan
                 when 1
                   Rainbow('C').yellow
                 else
                   Rainbow('U').magenta
                 end
        letter
      end

      def reset
        @criteria = []
        @grade_count = {}
      end

      def criteria
        @criteria ||= []
      end

      def grade_count
        @grade_count ||= {}
      end

      def count(grade)
        grade_count[grade] ||= 0
      end

      def increase_count(grade)
        count(grade)
        grade_count[grade] += 1
      end

      def enforcers
        @enforcers ||= []
      end

      def register_enforcer(enforcer)
        enforcers << enforcer
      end

      def base_enforcers
        @base_enforcers ||= []
      end

      def register_base_enforcer(enforcer)
        base_enforcers << enforcer
      end

      def register_default_enforcers
        register_enforcer(FieldEnforcer)
        register_enforcer(MethodEnforcer)

        register_base_enforcer(ModuleClassEnforcer)
      end

      private

      def print_criteria(criteria)
        grade = criteria.evaluate
        letter = grade_to_letter(grade)
        if grade == 3
          CLI.increment(Rainbow('.').green)
        else
          CLI.increment(letter)
        end

        # Increment numbers of processed items
        no_color = grade_to_letter_no_color(grade)
        increase_count(no_color.downcase.to_sym)
      end
    end
  end
end
