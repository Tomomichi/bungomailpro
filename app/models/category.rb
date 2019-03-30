# == Schema Information
#
# Table name: categories
#
#  id          :string           not null, primary key
#  books_count :integer          default(0)
#  name        :string           not null
#  range_from  :integer
#  range_to    :integer
#
# Indexes
#
#  index_categories_on_range_from  (range_from)
#

class Category < ApplicationRecord
  self.primary_key = :id
  has_many :books, dependent: :nullify

  def title
    case id
      when 'flash', 'shortshort', 'short'
        '短編'
      when 'novelette'
        '中編'
      when 'novel'
        '長編'
    end
  end
end
