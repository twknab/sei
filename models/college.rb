# frozen_string_literal: true

require 'sequel'

class College < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:name, :city, :state]
  end
end
