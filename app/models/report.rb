# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :active_mentions, class_name: 'MentionCorrelation', foreign_key: 'mention_id', dependent: :destroy, inverse_of: :mention
  has_many :passive_mentions, class_name: 'MentionCorrelation', foreign_key: 'mentioned_id', dependent: :destroy, inverse_of: :mentioned
  has_many :mentioning, through: :active_mentions, source: :mentioned
  has_many :mentions, through: :passive_mentions

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def mention(other_report)
    active_mentions.create(mentioned_id: other_report.id)
  end

  def delete_mention(other_report)
    active_mentions.find_by(mentioned_id: other_report.id).destroy
  end

  def delete_all_mention(id)
    active_mentions.where(mention_id: id).destroy_all
  end
end
