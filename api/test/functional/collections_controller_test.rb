require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collections" do
    assert_difference('Collections.count') do
      post :create, :collections => { }
    end

    assert_redirected_to collections_path(assigns(:collections))
  end

  test "should show collections" do
    get :show, :id => collections(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collections(:one).id
    assert_response :success
  end

  test "should update collections" do
    put :update, :id => collections(:one).id, :collections => { }
    assert_redirected_to collections_path(assigns(:collections))
  end

  test "should destroy collections" do
    assert_difference('Collections.count', -1) do
      delete :destroy, :id => collections(:one).id
    end

    assert_redirected_to collections_path
  end
end
