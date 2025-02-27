class PdfCounter < ApplicationRecord
  # Get the next number atomically and increment the counter
  def self.next_number
    counter = first_or_create!(current_number: 0)
    counter.with_lock do
      counter.current_number += 1
      counter.save!
      counter.current_number
    end
  end
end
