require 'test_helper'

class RestInstancesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rest_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rest_instance" do
    assert_difference('RestInstance.count') do
      post :create, :rest_instance => { }
    end

    assert_redirected_to rest_instance_path(assigns(:rest_instance))
  end

  test "should show rest_instance" do
    get :show, :id => rest_instances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => rest_instances(:one).to_param
    assert_response :success
  end

  test "should update rest_instance" do
    put :update, :id => rest_instances(:one).to_param, :rest_instance => { }
    assert_redirected_to rest_instance_path(assigns(:rest_instance))
  end

  test "should destroy rest_instance" do
    assert_difference('RestInstance.count', -1) do
      delete :destroy, :id => rest_instances(:one).to_param
    end

    assert_redirected_to rest_instances_path
  end
end
