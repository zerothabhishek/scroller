require "scroller/version"

#
# Scroller.reveal(arel, after: id)
#
module Scroller

  PerPage = 10
  Descending = 'desc'

  # arel
  # args:
  #   after: 
  #   per_page:
  #
  def self.reveal(arel, args)
    
    arel or raise ScrollerError
    after = args[:after] or raise ScrollerError
    per_page = args[:per_page] || PerPage


    order_values = arel.order_values[0]
    if order_values.nil?
      arel = add_order_values(arel)
    end

    direction = guess_direction(arel)

    if direction == Descending
      arel.where('id < ?', after).limit(per_page)
    else
      arel.where('id > ?', after).limit(per_page)
    end
  end

  def self.add_order_values(arel)
    arel.order(created_at: :desc)
  end

  # Works for order clause with column name, like
  #   order(created_at: :desc) or order('created_at desc')
  #
  # For complicated order clause like one with a subquery or alias,
  #   it relies on the presence of 'desc'
  #
  def self.guess_direction(arel)
    order_values = arel.order_values[0]
    if Arel::Nodes::Descending === order_values ||
       order_values.split(' ').any?{ |part| part == Descending }
      return Descending
    end
  end  
  
end


class ScrollerError < Exception
end
