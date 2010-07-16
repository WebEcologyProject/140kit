class AddFulltextIndexTweets < ActiveRecord::Migration
  def self.up
    execute('ALTER TABLE tweets ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX text ON tweets (text(500))')
  end

  def self.down
    execute('ALTER TABLE table ENGINE = innoDB')
    execute('DROP FULLTEXT INDEX ON tweets.text')
  end
end
