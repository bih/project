class HomeController < ApplicationController
  def index
    student_index if signed_in? and current_user.student?
  end

  def student_index
    @user = current_user
    @units = Unit.where_student(@user)

    @attendance = lambda {
      if @user.attendance >= 95
        { :class => "percentage-great", :text => "Your overall attendance is very good at #{@user.attendance}%. Keep it up." }
      elsif @user.attendance <= 75
        { :class => "percentage-warning", :text => "Your overall attendance is worrying low at #{@user.attendance}%. You need to go to more classes." }
      else
        { :class => "percentage-healthy", :text => "Your overall attendance is healthy at #{@user.attendance}%, but you could do better." }
      end
    }.call

    render :"student-index"
  end

  def about
  end
end
