require "nacelle/cells_serializer"

module Nacelle
  class CellsController < ApplicationController
    def index
      render json: CellsSerializer.new
    end
  end
end
