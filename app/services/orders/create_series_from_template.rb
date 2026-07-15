class Orders::CreateSeriesFromTemplate
  class NotCreatable < StandardError; end

  def initialize(template:, start_on:, weekday:, occurrences:, admin_user:)
    @template = template
    @start_on = Date.parse(start_on.to_s)
    @weekday = Integer(weekday)
    @occurrences = Integer(occurrences)
    @admin_user = admin_user
  rescue ArgumentError, TypeError
    raise NotCreatable, "Bitte Startdatum, Wochentag und Anzahl vollständig angeben."
  end

  def call
    raise NotCreatable, "Eine Serie braucht mindestens einen und höchstens 52 Termine." unless @occurrences.between?(1, 52)
    raise NotCreatable, "Ungültiger Wochentag." unless @weekday.between?(0, 6)

    Order.transaction do
      occurrence_dates.map do |event_date|
        order = Order.new(status: "preparing", customer_name: order_name(event_date), event_date: event_date)
        Orders::ApplyTemplate.new(order: order, template: @template).apply_defaults!
        order.responsible_admin_user ||= @admin_user
        order.event_location ||= "Ort offen"
        order.save!
        Orders::ApplyTemplate.new(order: order, template: @template).materialize!
        order.activities.create!(admin_user: @admin_user, event_type: "series_created", message: "Aus Veranstaltungsserie #{@template.name} erstellt")
        order
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    raise NotCreatable, error.record.errors.full_messages.to_sentence
  end

  private

  def occurrence_dates
    first = @start_on + ((@weekday - @start_on.wday) % 7)
    @occurrences.times.map { |index| first + index.weeks }
  end

  def order_name(event_date)
    "#{@template.name} · #{I18n.l(event_date)}"
  end
end
