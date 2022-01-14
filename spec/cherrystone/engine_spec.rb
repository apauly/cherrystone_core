# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cherrystone do

  it 'is configurable' do
    Cherrystone.configure do |config|
      config.yay = 'baz'
    end

    expect(Cherrystone::Engine.config.yay).to eq 'baz'
  end

end
