terms3 = ["#nowplaying", "#Welcometonigeria", "#YouBigDummy", "#theresnothinglike", "OMGDUVALFACT"]
terms2 = ["#Joick", "#KushandOrangeJuice", "#DontTryToRoastIf", "Social", "Party"]
def testest(term, time)
scrape = Scrape.new({:name => term, :researcher_id => 1, :length => time, :created_at => Time.now, :updated_at => Time.now, :scrape_type => "search", :instance_id => ""}).save
scrape_id = Scrape.find({:name => term, :researcher_id => 1, :length => time}).id
scrape_metadata = StreamMetadata.new({:previous_priority => 200, :current_priority => 100, :scrape_id => scrape_id, :term => term, :sanitized_term => term.gsub(" ", "").gsub("#", "")}).save
end
terms3.each do |term|
testest(term, rand(1000)+6000)
end
terms2.each do |term|
testest(term, rand(1000)+6000)
end