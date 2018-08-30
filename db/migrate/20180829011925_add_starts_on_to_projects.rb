# frozen_string_literal: true

class AddStartsOnToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :starts_on, :date
  end
end
