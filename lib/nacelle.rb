require "nacelle/version"
require "rails/all"
require "cells"
require "cells_ext"
require "output_filter/cells"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      app.config.middleware.use OutputFilter::Cells
    end
  end
end
