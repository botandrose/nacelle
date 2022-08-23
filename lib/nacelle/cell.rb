require "cells"

module Nacelle
  class Cell < Cell::Base
    self.view_paths += %w[app/cells app/views]
  end
end

if Rails.version >= "6.1.0"
  Cell::Base::View.class_eval do
    def compiled_method_container
      ActionView::Base
    end
  end
end
