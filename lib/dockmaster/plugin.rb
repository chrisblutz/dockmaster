require 'dockmaster/plugins/manager'

module Dockmaster
  # This class represents a plugin for Dockmaster.  It is intented to be
  # extended in subclasses.
  class Plugin
    class << self
      def loaded
        @subclasses ||= []
      end

      def managers
        @managers ||= {}
      end

      def plugins_by_id
        @plugins_by_id ||= {}
      end

      def inherited(other)
        loaded << other
      end

      def load_plugins
        loaded.each do |plugin|
          plugin_id = plugin.id if plugin.respond_to?(:id)
          plugin_id ||= plugin.name
          plugins_by_id[plugin_id] = plugin

          manager = Dockmaster::Manager.new(plugin_id)
          managers[plugin] = manager

          next unless plugin.respond_to?(:load)
          plugin.load(manager)
        end
      end

      def fire_event(event, *args)
        managers.each do |_, manager|
          handler = manager[event]
          next if handler.nil?
          next unless handler.respond_to?(event)
          handler.send(event, *args)
        end
      end

      def fire_misc_generation(master_store, base_renderer)
        loaded.each do |plugin|
          root = plugin.gem_source if plugin.respond_to?(:gem_source)
          root ||= File.join(__FILE__, '../../')
          output = Dockmaster::Output.new(base_renderer, root)
          next unless plugin.respond_to?(:misc_generation)
          plugin.misc_generation(master_store, output)
        end
      end
    end
  end
end
