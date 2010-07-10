require 'test_helper'

class AnalyticalInstancesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analytical_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analytical_instance" do
    assert_difference('AnalyticalInstance.count') do
      post :create, :analytical_instance => { }
    end

    assert_redirected_to analytical_instance_path(assigns(:analytical_instance))
  end

  test "should show analytical_instance" do
    get :show, :id => analytical_instances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => analytical_instances(:one).to_param
    assert_response :success
  end

  test "should update analytical_instance" do
    put :update, :id => analytical_instances(:one).to_param, :analytical_instance => { }
    assert_redirected_to analytical_instance_path(assigns(:analytical_instance))
  end

  test "should destroy analytical_instance" do
    assert_difference('AnalyticalInstance.count', -1) do
      delete :destroy, :id => analytical_instances(:one).to_param
    end

    assert_redirected_to analytical_instances_path
  end
end
