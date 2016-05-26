class Collection < Array
  def sum(property)
    reduce(0) { |total, obj| total + obj.send(property) }
  end

  def filter_map(test, cast)
    select(&test).map(&cast).to_collection
  end
end
