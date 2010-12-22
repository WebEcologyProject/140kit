class AddNewFieldsToTweets < ActiveRecord::Migration
  def self.up
      add_column :tweets, :in_reply_to_user_id_str, :string
      add_column :tweets, :new_id, :integer
      add_column :tweets, :id_str, :string
      add_column :tweets, :new_id_str, :string
  end

  def self.down
    remove_column :tweets, :in_reply_to_user_id_str
    remove_column :tweets, :new_id
    remove_column :tweets, :id_str
    remove_column :tweets, :new_id_str
  end
end
