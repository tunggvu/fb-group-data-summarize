class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, though: :user_groups
end
