class AddHiddenBooleanResearchers < ActiveRecord::Migration
  def self.up
    add_column :researchers, :hidden_account, :boolean
  end

  def self.down
    remove_column :researchers, :hidden_account
  end
end
