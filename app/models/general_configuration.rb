class GeneralConfiguration < ApplicationRecord
    belongs_to :unit
    
    default_scope { order(Arel.sql("LOWER(description) ASC")) }
end
