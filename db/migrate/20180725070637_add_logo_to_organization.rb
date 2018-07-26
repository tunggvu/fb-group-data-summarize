# frozen_string_literal: true

class AddLogoToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :logo, :string
  end
end
