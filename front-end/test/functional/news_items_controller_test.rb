require 'test_helper'

class NewsItemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:news_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create news_item" do
    assert_difference('NewsItem.count') do
      post :create, :news_item => { }
    end

    assert_redirected_to news_item_path(assigns(:news_item))
  end

  test "should show news_item" do
    get :show, :id => news_items(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => news_items(:one).to_param
    assert_response :success
  end

  test "should update news_item" do
    put :update, :id => news_items(:one).to_param, :news_item => { }
    assert_redirected_to news_item_path(assigns(:news_item))
  end

  test "should destroy news_item" do
    assert_difference('NewsItem.count', -1) do
      delete :destroy, :id => news_items(:one).to_param
    end

    assert_redirected_to news_items_path
  end
end
