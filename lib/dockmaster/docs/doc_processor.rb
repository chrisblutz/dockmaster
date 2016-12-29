require 'dockmaster/docs/process_data'
require 'dockmaster/docs/processor_defaults'

module Dockmaster
  # This class processes documentation comments into usable formats
  class DocProcessor
    class << self
      def process(doc_comment, file)
        @file = file

        @lines = []
        @text = ''

        @fields = {}

        ProcessorDefaults.register_internals

        process_lines(doc_comment)

        final = process_internal_documentation(@lines)
        @text = format_lines(final)
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

      def register_internal_wrap_annotation(annotation, front, back, process = true)
        register_internal_annotation_handler(annotation) do |lines|
          lines = process_internal_documentation(lines) if process
          wrap(lines, front, back)
        end
      end

      def register_annotation_handler(annotation, &block)
        handlers[annotation] = block
      end

      def register_direct_annotation(annotation, process = true)
        DocProcessor.register_annotation_handler(annotation) do |text|
          if process
            processed = DocProcessor.process_internal_documentation(text)
            DocProcessor.set(annotation, DocProcessor.join(processed))
          else
            DocProcessor.set(annotation, text)
          end
        end
      end

      def process_internal_documentation(lines)
        lines = [lines] unless lines.is_a?(Array)
        process_internal(lines)
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

      def join(lines, delimiter = ' ')
        text = ''
        (0..lines.length).each do |index|
          text += "#{lines[index]}#{delimiter if index < lines.length - 1}"
        end
        text
      end

      def wrap(lines, front, back)
        lines[0] = "#{front}#{lines[0].lstrip}"
        lines[lines.length - 1] = "#{lines[lines.length - 1].rstrip}#{back}"
        lines
      end

      def format_lines(lines)
        str = ''

        lines.each do |line|
          str += if line.empty?
                   "\n\n"
                 else
                   "#{line} "
                 end
        end

        str
      end

      private

      def process_lines(doc_comment)
        lines = []
        doc_comment.split("\n").each do |line|
          lines << line[1..-1].rstrip
        end

        indent = ' ' * min_indent(lines)
        lines.each do |line|
          line.sub!(indent, '')
        end

        lines.each do |line|
          if line.start_with?('@')
            process_annotation(line)
          else
            @lines << line
          end
        end
      end

      def process_annotation(text)
        annot = text.split(' ')[0][1..-1].to_sym
        return unless handlers.key?(annot)
        handler = handlers[annot]
        return if handler.nil?
        intern = text[1 + annot.length..-1].strip
        handler.call(intern)
      end

      def process_internal(lines)
        data = ProcessData.new
        data.level = 0
        data.intern = []
        data.final = []
        data.final_line = ''
        data.cache_final = ''
        data.cache_intern = []

        lines.each do |line|
          data = process_internal_line(line, data)
        end

        strip_empty_lines(data.final)
      end

      def process_internal_line(line, data)
        data.intern_line = ''
        data.activity = false
        line.each_char do |char|
          data = process_internal_char(char, data)
        end

        if data.level > 0
          data.intern << data.intern_line
        else
          if data.cache_intern.empty?
            data.final << data.final_line unless data.activity
          else
            len = data.cache_intern.length - 1
            data.cache_intern[len] = "#{data.cache_intern[len]}#{data.final_line}"
            data.final += data.cache_intern
          end
          data.cache_intern = []
          data.final_line = ''
        end

        data
      end

      def process_internal_char(char, data)
        if char == '{'
          data.cache_final = data.final_line
          data.final_line = ''
          data.intern_line += '{' if data.level > 0
          data.level += 1
        elsif char == '}'
          if data.level > 1
            data.intern_line += '}'
            data.level -= 1
          elsif data.level == 1
            data.activity = true
            data.intern << data.intern_line
            data.intern_line = ''
            data.cache_intern = int_annot_result(data.intern, data.cache_final)
            data.cache_final = ''
            data.intern = []
            data.level = 0
          end
        elsif data.level > 0
          data.intern_line += char
        else
          data.activity = false
          data.final_line += char
        end

        data
      end

      def int_annot_result(intern, cache_final)
        result = process_internal_annotation(intern)
        result = strip_empty_lines(result)
        result[0] = "#{cache_final}#{result[0] unless result.empty?}"
        result
      end

      def process_internal_annotation(lines)
        default_value = join(lines)
        return default_value unless !lines.empty? && lines[0].start_with?('@')
        annot = lines[0].split(' ')[0][1..-1].to_sym
        return default_value unless internal_handlers.key?(annot)
        handler = internal_handlers[annot]
        return default if handler.nil?
        lines[0] = lines[0][1 + annot.length..-1].strip
        result = handler.call(lines)
        result ||= []
        result
      end

      def min_indent(lines)
        indents = []

        lines.each do |line|
          indents << line[/\A */].size unless line.empty?
        end

        return indents.min unless indents.empty?
        0
      end

      def strip_empty_lines(lines)
        lines.shift if !lines.empty? && lines[0].empty?
        lines.pop if !lines.empty? && lines[lines.length - 1].empty?
        lines
      end
    end
  end
end
