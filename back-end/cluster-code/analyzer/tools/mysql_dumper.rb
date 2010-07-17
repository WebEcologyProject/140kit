def mysql_dumper(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  conditional = Analysis.conditional(collection).gsub("where", "").gsub("'","\"")
  FilePathing.tmp_folder(collection)
  FilePathing.mysqldump("tweets", conditional, collection)
  FilePathing.mysqldump("users", conditional, collection)
  FilePathing.push_tmp_folder(save_path)
  recipient = collection.researcher.email
  subject = "#{collection.researcher.user_name}, your raw data (SQL) for the #{collection.name} data set is complete."
  message_content = "Your SQL files are ready for download. You can grab them by clicking this link: <a href=\"http://140kit.com/files/raw_data/raw_sql/#{collection.folder_name}.zip\">http://140kit.com/files/raw_data/raw_sql/#{collection.folder_name}.zip</a>."
  send_email(recipient, subject, message_content, collection)
end
