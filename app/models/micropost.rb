class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  # Returns microposts from the users being followed by the given user (plus self).
  def self.from_users_followed_by(user)
    fu_subselect = 'SELECT followed_id FROM relationships WHERE follower_id = :user_id'
    where("user_id IN (#{fu_subselect}) OR user_id = :user_id", user_id: user)
  end
end
