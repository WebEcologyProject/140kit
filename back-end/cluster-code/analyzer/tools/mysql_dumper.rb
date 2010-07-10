def mysql_dumper(collection_id)
  collection = Collection.find({:id => collection_id})
  conditional = Analysis.conditional(collection).gsub("where", "").gsub("'","\"")
  session_hash = Digest::SHA1.hexdigest(Time.ntp.to_s+rand(100000).to_s)
  hostname, user, password, database = determine_environment
  `mkdir ../tmp_files/#{session_hash}/`
  `mkdir ../tmp_files/#{session_hash}/#{collection.folder_name}`
  `mysqldump -h #{hostname} -u #{user} --password='#{password}' --databases #{database} --tables users --where='#{conditional}' > ../tmp_files/#{session_hash}/#{collection.folder_name}/users.sql`
  `mysqldump -h #{hostname} -u #{user} --password='#{password}' --databases #{database} --tables tweets --where='#{conditional}' > ../tmp_files/#{session_hash}/#{collection.folder_name}/tweets.sql`
  `zip -r -9 -j ../tmp_files/#{session_hash}/#{collection.folder_name} ../tmp_files/#{session_hash}/#{collection.folder_name}`
  `rsync -r ../tmp_files/#{session_hash}/#{collection.folder_name}.zip #{SQL_ADDRESS}`
  `rm -r ../tmp_files/#{session_hash}`
  if !collection.single_dataset
    recipient = collection.researcher.email
    subject = "#{collection.researcher.user_name}, your raw data (SQL) for the #{collection.name} data set is complete."
    message_content = "Your SQL files are ready for download. You can grab them by clicking this link: <a href=\"http://140kit.com/files/raw_data/raw_sql/#{collection.folder_name}.zip\">http://140kit.com/files/raw_data/raw_sql/#{collection.folder_name}.zip</a>."
    email = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  end
end

def determine_environment
  case ENVIRONMENT
  when "production"
    settings = Environment.read_from_config("production")
    return settings["hostname"], settings["user"], settings["password"], settings["database"]
  when "testing"
    settings = Environment.read_from_config("testing")
    return settings["hostname"], settings["user"], settings["password"], settings["database"]
  when "development"
    settings = Environment.read_from_config("development")
    return settings["hostname"], settings["user"], settings["password"], settings["database"]
  end
end