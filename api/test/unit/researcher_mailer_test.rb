require 'test_helper'

class ResearcherMailerTest < ActionMailer::TestCase
  test "scrape_done" do
    @expected.subject = 'ResearcherMailer#scrape_done'
    @expected.body    = read_fixture('scrape_done')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ResearcherMailer.create_scrape_done(@expected.date).encoded
  end

end
