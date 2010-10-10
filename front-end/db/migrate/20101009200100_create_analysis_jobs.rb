class CreateAnalysisJobs < ActiveRecord::Migration
  def self.up
    create_table :analysis_jobs do |t|
      t.string :function
      t.boolean :finished,    :default => false
      t.string :instance_id,  :limit => 40
      t.integer :dataset_id
      t.boolean :rest,        :default => false
      t.string :save_path

      t.timestamps
    end
  end

  def self.down
    drop_table :analysis_jobs
  end
end
