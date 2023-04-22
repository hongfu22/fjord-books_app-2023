# frozen_string_literal: true

class MentionCorrelation < ApplicationRecord
  belongs_to :mention, class_name: 'Report'
  belongs_to :mentioned, class_name: 'Report'
  validates :mention_id, uniqueness: { scope: :mentioned_id }
end
