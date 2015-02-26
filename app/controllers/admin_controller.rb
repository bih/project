class AdminController < ApplicationController
  before_filter :admin_lecturer_only!
  before_filter :gchart_attendance_this_week, :if => Proc.new { current_user.admin? }
  before_filter :gchart_attendance_last_week, :if => Proc.new { current_user.admin? }

  def index
    if current_user.admin?
      render :index
    else
      render :"lecturer/index"
    end
  end

private

  def gchart_attendance_this_week
    attendance = { 1 => [], 2 => [], 3 => [], 4 => [], 5 => [] }

    Lecture.this_week.each do |l|
      attendance[l.start_time.wday].push(l.attendance) if l.start_time.wday <= 5
    end

    attendance = attendance.map do |key, value|
      if value.count > 0
        ((value.sum.to_f / (value.count * 100).to_f) * 100.0)
      else
        0.0
      end
    end

    legends = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"].each_with_index.map{ |x, index| "#{x} (#{attendance[index].to_i}%)" }
    colours = ["535aac", "825959", "843e01", "0a7061", "17334a", "6320df", "f40b59"].first(7).join(',')

    @gchart_attendance_this_week = Gchart.line( :size => '500x200', :title => "Total Attendance This Week", :bg => "FFF", :line_colors => colours, :legend => legends, :data => attendance)
  end

  def gchart_attendance_last_week
    attendance = { 1 => [], 2 => [], 3 => [], 4 => [], 5 => [] }

    Lecture.last_week.each do |l|
      attendance[l.start_time.wday].push(l.attendance) if l.start_time.wday <= 5
    end

    attendance = attendance.map do |key, value|
      if value.count > 0
        ((value.sum.to_f / (value.count * 100).to_f) * 100.0)
      else
        0.0
      end
    end

    legends = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"].each_with_index.map{ |x, index| "#{x} (#{attendance[index].to_i}%)" }
    colours = ["535aac", "825959", "843e01", "0a7061", "17334a", "6320df", "f40b59"].first(7).join(',')

    @gchart_attendance_last_week = Gchart.line( :size => '500x200', :title => "Total Attendance Last Week", :bg => "FFF", :line_colors => colours, :legend => legends, :data => attendance)
  end
end