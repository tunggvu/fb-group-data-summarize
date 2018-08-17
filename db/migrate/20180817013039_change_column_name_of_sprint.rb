# frozen_string_literal: true

class ChangeColumnNameOfSprint < ActiveRecord::Migration[5.2]
  def change
    rename_column :sprints, :start_time, :starts_on
    rename_column :sprints, :end_time, :ends_on
  end
end
