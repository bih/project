class Admin::LogsController < ApplicationController
  before_filter :admin_only!

  def index
    @logs = Audited::Adapters::ActiveRecord::Audit.paginate(:page => params[:page]).order("created_at DESC").all
  end
end
