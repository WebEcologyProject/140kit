class AddAnalysisFinishedToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :analysis_finished, :boolean
  end

  def self.down
    remove_colomn :datasets, :analysis_finished
  end
end
