for_each = function(table, fn)
  for _, item in pairs(table) do
    fn(item)
  end
end