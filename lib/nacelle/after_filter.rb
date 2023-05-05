module Nacelle
  class AfterFilter < Struct.new(:controller)
    def self.after controller
      if controller.content_type&.include?("text/html")
        new(controller).call
      end
    end

    def call
      cells = cells controller.response.body

      controller.response.body.gsub!(/(#{cells.keys.join('|')})/) do |tag|
        name, state, attrs = cells[tag]
        attrs = HashWithIndifferentAccess.new(attrs)
        cell = "#{name.camelize}Cell".constantize.new_with_request(controller.request)
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

