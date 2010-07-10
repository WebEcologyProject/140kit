require 'test_helper'

class StreamInstancesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_instance" do
    assert_difference('StreamInstance.count') do
      post :create, :stream_instance => { }
    end

    assert_redirected_to stream_instance_path(assigns(:stream_instance))
  end

  test "should show stream_instance" do
    get :show, :id => stream_instances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => stream_instances(:one).to_param
    assert_response :success
  end

  test "should update stream_instance" do
    put :update, :id => stream_instances(:one).to_param, :stream_instance => { }
    assert_redirected_to stream_instance_path(assigns(:stream_instance))
  end

  test "should destroy stream_instance" do
    assert_difference('StreamInstance.count', -1) do
      delete :destroy, :id => stream_instances(:one).to_param
    end

    assert_redirected_to stream_instances_path
  end
end
