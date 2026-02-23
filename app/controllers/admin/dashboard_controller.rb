class Admin::DashboardController < Admin::BaseController
  def index
    @products_count = Product.count
    @events_count = Event.count
    @inquiries_count = Inquiry.count
  end
end
