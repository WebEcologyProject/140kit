require 'test_helper'

class TweetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tweets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tweet" do
    assert_difference('Tweet.count') do
      post :create, :tweet => { }
    end

    assert_redirected_to tweet_path(assigns(:tweet))
  end

  test "should show tweet" do
    get :show, :id => tweets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tweets(:one).to_param
    assert_response :success
  end

  test "should update tweet" do
    put :update, :id => tweets(:one).to_param, :tweet => { }
    assert_redirected_to tweet_path(assigns(:tweet))
  end

  test "should destroy tweet" do
    assert_difference('Tweet.count', -1) do
      delete :destroy, :id => tweets(:one).to_param
    end

    assert_redirected_to tweets_path
  end
end
