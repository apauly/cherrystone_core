# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cherrystone::Node do

  let(:node_subclass) {
    Class.new(Cherrystone::Node) do
      def add_self_as_child(identifier, payload, &block)
        append self.class.new(identifier, payload), &block
      end

      def something(body)
        append :something, body
      end
    end
  }

  let(:root_node) {
    node_subclass.new(:root)
  }

  it 'builds an AST' do
    root_node.add_self_as_child :yay, 'Yay' do
      add_self_as_child :item, 'item 1'
      add_self_as_child :other_item, 'something else'
      add_self_as_child :item, 'item 2' do
        add_self_as_child :item, 'item 3'
        something 'Baz'
      end
    end

    expect(root_node.find(:yay).payload).to eq 'Yay'
    expect(root_node.find_all(:yay).length).to eq 1
    expect(root_node.find_all(:item).length).to eq 0

    expect(root_node.find(:yay).children.length).to eq 3
    expect(root_node.find(:yay).find_all(except: :item).length).to eq 1
    expect(root_node.find(:yay).find_all(except: :item).first.payload).to eq 'something else'
    expect(root_node.find(:yay).find_all(:item).length).to eq 2
    expect(root_node.find(:yay).find(:item).payload).to eq 'item 1'
    expect(root_node.find(:yay).find_all(:item).last.find(:item).payload).to eq 'item 3'
    expect(root_node.find(:yay).find_all(:item).last.find(:something).payload).to eq 'Baz'
  end

end
