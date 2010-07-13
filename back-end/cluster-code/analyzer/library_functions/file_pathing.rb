class FilePathing
  def self.tmp_folder(collection)
    $w.tmp_path = "../tmp_files/#{$w.session_hash}/#{collection.folder_name}/"
    `mkdir ../tmp_files/#{$w.session_hash}/`
    `mkdir ../tmp_files/#{$w.session_hash}/#{collection.folder_name}/`
  end

  def self.mysqldump(model, conditional, collection)
    `mysqldump -h #{Environment.host} -u #{Environment.username} --password='#{Environment.password}' --databases #{Environment.database} --tables #{model} --where='#{conditional}' > #{$w.tmp_path}/#{model}.sql`
  end

  def self.push_tmp_folder(sub_dir, folder=$w.tmp_path)
    raise "Can't navigate below Environment.storage path of #{Environment.storage_path} with sub_dir" if sub_dir.include?("..")
    folder = folder.chop if folder.split("").last == "/"
    sub_dir = sub_dir.chop if sub_dir.split("").last == "/"
    parent_dir, direct_dir = FilePathing.resolve_path_zip_name(folder)
    `zip -r -9 -j #{folder} #{folder}`
    final_path = "#{Environment.storage_path}/#{sub_dir}/".gsub("//", "/")
    FilePathing.make_directories(sub_dir)
    attempts = 0
    sent = false
    while !sent
      case Environment.storage_type
      when "local"
        attempt = "mv #{folder}.zip ../../#{final_path}"
        result = `#{attempt}`
        exception_message = "mkdir for #{attempt} failed after #{attempts+1} tries."
      when "remote"
        #This check actually fails since return of rsync message is ALWAYS empty string?
        attempt = "rsync -r #{folder}.zip #{Environment.storage_ssh}:#{final_path}"
        result = `#{attempt}`
        exception_message = "rsync for #{attempt} failed after #{attempts+1} tries."
      end
      sent = (result.empty? || !result.scan(/mkdir: cannot create directory `.*': File exists/).first.empty?)
      attempts+=1
      raise Exception, exception_message if attempts == ERROR_THRESHOLD
    end
    FilePathing.remove_folder(parent_dir)
  end
  
  def self.remove_folder(folder)
    `rm -r #{folder}`
  end
  
  def self.resolve_path_zip_name(folder)
    if folder.split("").last == "/"
      parent_dir = folder.scan(/^.*\//).first.chop
    else
      parent_dir = folder.chop.scan(/^.*\//).first.chop
    end
    direct_dir = folder.gsub(parent_dir, "").gsub("/", "")
    return parent_dir, direct_dir
  end
  
  def self.make_directories(dir_listing)
    dirs = []
    attempts = 0
    made = false
    dir_listing.split("/").each do |dir|
      while !made
        case Environment.storage_type
        when "local"
          attempt = "mkdir ../../#{Environment.storage_path}/#{dirs.join("/")+"/"+dir}"
          result = `#{attempt}`
        when "remote"
          attempt = "ssh #{Environment.storage_ssh} 'mkdir #{Environment.storage_path}/#{dirs.join("/")+"/"+dir}'"
          result = `#{attempt}`
        end
        made = (result.empty? || !result.scan(/mkdir: cannot create directory `.*': File exists/).first.empty?)
        dirs << dir
        attempts+=1
        raise Exception, "mkdir for #{attempt} failed after #{attempts} tries." if attempts == ERROR_THRESHOLD
      end
    end
  end
end