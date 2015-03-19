require 'test_helper'

class Admin::UnitsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @controller = Admin::UnitsController.new

    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end

  test "should get index" do
    get :index
    assert_response :success, "Could not render show all units page"
  end

  test "should get show unit" do
    get :show, id: 1
    assert_response :success, "Could not render show unit leaders page"
  end

  test "should get new" do
    get :new
    assert_response :success, "Could not render new unit page"
  end

  test "should get create" do
    assert_difference('Unit.count') do
      post :create, unit: {
        unit_name: "Test Unit",
        unit_code: "Test Unit Code",
        unit_year: "2015"
      }
    end

    assert_redirected_to admin_unit_path(assigns(:unit)), "Could not create unit and redirect to unit leaders page"
  end

  test "should get edit" do
    get :edit, id: 1
    assert_response :success, "Could not show edit page for unit 1"
  end

  test "should get update" do
    put :update, {
      id: 1,
      unit: {
        unit_name: "Test Unit",
        unit_code: "Test Unit Code",
        unit_year: "2015"
      }
    }

    assert_redirected_to admin_units_path, "Could not update unit 1 and redirect to all units"
  end

  test "should get destroy" do
    delete :destroy, id: 1
    assert_redirected_to admin_units_path, "Could not destroy unit 1 and redirect to all units"
  end

end
