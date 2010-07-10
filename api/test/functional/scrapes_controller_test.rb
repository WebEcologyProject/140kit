require 'test_helper'

class ScrapesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scrapes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scrape" do
    assert_difference('Scrape.count') do
      post :create, :scrape => { }
    end

    assert_redirected_to scrape_path(assigns(:scrape))
  end

  test "should show scrape" do
    get :show, :id => scrapes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => scrapes(:one).to_param
    assert_response :success
  end

  test "should update scrape" do
    put :update, :id => scrapes(:one).to_param, :scrape => { }
    assert_redirected_to scrape_path(assigns(:scrape))
  end

  test "should destroy scrape" do
    assert_difference('Scrape.count', -1) do
      delete :destroy, :id => scrapes(:one).to_param
    end

    assert_redirected_to scrapes_path
  end
end
