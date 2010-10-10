class AddResearcherIdToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :researcher_id, :integer
  end

  def self.down
    remove_column :curations, :researcher_id
  end
end
