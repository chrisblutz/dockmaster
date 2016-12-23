require 'dockmaster/docs/doc_processor'

module Dockmaster
  # This class handles default handlers, etc. for the documentation processor
  class ProcessorDefaults
    class << self
      def register_internals
        register_basic_handlers

        register_code_handlers
        register_link_handlers
      end

      private

      def register_code_handlers
        # code annotation
        DocProcessor.register_internal_annotation_handler(:code) do |text|
          "<code>#{DocProcessor.process_internal_documentation(text)}</code>"
        end
      end

      def register_link_handlers
        # link annotation
        DocProcessor.register_internal_annotation_handler(:link) do |text|
          link = text.split(' ')[0]
          text = text[link.length..-1].strip
          text = link if text.empty?
          "<a href=\"#{link}\">#{DocProcessor.process_internal_documentation(text)}</a>"
        end

        # see annotation
        DocProcessor.register_internal_annotation_handler(:see) do |text|
          see_link = DocProcessor.see_links[text]
          link = ''
          if see_link.nil?
            puts "Unrecognized reference to #{text} found in '#{@file}'"
            link = '#'
          else
            link = see_link
          end

          "<em>(see <a href=\"#{link}\">#{text}</a>)</em>"
        end
      end

      def register_basic_handlers
        # param annotation
        DocProcessor.register_annotation_handler(:param) do |text|
          param = text.split(' ')[0]
          desc = text[param.length..-1].strip
          desc = DocProcessor.process_internal_documentation(desc)

          DocProcessor.retrieve_with_default(:params, {})[param] = desc
        end

        # return annotation
        DocProcessor.register_annotation_handler(:return) do |text|
          processed = DocProcessor.process_internal_documentation(text)
          DocProcessor.set(:return, processed)
        end

        # author annotation
        DocProcessor.register_annotation_handler(:author) do |text|
          processed = DocProcessor.process_internal_documentation(text)
          DocProcessor.set(:author, processed)
        end
      end
    end
  end
end
