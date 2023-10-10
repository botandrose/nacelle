require "nacelle/version"
require "action_controller/railtie"
require "sprockets/railtie"
require "nacelle/cell"
require "nacelle/has_cells"
require "nacelle/after_filter"

module Nacelle
  class Engine < ::Rails::Engine
    initializer "nacelle.init" do |app|
      ActionController::Base.after_action AfterFilter
      ActiveRecord::Base.extend HasCells if defined?(ActiveRecord)
    end

    initializer "nacelle.assets.precompile" do |app|
      app.config.assets.precompile += %w( 
        ckeditor/plugins/cells/icons/insertcell.png
      )
    end
  end
end
