require 'test_helper'

class Admin::LecturesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @controller = Admin::LecturesController.new

    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    assert_difference('Lecture.count') do
      post :create, lecture: {
        lecture_name: "Test Lecture",
        lecture_type: "lecture",
        lecture_room: "E403",

        attendance_expected: 0,
        attendance_actual: 0,

        start_time: Time.now.beginning_of_hour,
        end_time: Time.now.beginning_of_hour + 1.hour,

        unit_id: 1,
        user_id: 2
      }
    end

    assert_redirected_to admin_lectures_path
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get add" do
    get :add
    assert_response :success
  end

  test "should get attendance" do
    get :attendance
    assert_response :success
  end

  test "should get download" do
    get :download
    assert_response :success
  end

end
