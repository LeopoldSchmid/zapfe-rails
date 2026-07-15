class Admin::BaseController < ApplicationController
  include Admin::Undoable
  before_action :require_admin!
  layout "admin"
end
