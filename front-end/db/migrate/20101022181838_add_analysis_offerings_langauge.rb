class AddAnalysisOfferingsLangauge < ActiveRecord::Migration
  def self.up
    add_column :analytical_offerings, :language, :string
  end

  def self.down
    remove_column :analytical_offerings, :language
  end
end
