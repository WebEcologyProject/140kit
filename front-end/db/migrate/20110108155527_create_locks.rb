class CreateLocks < ActiveRecord::Migration
  def self.up
    create_table :locks do |t|
      t.string :classname
      t.integer :with_id
      t.string :instance_id, :limit => 40

      t.timestamps
    end
    add_index "locks", ["classname", "with_id"], :name => "classname_with_id", :unique => true
  end

  def self.down
    drop_table :locks
  end
end