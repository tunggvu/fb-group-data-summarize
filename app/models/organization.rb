# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :parent, class_name: "Organization", optional: true
  has_many :children, class_name: "Organization", foreign_key: "parent_id"
  has_many :employees
  validates :name, presence: true
  validates :manager_id, presence: true
  validates :level, presence: true

  enum level: {team: 1, clan: 2, section: 3, division: 4}

  scope :top_organization, ->{ where parent_id: nil }

  def as_json options={}
    super((options || { }).merge({
      :methods => [:children]
    }))
  end
end
