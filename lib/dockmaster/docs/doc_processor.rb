require 'dockmaster/docs/processor_defaults'

module Dockmaster
  # This class processes documentation comments into usable formats
  class DocProcessor
    class << self
      def process(doc_comment, file)
        @file = file

        @text = ''

        @fields = {}

        ProcessorDefaults.register_internals

        process_lines(doc_comment)

        @text = process_internal_documentation(@text)
        @text.strip!
        @text.gsub!("\n", '<br>')

        Dockmaster::Docs.new(@text.strip, @fields)
      end

      def handlers
        @handlers ||= {}
      end

      def internal_handlers
        @internal_handlers ||= {}
      end

      def see_links
        @see_links ||= {}
      end

      def register_internal_annotation_handler(annotation, &block)
        internal_handlers[annotation] = block
      end

      def register_annotation_handler(annotation, &block)
        handlers[annotation] = block
      end

      def process_internal_documentation(text)
        process_internal(text)
      end

      def retrieve(name)
        @fields[name]
      end

      def retrieve_with_default(name, default)
        @fields[name] ||= default
      end

      def set(name, value)
        @fields[name] = value
      end

      private

      def process_lines(doc_comment)
        doc_comment.split("\n").each do |line|
          # Strip '#' and any outside whitespace
          text = line[1..-1].strip

          if text.empty?
            @text += "\n\n"
          elsif text.start_with?('@')
            @text.strip!
            process_annotation(text)
          else
            @text += "#{text} "
          end
        end
      rescue
        abort "ERROR: Malformed documentation in '#{@file}'"
      end

      def process_annotation(text)
        annot = text.split(' ')[0][1..-1].to_sym
        return unless handlers.key?(annot)
        handler = handlers[annot]
        return if handler.nil?
        intern = text[1 + annot.length..-1].strip
        handler.call(intern)
      rescue
        abort "ERROR: Malformed doc annotation in '#{@file}'"
      end

      def process_internal(text)
        level = 0
        intern = ''
        final = ''

        text.each_char do |char|
          if char == '{'
            intern += '{' if level > 0
            level += 1
          elsif char == '}'
            if level > 1
              intern += '}'
              level -= 1
            elsif level == 1
              result = process_internal_annotation(intern)
              final += result
              intern = ''
              level = 0
            end
          elsif level > 0
            intern += char
          else
            final += char
          end
        end

        final
      rescue
        abort "ERROR: Malformed documentation in '#{@file}'"
      end

      def process_internal_annotation(text)
        text.strip!
        return text unless text.start_with?('@')
        annot = text.split(' ')[0][1..-1].to_sym
        return text unless internal_handlers.key?(annot)
        handler = internal_handlers[annot]
        return text if handler.nil?
        intern = text[1 + annot.length..-1].strip
        result = handler.call(intern)
        result
      rescue
        abort "ERROR: Malformed internal doc annotation in '#{@file}'"
      end
    end
  end
end
