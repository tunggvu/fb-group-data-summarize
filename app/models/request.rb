# frozen_string_literal: true

class Request < ApplicationRecord
  enum status: { pending: 1, approved: 2, rejected: 3 }

  belongs_to :device
  belongs_to :project
  belongs_to :request_pic, class_name: Employee.name
  belongs_to :requester, class_name: Employee.name
end
