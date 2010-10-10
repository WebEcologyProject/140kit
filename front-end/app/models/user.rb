class User < ActiveRecord::Base
  has_many :tweets, :foreign_key => 'screen_name'
  belongs_to :datasets
  
  def self.language(language)
    language_map = {"en" => "English", "ja" => "Japanese", "it" => "Italian", "de" => "German", "fr" => "French", "kr" => "Korean", "es" => "Spanish"}
    return language_map[language]
  end
end
