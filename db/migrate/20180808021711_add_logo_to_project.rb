# frozen_string_literal: true

class AddLogoToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :logo, :string
  end
end
