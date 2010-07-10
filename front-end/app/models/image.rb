class Image < ActiveRecord::Base
  belongs_to :projects
  belongs_to :posts
  belongs_to :researcher
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 2.megabytes,
                 :resize_to => '900x700>',
                 :thumbnails => { :thumb => '200x200', :geometry => 'x10' }
  validates_as_attachment
end
