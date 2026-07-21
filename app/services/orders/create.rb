module Orders
  class Create
    def initialize(attributes:, template: nil, applier_class: Orders::ApplyTemplate)
      @attributes = attributes
      @template = template
      @applier_class = applier_class
    end

    def call
      Order.transaction do
        order = Order.new(@attributes)
        applier = @applier_class.new(order: order, template: @template) if @template
        applier&.apply_defaults!
        order.save!
        applier&.materialize!
        order
      end
    end
  end
end
