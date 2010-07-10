require 'test_helper'

class GraphPointsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graph_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create graph_point" do
    assert_difference('GraphPoint.count') do
      post :create, :graph_point => { }
    end

    assert_redirected_to graph_point_path(assigns(:graph_point))
  end

  test "should show graph_point" do
    get :show, :id => graph_points(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => graph_points(:one).to_param
    assert_response :success
  end

  test "should update graph_point" do
    put :update, :id => graph_points(:one).to_param, :graph_point => { }
    assert_redirected_to graph_point_path(assigns(:graph_point))
  end

  test "should destroy graph_point" do
    assert_difference('GraphPoint.count', -1) do
      delete :destroy, :id => graph_points(:one).to_param
    end

    assert_redirected_to graph_points_path
  end
end
