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
        DocProcessor.register_internal_wrap_annotation(:code, '<code>', '</code>')

        # pre annotation
        DocProcessor.register_internal_annotation_handler(:pre) do |lines|
          str = '<pre><code'
          if lines[0].start_with?('@')
            css_class = lines[0].split(/\s/i)[0][1..-1]
            lines[0] = lines[0][css_class.length + 1..-1].strip
            str += " class=\"#{css_class}\""
          end
          str += '>'
          result = DocProcessor.process_internal_documentation(lines)
          str += DocProcessor.join(result, "\n")
          str += '</code></pre>'
          [str]
        end

        # quote annotation
        DocProcessor.register_internal_wrap_annotation(:quote, '<blockquote>', '</blockquote>')
      end

      def register_link_handlers
        # link annotation
        DocProcessor.register_internal_annotation_handler(:link) do |lines|
          link = lines[0].split(' ')[0]
          lines[0] = lines[0][link.length..-1].strip
          lines[0] = link if DocProcessor.join(lines).strip.empty?
          result = DocProcessor.process_internal_documentation(lines)
          DocProcessor.wrap(result, "<a href=\"#{link}\">", '</a>')
        end

        # see annotation
        DocProcessor.register_internal_annotation_handler(:see) do |lines|
          text = DocProcessor.join(lines)
          see_link = DocProcessor.see_links[text]
          link = ''
          if see_link.nil?
            puts "Unrecognized reference to #{text} found in '#{@file}'"
            link = '#'
          else
            link = see_link
          end

          ["<em>(see <a href=\"#{link}\">#{text}</a>)</em>"]
        end
      end

      def register_basic_handlers
        # param annotation
        DocProcessor.register_annotation_handler(:param) do |text|
          param = text.split(' ')[0]
          desc = text[param.length..-1].strip
          desc = DocProcessor.process_internal_documentation(desc)
          desc = DocProcessor.join(desc)

          DocProcessor.retrieve_with_default(:params, {})[param] = desc
        end

        # return annotation
        DocProcessor.register_direct_annotation(:return)

        # author annotation
        DocProcessor.register_direct_annotation(:author)

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
          [result]
        end
      end
    end
  end
end
