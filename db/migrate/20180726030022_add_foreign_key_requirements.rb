# frozen_string_literal: true

class AddForeignKeyRequirements < ActiveRecord::Migration[5.2]
  def change
    add_reference :requirements, :level, foreign_key: true
  end
end
