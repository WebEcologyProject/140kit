class CreateCurations < ActiveRecord::Migration
  def self.up
    create_table :curations do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :curations
  end
end
