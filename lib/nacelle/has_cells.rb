module Nacelle
  module HasCells
    def has_cells *columns
      define_method :cells do
        columns.flat_map do |column|
          send(column).scan(/(<cell[^>]*\/\s*>|<cell[^>]*>.*?<\/cell>)/m).map do |matches|
            tag = matches.first
            attrs = Hash.from_xml(tag)['cell']
            name, _ = attrs.delete('name').split('/')
            "#{name.camelize}Cell".constantize
          end
        end
      end
    end
  end
end

