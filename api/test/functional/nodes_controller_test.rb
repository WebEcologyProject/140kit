require 'test_helper'

class EdgesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:edges)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create edge" do
    assert_difference('Edge.count') do
      post :create, :edge => { }
    end

    assert_redirected_to edge_path(assigns(:edge))
  end

  test "should show edge" do
    get :show, :id => edges(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => edges(:one).to_param
    assert_response :success
  end

  test "should update edge" do
    put :update, :id => edges(:one).to_param, :edge => { }
    assert_redirected_to edge_path(assigns(:edge))
  end

  test "should destroy edge" do
    assert_difference('Edge.count', -1) do
      delete :destroy, :id => edges(:one).to_param
    end

    assert_redirected_to edges_path
  end
end
