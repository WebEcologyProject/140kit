class CreateBranchTerms < ActiveRecord::Migration
  def self.up
    create_table :branch_terms do |t|
      t.string :word
      t.integer :frequency
      t.integer :scrape_id
      t.integer :metadata_id
      t.string :instance_id
    end
  end

  def self.down
    drop_table :branch_terms
  end
end
