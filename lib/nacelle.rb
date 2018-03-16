require "nacelle/version"
require "action_controller/railtie"
require "nacelle/cell"
require "nacelle/middleware"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      app.config.middleware.use Nacelle::Middleware
    end
  end
end
