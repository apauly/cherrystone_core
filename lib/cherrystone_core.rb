# frozen_string_literal: true

require 'rails'

require 'cherrystone_core/version'
require 'cherrystone_core/core'
require 'cherrystone_core/node'
require 'cherrystone_core/view_helper'

require 'docile'

module Cherrystone
end

ActiveSupport.run_load_hooks :cherrystone_core
