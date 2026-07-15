class Admin::PushSubscriptionsController < Admin::BaseController
  def create
    subscription = current_admin_user.push_subscriptions.find_or_initialize_by(endpoint: subscription_params[:endpoint])
    subscription.assign_attributes(subscription_params)
    subscription.save!
    head :no_content
  end

  def destroy
    current_admin_user.push_subscriptions.find_by!(endpoint: params[:endpoint]).destroy!
    head :no_content
  end

  def test
    subscription = current_admin_user.push_subscriptions.find_by!(endpoint: params[:endpoint])
    PushNotificationJob.perform_later(
      subscription,
      title: "Push ist aktiv",
      body: "Benachrichtigungen für zapfe.intern funktionieren auf diesem Gerät.",
      path: admin_root_path,
      tag: "zapfe-push-test"
    )
    head :accepted
  end

  private

  def subscription_params
    params.require(:push_subscription).permit(:endpoint, :p256dh, :auth)
  end
end
