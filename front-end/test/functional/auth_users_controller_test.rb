require 'test_helper'

class AuthUsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:auth_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create auth_user" do
    assert_difference('AuthUser.count') do
      post :create, :auth_user => { }
    end

    assert_redirected_to auth_user_path(assigns(:auth_user))
  end

  test "should show auth_user" do
    get :show, :id => auth_users(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => auth_users(:one).to_param
    assert_response :success
  end

  test "should update auth_user" do
    put :update, :id => auth_users(:one).to_param, :auth_user => { }
    assert_redirected_to auth_user_path(assigns(:auth_user))
  end

  test "should destroy auth_user" do
    assert_difference('AuthUser.count', -1) do
      delete :destroy, :id => auth_users(:one).to_param
    end

    assert_redirected_to auth_users_path
  end
end
