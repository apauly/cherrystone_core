# frozen_string_literal: true

module Cherrystone
  module ViewHelper

    class DuplicateRootNodeRendered < StandardError; end

    def cherrystone_renderer
      @cherrystone_renderer ||= begin
        renderer_or_proc = Cherrystone::Engine.config.renderer
        if renderer_or_proc.respond_to?(:call)
          renderer_or_proc.call(self)
        else
          renderer_or_proc
        end
      end
    end

    def cherrystone_node(node, *args, &block)
      node.prepare(self) if node.respond_to? :prepare
      cherrystone_renderer.render self, node, *args, &block
    end

    def cherrystone_partial(*args, &block)
      cherrystone_renderer.partial self, *args, &block
    end

    def cherrystone_root_node(name, node_klass, *args, &block)
      payload, options = *args
      options ||= {}
      options[:controller] = controller

      if @root_node && Cherrystone::Engine.config.raise_on_duplicate_root_nodes
        raise DuplicateRootNodeRendered, <<~MSG
          Tried to render "#{name}" as a root node, but "#{@root_node.name}" has already been rendered as a root node
        MSG
      end

      custom_node_class = Cherrystone::Core.find_custom_node_class(name, constraint: node_klass)
      custom_node_class ||= node_klass

      @root_node = custom_node_class.new(name, payload, options)
      @root_node.run(&block) if block

      cherrystone_node @root_node
    end

    module ClassMethods
      attr_accessor :cherrystone_helpers

      def included(base)
        base.attr_reader :root_node
      end

      def cherrystone_helper(mapping)
        Cherrystone::ViewHelper.cherrystone_helpers ||= {}
        mapping.each_pair do |name, node_klass|

          Cherrystone::ViewHelper.cherrystone_helpers[name] = node_klass

          # TODO: Sanity check to avoid overriding existing methods
          define_method name do |*args, &block|
            cherrystone_root_node(name, node_klass, *args, &block)
          end

        end
      end

    end
    extend ClassMethods

  end
end
