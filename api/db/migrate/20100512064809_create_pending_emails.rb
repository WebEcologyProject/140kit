class CreatePendingEmails < ActiveRecord::Migration
  def self.up
    create_table :pending_emails do |t|
      t.boolean :sent
      t.text :message_content
      t.string :recipient
      t.string :subject

      t.timestamps
    end
  end

  def self.down
    drop_table :pending_emails
  end
end
