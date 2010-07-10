class News < ActiveRecord::Base
  belongs_to :researcher
  has_many :comments, :foreign_key => 'post_id'
  before_create :sluggify

  def sluggify
    self.slug = self.title.downcase.gsub(" ", "-").gsub(/[!\?\.\@\#\$\%\^\&\*\(\)\/\"\'\:\;\<\>\+\=]/, "") if self.slug.nil? || self.slug.empty?
  end
end
