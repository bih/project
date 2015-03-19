require 'test_helper'

class Admin::UserControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @controller = Admin::UsersController.new

    john_smith = User.find_by_email("john.smith@mmu.ac.uk")
    sign_in john_smith
  end
  
  test "should get index" do
    get :index
    assert_response :success, "Did not render the user index page."
  end

  test "should get index watchlist" do
    get :index, watchlist: true
    assert_response :success, "Did not render the student watchlist page."
  end

  ["student", "lecturer", "admin"].each do |type|
    test "should get index of #{type}" do
      get :index, type: type
      assert_response :success, "Did not render the #{type} index page."
    end

    test "should get new #{type}" do
      get :new, type: type
      assert_response :success, "Did not render the create new #{type} page."
    end
  end

  test "should post create student" do
    assert_difference('User.count') do
      post :create, user: {
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: "student",
        course_name: "Computer Science",
        mmu_id: "12356789"
        }
    end

    assert_redirected_to admin_users_path + "/type/student", "Did not redirect to list of students page."
  end

  test "should post create lecturer" do
    assert_difference('User.count') do
      post :create, user: {
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: "lecturer"
        }
    end

    assert_redirected_to admin_users_path + "/type/lecturer", "Did not redirect to list of lecturers page."
  end

  test "should post create admin" do
    assert_difference('User.count') do
      post :create, user: {
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567",
        account_type: "admin"
        }
    end

    assert_redirected_to admin_users_path + "/type/admin", "Did not redirect to list of admins page."
  end

  test "should get edit user" do
    get :edit, id: 3
    assert_response :success, "Did not render edit user page."
  end

  test "should get update" do
    post :update, {
      id: 3,
      user: {
        first_name: (first_name = Faker::Name.first_name),
        last_name: (last_name = Faker::Name.last_name),
        email: Faker::Internet.user_name("#{first_name} #{last_name}") + "@mmu.ac.uk",
        password: "abc1234567",
        password_confirmation: "abc1234567"
        }
      }

    # I know user with ID 3 is a student.
    assert_redirected_to admin_users_path + "/type/student", "Did not redirect back to users."
  end

  test "should get destroy" do
    delete :destroy, id: 3
    assert_redirected_to admin_users_path, "Did not redirect back to users."
  end

end
