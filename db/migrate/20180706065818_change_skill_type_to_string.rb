# frozen_string_literal: true

class ChangeSkillTypeToString < ActiveRecord::Migration[5.2]
  def change
    change_column :skills, :level, :string
  end
end
