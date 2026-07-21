module TransitionPolicy
  extend ActiveSupport::Concern

  class_methods do
    def allows_status_transitions(transitions)
      define_method(:allowed_status_transitions) { transitions }
      validate :status_transition_is_allowed, if: -> { persisted? && will_save_change_to_status? }
    end
  end

  private

  def status_transition_is_allowed
    from, to = status_change_to_be_saved
    return if Array(allowed_status_transitions[from]).include?(to)

    errors.add(:status, "kann nicht von #{from} nach #{to} wechseln")
  end
end
