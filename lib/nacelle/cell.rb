require "cells"

module Nacelle
  class Cell < Cell::Base
    self.view_paths += %w[app/cells app/views]

    def self.new_with_controller controller
      new.tap do |cell|
        cell.instance_variable_set :@controller, controller
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

    attr_reader :request, :session, :cookies

    delegate :perform_caching, :read_fragment, :write_fragment, to: :@controller

    def self.action_methods
      super - %w[
        cookies
        request
        session
        read_fragment
        write_fragment
        perform_caching
      ]
    end
  end
end

if Rails.version >= "6.1.0"
  Cell::Base::View.class_eval do
    def compiled_method_container
      ActionView::Base
    end

    def view_cache_dependencies
      []
    end
  end
end
