require "nacelle/version"
require "action_controller/railtie"
require "sprockets/railtie"
require "nacelle/cell"
require "nacelle/after_filter"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      ActionController::Base.after_action AfterFilter
    end

    initializer "nacelle.assets.precompile" do |app|
      app.config.assets.precompile += %w( 
        ckeditor/plugins/cells/icons/insertcell.png
      )
    end
  end
end
