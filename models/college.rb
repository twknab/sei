# frozen_string_literal: true

require 'sequel'

class College < Sequel::Model
  plugin :validation_helpers, :timestamps, :update_on_create

  def validate
    super
    validates_presence %i[name city state]
  end
end
