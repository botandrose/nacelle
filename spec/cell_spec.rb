require "spec_helper"

class UndatedCell < Nacelle::Cell
end

class DatedCell < Nacelle::Cell
  class << self
    attr_writer :updated_at

    def updated_at
      @updated_at || super
    end
  end
end

describe Nacelle::Cell do
  describe ".cache_key" do
    it "falls back to the base timestamp when a cell declares none" do
      expect(UndatedCell.cache_key).to eq "UndatedCell/#{Time.new(2000).to_i}"
    end

    it "tracks updated_at, so etags bust when the cell's content changes" do
      DatedCell.updated_at = Time.utc(2026, 7, 25)
      expect {
        DatedCell.updated_at = Time.utc(2026, 7, 29)
      }.to change { DatedCell.cache_key }
    end
  end
end
