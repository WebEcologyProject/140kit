class CreateResearchers < ActiveRecord::Migration
  def self.up
    create_table :researchers do |t|
      t.string :user_name
      t.string :email
      t.string :pass_hash
      t.string :pass_hash_confirm
      t.datetime :join_date
      t.string :last_login
      t.string :account
      t.datetime :last_access
      t.string :info
      t.string :avatar
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :researchers
  end
end
