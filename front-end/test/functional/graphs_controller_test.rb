require 'test_helper'

class GraphsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graphs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create graph" do
    assert_difference('Graph.count') do
      post :create, :graph => { }
    end

    assert_redirected_to graph_path(assigns(:graph))
  end

  test "should show graph" do
    get :show, :id => graphs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => graphs(:one).to_param
    assert_response :success
  end

  test "should update graph" do
    put :update, :id => graphs(:one).to_param, :graph => { }
    assert_redirected_to graph_path(assigns(:graph))
  end

  test "should destroy graph" do
    assert_difference('Graph.count', -1) do
      delete :destroy, :id => graphs(:one).to_param
    end

    assert_redirected_to graphs_path
  end
end
