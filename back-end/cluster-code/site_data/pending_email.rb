class PendingEmail < SiteData
  attr_accessor :sent, :id, :recipient, :message_content, :subject
end