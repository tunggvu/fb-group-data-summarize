# frozen_string_literal: true

class ChangeModifiedDateToModifiedAtInRequest < ActiveRecord::Migration[5.2]
  def change
    rename_column :requests, :modified_date, :modified_at
    change_column :requests, :modified_at, :datetime
  end
end
