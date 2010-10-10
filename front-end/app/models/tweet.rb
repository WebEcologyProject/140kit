class Tweet < ActiveRecord::Base
  belongs_to :stream_metadata, :foreign_key => "metadata_id"
  belongs_to :users
  belongs_to :datasets
  
  def self.source(source)
    if source.include?("</a>")
      source = source.scan(/>(.*)</)[0][0]
    end
    return source.gsub("\"", "\\\"")
  end

  def self.language(language)
    language_map = {"en" => "English", "ja" => "Japanese", "it" => "Italian", "de" => "German", "fr" => "French", "kr" => "Korean", "es" => "Spanish"}
    return language_map[language]
  end

end
