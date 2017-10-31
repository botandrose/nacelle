require "rails/all"
require "cells"
require "nacelle/version"
require "nacelle/middleware"
require "nacelle/cells_ext"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      app.config.middleware.use Nacelle::Middleware
    end
  end
end
