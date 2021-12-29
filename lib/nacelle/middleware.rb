require "active_support/xml_mini/nokogiri"
ActiveSupport::XmlMini.backend = "Nokogiri"

require "active_support/core_ext/hash"

module Nacelle
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      status, headers, body = @app.call env
      return [status, headers, body] unless headers["Content-Type"].try(:include?, "text/html")

      new_body = ""
      body.each { |part| new_body << part }
      process! new_body
      headers["Content-Length"] = new_body.length.to_s
      [status, headers, [new_body]]
    end

    private

    def process! body
      cells = cells body

      body.gsub!(/(#{cells.keys.join('|')})/) do |tag|
        name, state, attrs = cells[tag]
        attrs = HashWithIndifferentAccess.new(attrs)
        cell = "#{name.camelize}Cell".constantize.new
        args = [state]
        attrs.delete "class" # ignore styling class
        args << attrs unless attrs.empty?
        begin
          cell.render_state *args
        rescue AbstractController::ActionNotFound
          "<strong>Cell “#{name.capitalize} #{state}” not found!</strong>"
        end
      end unless cells.empty?
    end

    def cells body
      body.scan(/(<cell[^>]*\/\s*>|<cell[^>]*>.*?<\/cell>)/m).inject({}) do |cells, matches|
        tag = matches.first
        attrs = Hash.from_xml(tag)['cell']
        name, state = attrs.delete('name').split('/')
        cells[tag] = [name, state, attrs]
        cells
      end
    end
  end
end
