# frozen_string_literal: true

class AddEmployeeToProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :projects, :product_owner, references: :users
  end
end
