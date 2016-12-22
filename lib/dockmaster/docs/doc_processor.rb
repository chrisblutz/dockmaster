module Dockmaster
  # This class processes documentation comments into usable formats
  class DocProcessor
    class << self
      def process(doc_comment, file)
        @file = file

        @text = ''
        @params = {}
        @return = ''
        @author = ''

        process_lines(doc_comment)

        @text = process_internal(@text)

        Dockmaster::Docs.new(@text.strip, @params, @return, @author)
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
        annotation = text.split(' ')[0]

        case annotation
        when '@param'
          parse_param(text[annotation.length..-1].strip)
        when '@return'
          @return = process_internal(text[annotation.length..-1].strip)
        when '@author'
          @author = process_internal(text[annotation.length..-1].strip)
        end
      rescue
        abort "ERROR: Malformed @ doc annotation in '#{@file}'"
      end

      def parse_param(text)
        param = text.split(' ')[0]
        desc = text[param.length..-1].strip

        @params[param] = process_internal(desc)
      rescue
        abort "ERROR: Malformed @param doc annotation in '#{@file}'"
      end

      def process_internal(text)
        text.strip!
        text.gsub!("\n", '<br>')
        text
      rescue
        abort "ERROR: Malformed documentation in '#{@file}'"
      end
    end
  end
end
