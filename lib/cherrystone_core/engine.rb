# frozen_string_literal: true

require 'rails/engine'

module Cherrystone
  class << self
    def configure
      yield Engine.config
    end
  end

  class Engine < ::Rails::Engine
    config.renderer = nil
    config.inheritable_options = [:edit]
    config.default_node_class = 'Cherrystone::Node'
    config.custom_node_class_lookup = nil

    isolate_namespace Cherrystone

    config.after_initialize do
      ActiveSupport.run_load_hooks :cherrystone
    end

    def self.find_custom_node_class(name, constraint: nil)
      return constraint unless config.custom_node_class_lookup.respond_to?(:call)

      custom_node_class = config.custom_node_class_lookup.call name
      return constraint if custom_node_class.nil?

      # rubocop:disable Style/InverseMethods
      if constraint && !(custom_node_class < constraint)
        raise "Unspported custom class: #{custom_node_class} should inherit from #{constraint}"
      end
      # rubocop:enable Style/InverseMethods

      custom_node_class
    end

    def self.find_default_node_class(name)
      find_custom_node_class(name, constraint: config.default_node_class.constantize)
    end

  end
end
