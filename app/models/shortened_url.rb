 require 'securerandom'

class ShortenedUrl < ApplicationRecord
  validates :user_id, :long_url, :short_url, presence: :true
  validates :short_url, uniqueness: :true

  def self.random_code
    short_url = SecureRandom.urlsafe_base64
    while self.exists?(short_url: short_url)
      short_url = SecureRandom.urlsafe_base64
    end
    short_url
  end

  def self.create_short_url(user, long_url)
    short_url = ShortenedUrl.random_code
    ShortenedUrl.create!(user_id: user.id, long_url: long_url,
                        short_url: short_url)
  end

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visitors, -> { distinct },
    through: :visits,
    source: :visitor

  has_many :visits,
    primary_key: :id,
    foreign_key: :short_url_id,
    class_name: :Visit

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    # visits.where(visits[:created_at] < (Time.now - 100.minutes)).count
    count = 0
    visits.each do |visit|
      count += 1 if visit[:created_at] < (Time.now - 10.minutes)
      p "created at: #{visit[:created_at]}, time now: #{Time.now}"
    end
    count
  end


end
