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
    assert_response :success, "Did not render show all lectures page"
  end

  test "should get lecture on today" do
    get :on_day
    assert_response :success, "Did not render show lectures today page"
  end

  test "should get lecture on specific day" do
    get :on_day, date: "2015-10-05"
    assert_response :success, "Did not render show lectures on 2015-10-05 day page"
  end

  test "should get new lecture" do
    get :new
    assert_response :success, "Did not render create new lecture page"
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

    assert_redirected_to admin_lectures_path, "Did not create lecture and redirect to show all lectures page"
  end

  test "should get edit" do
    get :edit, id: 1
    assert_response :success, "Did not render edit lecture 1 page"
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

    assert_redirected_to admin_unit_lectures_path(assigns(:lecture)), "Did not update lecture 1 and redirect to lecture page."
  end

  test "should destroy lecture" do
    delete :destroy, id: 1
    assert_redirected_to admin_lectures_path, "Did not destroy lecture 1 and redirect to all lectures."
  end

  test "should get lecture" do
    get :show, id: 1
    assert_response :success, "Did not render lecture 1 student list."
  end

  test "should post add student" do
    post :add_student, {
      lecture_id: 1,
      lecture_student: {
        user_id: 3
        }
      }

    assert_redirected_to admin_lecture_path(1), "Did not add student and redirect to lecture 1 student list."
  end

  test "should post copy students" do
    post :copy_students, {
      lecture_id: 1,
      lecture_to_copy_id: 2
      }

    assert_redirected_to admin_lecture_path(1), "Did not copy students and redirect to lecture 1 student list."
  end

  test "should post remove student from lecture" do
    post :remove_student, {
      lecture_id: 1,
      id: 1
      }

    assert_redirected_to admin_lecture_path(1), "Did not redirect to lecture 1 student list."
  end

  test "should get lecture register" do
    get :register, lecture_id: 1
    assert_response :success, "Did not render lecture 1 register."
  end

  test "should post register student for lecture" do
    post :register_student, {
      lecture_id: 1,
      student_id: 3
      }

    assert_redirected_to admin_lecture_register_path(1), "Did not redirect to lecture 1 register."
  end
end
