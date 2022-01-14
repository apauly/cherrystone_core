# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cherrystone::ViewHelper, type: :helper do

  context '#cherrystone_renderer' do

    context 'with a proc' do
      before(:each) do
        Cherrystone.configure do |config|
          config.renderer = ->(view_context) {
            expect(view_context).to be_a ActionView::Base
            'Hello from lambda'
          }
        end
      end

      it 'returns renderer' do
        expect(helper.cherrystone_renderer).to eq 'Hello from lambda'
      end
    end

    context 'without a proc' do
      before(:each) do
        Cherrystone.configure do |config|
          config.renderer = 'RENDERER'
        end
      end

      it 'returns renderer' do
        expect(helper.cherrystone_renderer).to eq 'RENDERER'
      end
    end

  end

  context '#cherrystone_helper' do

    let(:test_renderer) { double }
    before(:each) do
      allow(test_renderer).to receive(:render) do |view_context, node|
        expect(view_context).to be_a ActionView::Base
        node
      end

      Cherrystone.configure do |config|
        config.renderer = test_renderer
      end
    end

    let(:custom_klass) do
      Class.new(Cherrystone::Node) do
        def title(a_title)
          append :title, a_title
        end
      end
    end

    it 'can add custom helpers' do
      Cherrystone::ViewHelper.cherrystone_helper some_helper_name: custom_klass
      result = helper.some_helper_name 'Bar', foo: :bar do
        title 'Foo'
      end

      expect(result).to eq helper.root_node
      expect(helper.root_node.name).to eq :some_helper_name
      expect(helper.root_node).to be_a custom_klass
      expect(helper.root_node.payload).to eq 'Bar'
      expect(helper.root_node.options).to include foo: :bar
      expect(helper.root_node.options).to include :controller
      expect(helper.root_node.find(:title)).to be_present
      expect(helper.root_node.find(:title).payload).to eq 'Foo'
    end

  end

end
