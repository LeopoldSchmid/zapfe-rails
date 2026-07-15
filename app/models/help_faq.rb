class HelpFaq < ApplicationRecord
  belongs_to :help_article

  validates :question, :answer, presence: true
end
