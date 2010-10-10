class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances do |t|
      t.string :uuid, :limit => 40
      t.string :hostname
      t.string :instance_name
      t.integer :pid
      t.boolean :killed, :default => false
      t.string :slug

      t.timestamps
    end
  end

  def self.down
    drop_table :instances
  end
end
