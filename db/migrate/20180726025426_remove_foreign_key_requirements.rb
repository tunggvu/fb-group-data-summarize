# frozen_string_literal: true

class RemoveForeignKeyRequirements < ActiveRecord::Migration[5.2]
  def change
    remove_column :requirements, :skill_id
  end
end
