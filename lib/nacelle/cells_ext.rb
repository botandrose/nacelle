module Cell
  class << self
    def to_json
      cell_name = self.to_s.sub("Cell", "").underscore
      action_methods.map do |state|
        {
          id:   "#{cell_name}/#{state.to_s}",
          name: "#{cell_name.humanize} #{state.to_s.humanize}",
        }
      end
    end

    def all
      @all ||= begin
        require_all_cells
        BaseCell.subclasses
      end
    end

    private

    def require_all_cells
      # TODO pull in cells from engines, too
      cell_files = Dir[::Rails.root.join('app/cells/*.rb')]
      cell_files.each { |cell_file| require cell_file }
    end
  end
end
