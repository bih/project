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

  test "should get lecture on day" do
    get :on_day
    assert_response :success
  end

  test "should get new lecture" do
    get :new
    assert_response :success
  end

  test "should create lecture" do
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
    get :edit, id: 1
    assert_response :success
  end

  test "should update lecture" do
    put :update, {
      id: 1,
      lecture: {
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
    }

    assert_redirected_to admin_unit_lectures_path(assigns(:lecture))
  end

  test "should destroy lecture" do
    delete :destroy, id: 1
    assert_redirected_to admin_lectures_path
  end

  test "should get lecture" do
    get :show, id: 1
    assert_response :success
  end

  test "should post add student" do
    post :add_student, {
      lecture_id: 1,
      lecture_student: {
        user_id: 3
      }
    }

    assert_redirected_to admin_lecture_path(1)
  end

  test "should post copy students" do
    post :copy_students, {
      lecture_id: 1,
      lecture_to_copy_id: 2
    }

    assert_redirected_to admin_lecture_path(1)
  end

  test "should post remove student from lecture" do
    post :remove_student, {
      lecture_id: 1,
      id: 1
    }

    assert_redirected_to admin_lecture_path(1)
  end

  test "should get lecture register" do
    get :register, lecture_id: 1
    assert_response :success
  end

  test "should post register student for lecture" do
    post :register_student, {
      lecture_id: 1,
      student_id: 3
    }

    assert_redirected_to admin_lecture_register_path(1)
  end
end
