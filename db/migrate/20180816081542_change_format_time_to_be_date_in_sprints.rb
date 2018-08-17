# frozen_string_literal: true

class ChangeFormatTimeToBeDateInSprints < ActiveRecord::Migration[5.2]
  def change
    change_column :sprints, :end_time, :date
    change_column :sprints, :start_time, :date
  end
end
