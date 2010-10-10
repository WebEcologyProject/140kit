class RenameAnalysisFinishedToAnalyzed < ActiveRecord::Migration
  def self.up
    rename_column :datasets, :analysis_finished, :analyzed
  end

  def self.down
    rename_column :datasets, :analyzed, :analysis_finished
  end
end
