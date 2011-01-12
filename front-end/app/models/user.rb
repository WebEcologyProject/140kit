class User < ActiveRecord::Base
  has_many :tweets, :foreign_key => 'screen_name'
  belongs_to :datasets
  
  validates_uniqueness_of :screen_name
  validates_uniqueness_of :twitter_id
  
  def self.language(language)
    language_map = {"en" => "English", "ja" => "Japanese", "it" => "Italian", "de" => "German", "fr" => "French", "kr" => "Korean", "es" => "Spanish"}
    return language_map[language]
  end
end
