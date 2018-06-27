# frozen_string_literal: true

class Organization < ApplicationRecord
  belongs_to :parent, class_name: "Organization", optional: true
  has_many :children, class_name: "Organization", foreign_key: "parent_id"
  has_many :employees
  validates :name, presence: true
  validates :manager_id, presence: true
end
