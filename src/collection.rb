class Collection < Array
  def sum(property)
    reduce(0) do |total, obj|
      next total if obj.nil?

      value = obj.send(property)

      if value.nil?
        total
      else
        total + value
      end
    end
  end

  def filter_map(test, cast)
    select(&test).map(&cast).to_collection
  end
end
