load "run.rb"
users = [
          {
            "name"=>"Luan's",
            "profile_sidebar_fill_color"=>"ffffff",
            "profile_sidebar_border_color"=>"000000",
            "profile_background_tile"=>true,
            "location"=>"Rio de Janeiro",
            "profile_image_url"=>"http://a3.twimg.com/profile_images/985402991/4cb61893-74a7-4ed7-9cd6-55ab11670986_normal.png",
            "created_at"=>DateTime.now,
            "profile_link_color"=>"0900ff",
            "metadata_id"=>5,
            # "instance_id"=>"",
            "url"=>"http://www.orkut.com.br/Main#Profile?rl=mp&uid=2163737690676948404",
            "favourites_count"=>3,
            "contributors_enabled"=>false,
            # "id"=>345,
            "utc_offset"=>-10800,
            # "flagged"=>false,
            "twitter_id"=>38754815,
            "protected"=>false,
            "followers_count"=>163,
            "profile_text_color"=>"050505",
            "lang"=>"en",
            "description"=>"",
            "profile_background_color"=>"000000",
            "time_zone"=>"Brasilia",
            "notifications"=>false,
            "geo_enabled"=>true,
            "verified"=>false,
            "friends_count"=>190,
            "profile_background_image_url"=>"http://a1.twimg.com/profile_background_images/111555284/ist2_4992070-sound-and-music-icons-black.jpg",
            "statuses_count"=>1127,
            "screen_name"=>"luan_bitch",
            "metadata_type"=>"Stream"
          },
          {
            "profile_sidebar_border_color"=>"87bc44",
            "name"=>"meizo farhana",
            "profile_sidebar_fill_color"=>"e0ff92",
            "profile_background_tile"=>false,
            "location"=>"~this planet~",
            "created_at"=>DateTime.now,
            "profile_image_url"=>"http://a3.twimg.com/profile_images/1010578859/5d0820a7-babe-44e1-8822-3a6d12d64826_normal.png",
            "metadata_id"=>5,
            "profile_link_color"=>"0000ff",
            "contributors_enabled"=>false,
            "favourites_count"=>0,
            "url"=>nil,
            "utc_offset"=>28800,
            "followers_count"=>6,
            "lang"=>"en",
            "profile_text_color"=>"000000",
            "protected"=>false,
            "twitter_id"=>150161960,
            "notifications"=>false,
            "description"=>"i love KPOP\r\n",
            "geo_enabled"=>true,
            "profile_background_color"=>"9ae4e8",
            "verified"=>false,
            "time_zone"=>"Kuala Lumpur",
            "statuses_count"=>55,
            "friends_count"=>91,
            "profile_background_image_url"=>"http://s.twimg.com/a/1277506381/images/themes/theme1/bg.png",
            "metadata_type"=>"Stream",
            "screen_name"=>"meizofarhana"
          }
        ]
        
puts users[0].keys - users[1].keys
puts users[0].length
puts users[1].length

puts "\n\nSAVING THE FIRST ALONE...\n\n"
Database.save_all({:users => [users.first]})

puts "\n\nSAVING THE LAST ALONE...\n\n"
Database.save_all({:users => [users.last]})
puts "\n\nSAVING ALL TOGETHER...\n\n"
Database.save_all({:users => users})

puts "\n\nLOADING THE WEBPAGE IN REVERSE...\n\n"
Database.save_all({:users => users.reverse})