class Quote < ApplicationRecord
    belongs_to :material
    has_many :quote_processes, dependent: :destroy
    has_many :quote_toolings, dependent: :destroy
    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_toolings, allow_destroy: true
  end