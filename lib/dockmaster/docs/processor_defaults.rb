require 'dockmaster/docs/doc_processor'
require 'dockmaster/docs/ext_loader_registry'

require 'dockmaster/docs/external_loaders/html_loader'
require 'dockmaster/docs/external_loaders/txt_loader'

module Dockmaster
  # This class handles default handlers, etc. for the documentation processor
  class ProcessorDefaults
    class << self
      attr_reader :loaded

      def register_internals
        return if @loaded
        register_basic_handlers

        register_code_handlers
        register_link_handlers

        register_external_loaders

        @loaded = true
      end

      private

      def register_code_handlers
        # code annotation
        DocProcessor.register_internal_annotation_handler(:code) do |text|
          "<code>#{DocProcessor.process_internal_documentation(text)}</code>"
        end

        # quote annotation
        DocProcessor.register_internal_annotation_handler(:quote) do |text|
          "<blockquote>#{DocProcessor.process_internal_documentation(text)}</blockquote>"
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

        # api annotation
        DocProcessor.register_annotation_handler(:api) do |text|
          sym = text.to_sym
          DocProcessor.set(:api, sym)
        end
      end

      def register_external_loaders
        ExtLoaderRegistry.register(HTMLLoader)
        ExtLoaderRegistry.register(TXTLoader)

        # ext annotation
        DocProcessor.register_internal_annotation_handler(:ext) do |text|
          result = ExtLoaderRegistry.load(File.join(Dir.pwd, text))
          result
        end
      end
    end
  end
end
