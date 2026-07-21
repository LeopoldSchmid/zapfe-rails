class InvoiceSequence < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  validates :next_value, numericality: { only_integer: true, greater_than: 0 }

  def self.take_next!(year: Date.current.year)
    transaction(requires_new: true) do
      sequence = lock.find_or_create_by!(year: year) { |record| record.next_value = starting_value(year) }
      value = sequence.next_value
      sequence.update!(next_value: value + 1)
      value
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.starting_value(year)
    prefix = "R-#{year}-"
    last_number = Invoice.where("invoice_number LIKE ?", "#{prefix}%").maximum(:invoice_number)
    last_number ? last_number.delete_prefix(prefix).to_i + 1 : 1
  end
  private_class_method :starting_value
end
