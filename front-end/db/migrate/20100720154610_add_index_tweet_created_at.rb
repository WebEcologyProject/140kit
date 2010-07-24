class AddIndexTweetCreatedAt < ActiveRecord::Migration
  def self.up
    add_index(:tweets, :created_at)
    add_index(:users, :created_at)
  end

  def self.down
  end
end
