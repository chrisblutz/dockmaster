module Dockmaster
  class SiteBinding
    def initialize(master_store, store, renderer)
      @master_store = master_store
      @store = store
      @renderer = renderer
    end

    attr_reader :store

    def render
      @renderer.result(@store.erb_binding)
    end

    def list_all
      puts @master_store.inspect

      str = ''
      @master_store.children.each do |c|
        str += create_list(c)
      end

      str.rstrip!

      puts str
      str
    end

    def erb_binding
      binding
    end

    private

    def create_list(store)
      str = '<a id="lc-list" href="'
      str += "/#{store.path}.html"
      str += '">'
      str += store.rb_string
      str += "</a>\n"

      store.children.each do |c|
        str += create_list(c)
      end

      str
    end
  end
end
