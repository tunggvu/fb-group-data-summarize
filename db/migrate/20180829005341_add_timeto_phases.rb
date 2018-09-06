# frozen_string_literal: true

class AddTimetoPhases < ActiveRecord::Migration[5.2]
  def change
    add_column :phases, :starts_on, :date, null: false
    add_column :phases, :ends_on, :date, null: false
  end
end
