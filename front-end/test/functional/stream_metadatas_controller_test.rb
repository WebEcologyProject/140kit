require 'test_helper'

class StreamMetadatasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_metadatas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_metadata" do
    assert_difference('StreamMetadata.count') do
      post :create, :stream_metadata => { }
    end

    assert_redirected_to stream_metadata_path(assigns(:stream_metadata))
  end

  test "should show stream_metadata" do
    get :show, :id => stream_metadatas(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => stream_metadatas(:one).to_param
    assert_response :success
  end

  test "should update stream_metadata" do
    put :update, :id => stream_metadatas(:one).to_param, :stream_metadata => { }
    assert_redirected_to stream_metadata_path(assigns(:stream_metadata))
  end

  test "should destroy stream_metadata" do
    assert_difference('StreamMetadata.count', -1) do
      delete :destroy, :id => stream_metadatas(:one).to_param
    end

    assert_redirected_to stream_metadatas_path
  end
end
