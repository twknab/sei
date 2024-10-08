# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:colleges) do
      primary_key :id
      String :name, null: false
      String :city, null: false
      String :state, null: false
      String :college_board_code
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
