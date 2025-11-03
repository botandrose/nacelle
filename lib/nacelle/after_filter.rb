require "active_support/xml_mini/nokogiri"
ActiveSupport::XmlMini.backend = "Nokogiri"
require "active_support/core_ext/hash"
# we need all this for Hash.from_xml

module Nacelle
  class AfterFilter < Struct.new(:controller)
    def self.after controller
      if controller.content_type&.include?("text/html")
        new(controller).call
      end
    end

    def call
      cells = cells controller.response.body
      return if cells.empty?

      controller.response.body = controller.response.body.gsub(/(#{cells.keys.join('|')})/) do |tag|
        name, action, attrs = cells[tag]
        action = action.to_sym
        attrs = HashWithIndifferentAccess.new(attrs)
        cell = "#{name.camelize}Cell".constantize.new_with_controller(controller)
        attrs.delete "class" # ignore styling class
        if cell.class.action_methods.include?(action)
          cell.action = action
          if cell.method(action).arity.zero? && attrs.empty?
            cell.send(action)
          else
            cell.send(action, attrs)
          end
        else
          "<strong>Cell “#{name.capitalize} #{action}” not found!</strong>"
        end
      end
    end

    private

    def cells html
      html.scan(/(<cell[^>]*\/\s*>|<cell[^>]*>.*?<\/cell>)/m).inject({}) do |cells, matches|
        tag = matches.first
        attrs = Hash.from_xml(tag)['cell']
        name, state = attrs.delete('name').split('/')
        cells[tag] = [name, state, attrs]
        cells
      end
    end
  end
end

