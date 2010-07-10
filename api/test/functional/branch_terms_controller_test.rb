require 'test_helper'

class BranchTermsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:branch_terms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create branch_term" do
    assert_difference('BranchTerm.count') do
      post :create, :branch_term => { }
    end

    assert_redirected_to branch_term_path(assigns(:branch_term))
  end

  test "should show branch_term" do
    get :show, :id => branch_terms(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => branch_terms(:one).to_param
    assert_response :success
  end

  test "should update branch_term" do
    put :update, :id => branch_terms(:one).to_param, :branch_term => { }
    assert_redirected_to branch_term_path(assigns(:branch_term))
  end

  test "should destroy branch_term" do
    assert_difference('BranchTerm.count', -1) do
      delete :destroy, :id => branch_terms(:one).to_param
    end

    assert_redirected_to branch_terms_path
  end
end
