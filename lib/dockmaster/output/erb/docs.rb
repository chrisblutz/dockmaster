require 'dockmaster/output/prettify/pretty_docs'
require 'dockmaster/output/raw/raw_docs'

module Dockmaster
  # Represents the documentation
  # to be passed to the ERB templates
  class Docs
    def intialize(doc_str)
      @doc_str = doc_str
    end

    def raw
      @raw_docs ||= RawDocs.format(@doc_str)
    end

    def pretty
      @pretty_docs ||= PrettyDocs.format(@doc_str)
    end
  end
end
