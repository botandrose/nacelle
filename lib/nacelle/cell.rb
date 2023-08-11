require "cells"

module Nacelle
  class Cell < Cell::Base
    self.view_paths += %w[app/cells app/views]

    def self.new_with_controller controller
      new.tap do |cell|
        cell.instance_variable_set :@request, controller.request
        cell.instance_variable_set :@session, controller.session
        cell.instance_variable_set :@cookies, controller.send(:cookies)
      end
    end

    def self.updated_at
      Time.new(2000) # can be overriden to bust caches
    end

    def self.cache_key
      to_s # can be overriden to bust caches
    end

    attr_accessor :request, :session, :cookies
  end
end

if Rails.version >= "6.1.0"
  Cell::Base::View.class_eval do
    def compiled_method_container
      ActionView::Base
    end
  end
end
