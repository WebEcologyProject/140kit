class AnalysisFinishedDefaultToTrue < ActiveRecord::Migration
  def self.up
    change_column :datasets, :analysis_finished, :boolean, :default => false
  end

  def self.down
    change_column :datasets, :analysis_finished, :boolean
  end
end
