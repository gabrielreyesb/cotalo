class Quote < ApplicationRecord
    validates :customer_email, presence: true
    validates :product_pieces, numericality: { greater_than: 0 }

    belongs_to :material, optional: true
    belongs_to :unit, optional: true
    
    has_many :quote_processes, dependent: :destroy
    has_many :quote_toolings, dependent: :destroy
    
    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_toolings, allow_destroy: true
    attr_accessor :customer_organization 
end