module Nacelle
  class Cell
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
      instance_methods - Class.new(superclass).instance_methods
    end

    def self.name
      to_s.underscore.sub("_cell","")
    end

    cattr_accessor(:view_path) { "app/cells" }
    attr_accessor :action

    def self.helper mod
    end

    def render template: nil
      template ||= "#{self.class.name}/#{action}"
      assigns = instance_variables.reduce({}) do |hash, key|
        new_key = key.to_s.split("@").last.to_sym
        value = instance_variable_get(key)
        hash.merge(new_key => value)
      end
      view_context = @controller.view_context.dup
      paths = view_context.lookup_context.view_paths + [view_path]
      view_context.lookup_context.instance_variable_set :@view_paths, paths
      view_context.assign assigns
      view_context.render template: template
    end
  end
end

