# frozen_string_literal: true

class ChangeColumnNullToOrganazation < ActiveRecord::Migration[5.2]
  def change
    change_column_null :organizations, :manager_id, true
  end
end
