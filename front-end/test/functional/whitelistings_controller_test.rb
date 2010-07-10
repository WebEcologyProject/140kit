require 'test_helper'

class WhitelistingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:whitelistings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create whitelisting" do
    assert_difference('Whitelisting.count') do
      post :create, :whitelisting => { }
    end

    assert_redirected_to whitelisting_path(assigns(:whitelisting))
  end

  test "should show whitelisting" do
    get :show, :id => whitelistings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => whitelistings(:one).to_param
    assert_response :success
  end

  test "should update whitelisting" do
    put :update, :id => whitelistings(:one).to_param, :whitelisting => { }
    assert_redirected_to whitelisting_path(assigns(:whitelisting))
  end

  test "should destroy whitelisting" do
    assert_difference('Whitelisting.count', -1) do
      delete :destroy, :id => whitelistings(:one).to_param
    end

    assert_redirected_to whitelistings_path
  end
end
