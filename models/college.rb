# frozen_string_literal: true

require 'sequel'

class College < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def validate
    super
    validates_presence %i[name city state]
  end
end
