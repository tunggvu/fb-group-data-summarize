# frozen_string_literal: true

class Device < ApplicationRecord
  enum device_type: { laptop: 1, pc: 2, mac_mini: 3, mac_book: 4 }

  belongs_to :project
  belongs_to :pic, class_name: Employee.name

  has_many :requests
end
