class Nacelle::CellsSerializer
  def as_json(*)
    { cells: cell_classes.flat_map(&method(:serialize)) }
  end

  private

  def serialize klass
    cell = klass.to_s.sub("Cell", "").underscore
    cell_name = cell.humanize

    klass.action_methods.map do |action|
      action_name = action.to_s.humanize
      {
        id:   "#{cell}/#{action}",
        name: "#{cell_name} #{action_name}",
      }
    end
  end

  def cell_classes
    @all ||= begin
      require_all_cells
      Nacelle::Cell.subclasses
    end
  end

  def require_all_cells
    # TODO pull in cells from engines, too
    cell_files = Dir[::Rails.root.join('app/cells/*.rb')]
    cell_files.each(&method(:require))
  end
end
