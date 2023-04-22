# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :active_mentions, class_name: 'MentionCorrelation', foreign_key: 'mention_id', dependent: :destroy, inverse_of: :mention
  has_many :passive_mentions, class_name: 'MentionCorrelation', foreign_key: 'mentioned_id', dependent: :destroy, inverse_of: :mentioned
  has_many :mentioned_reports, through: :active_mentions, source: :mentioned
  has_many :mentioning_reports, through: :passive_mentions, source: :mention

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def create_mentions(mentioning_id, urls)
    mentioned_reports = Report.where(id: urls.flatten)
    mentioned_reports.each do |mentioned_report|
      next if mentioning_id == mentioned_report.id
      return false if mentioned_report.blank?

      active_mentions.create(mentioned_id: mentioned_report.id)
    end
    true
  end

  def delete_all_mention
    active_mentions.destroy_all
  end
end
