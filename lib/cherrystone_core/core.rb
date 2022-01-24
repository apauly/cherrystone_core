# frozen_string_literal: true

module Cherrystone
  module Core
  
    def self.find_custom_node_class(name, constraint: nil)
      return constraint unless Engine.config.custom_node_class_lookup.respond_to?(:call)

      custom_node_class = Engine.config.custom_node_class_lookup.call name
      return constraint if custom_node_class.nil?

      # rubocop:disable Style/InverseMethods
      if constraint && !(custom_node_class < constraint)
        raise "Unspported custom class: #{custom_node_class} should inherit from #{constraint}"
      end
      # rubocop:enable Style/InverseMethods

      custom_node_class
    end

    def self.find_default_node_class(name)
      find_custom_node_class(name, constraint: Engine.config.default_node_class.constantize)
    end

  end
end
