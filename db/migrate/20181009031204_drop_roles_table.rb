# frozen_string_literal: true

class DropRolesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :employee_roles
    drop_table :roles
  end
end
