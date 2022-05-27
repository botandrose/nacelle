require "nacelle/version"
require "action_controller/railtie"
require "sprockets/railtie"
require "nacelle/cell"
require "nacelle/middleware"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      app.config.middleware.use Nacelle::Middleware
    end

    initializer "nacelle.assets.precompile" do |app|
      app.config.assets.precompile += %w( 
        ckeditor/plugins/cells/icons/insertcell.png
      )
    end
  end
end
