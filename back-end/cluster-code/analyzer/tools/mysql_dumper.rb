def mysql_dumper(curation_id, save_path)
  curation = Curation.find({:id => curation_id})
  conditional = Analysis.conditional(curation).gsub("where", "").gsub("'","\"")
  FilePathing.tmp_folder(curation)
  FilePathing.mysqldump("tweets", conditional)
  FilePathing.mysqldump("users", conditional)
  FilePathing.push_tmp_folder(save_path)
  # recipient = collection.researcher.email
  # subject = "#{collection.researcher.user_name}, your raw data (SQL) for the #{collection.name} data set is complete."
  # message_content = "Your SQL files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://nutmegunit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://nutmegunit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
  # send_email(recipient, subject, message_content, collection)
end
