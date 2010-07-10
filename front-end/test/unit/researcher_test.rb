require File.dirname(__FILE__) + '/../test_helper'

class ResearcherTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :researchers

  def test_should_create_researcher
    assert_difference Researcher, :count do
      researcher = create_researcher
      assert !researcher.new_record?, "#{researcher.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference Researcher, :count do
      u = create_researcher(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference Researcher, :count do
      u = create_researcher(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference Researcher, :count do
      u = create_researcher(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference Researcher, :count do
      u = create_researcher(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    researchers(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal researchers(:quentin), Researcher.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    researchers(:quentin).update_attributes(:login => 'quentin2')
    assert_equal researchers(:quentin), Researcher.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_researcher
    assert_equal researchers(:quentin), Researcher.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    researchers(:quentin).remember_me
    assert_not_nil researchers(:quentin).remember_token
    assert_not_nil researchers(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    researchers(:quentin).remember_me
    assert_not_nil researchers(:quentin).remember_token
    researchers(:quentin).forget_me
    assert_nil researchers(:quentin).remember_token
  end

  protected
    def create_researcher(options = {})
      Researcher.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
