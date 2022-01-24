# frozen_string_literal: true

module Cherrystone
  class Node

    attr_reader :name, :payload, :children
    attr_accessor :parent, :options

    def initialize(name, payload=nil, options=nil)
      @name = name
      @payload = payload
      @options = options || {}
      @children = []
    end

    def run(&block)
      return unless block

      Docile.dsl_eval(self, &block)
    end

    def append(name, payload=nil, options=nil, &block)
      node = if name.is_a?(Node)
        name
      else
        default_node_klass = Cherrystone::Core.find_default_node_class(name)
        default_node_klass.new(name, payload, options)
      end

      node.options = apply_inheritable_options(node.options)
      node.parent = self
      node.run(&block)
      self.children << node

      node
    end

    def root?
      self.parent.nil?
    end

    def root
      return self if root?

      self.parent.root
    end

    # find any children matching the given name
    def find(name)
      self.children.detect {|node| node.name == name }
    end

    # find all children matching the given name
    def find_all(name_or_options)
      options = if name_or_options.is_a? Hash
        name_or_options
      else
        { only: name_or_options }
      end

      self.children.select {|node|
        (!options[:only] || Array.wrap(options[:only]).include?(node.name)) &&
        (!options[:except] || !Array.wrap(options[:except]).include?(node.name))
      }
    end

    def find_recursive(name_or_options)
      [
        find_all(name_or_options),
        *self.children.map {|child_node| child_node.find_recursive(name_or_options) }
      ].flatten
    end

    def inspect
      # avoid printing parents / children
      "#<#{self.class} @name=#{@name.inspect} @options=#{@options.inspect} @payload=#{@payload.inspect}>"
    end

    def node_class(name, expected_parent_klass)
      Cherrystone::Core.find_custom_node_class(name, constraint: expected_parent_klass)
    end

    # walk through the current tree and return the first matching option - from deep to shallow
    def find_option(name)
      return parent&.find_option(name) unless self.options.key?(name)

      self.options[name]
    end

    def apply_inheritable_options(options=nil)
      (options || {}).merge self.options.slice(*Cherrystone::Engine.config.inheritable_options)
    end

    def prepare(view_context)
      # allow subclasses to do fancy stuff before a node is rendered
    end

  end
end
