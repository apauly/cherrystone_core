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

    # Walk through the current tree and return the first matching option - from deep to shallow.
    #
    # This will return nil if the key is not found or if the key is given but nil. In order to handle this,
    # you can pass a block which will only be called if the key is not found at all.
    def find_option(name, &fallback_block)
      return self.options[name] if self.options.key?(name)

      if parent
        parent.find_option(name, &fallback_block)
      else
        fallback_block&.call
      end
    end

    def apply_inheritable_options(options=nil)
      inheritable_options = self.options.slice(*Cherrystone::Engine.config.inheritable_options)
      inheritable_options.merge!(options) if options
      inheritable_options
    end

    def prepare(view_context)
      # allow subclasses to do fancy stuff before a node is rendered
    end

  end
end
