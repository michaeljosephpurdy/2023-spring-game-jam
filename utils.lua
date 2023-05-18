for_each = function(table, fn)
  for _, item in pairs(table) do
    fn(item)
  end
end

overlaps_mouse = function(x, y, element)
  local mx, my = x / SCALE, y / SCALE
  return mx >= element.x and mx <= element.x + element.width and
         my >= element.y and my <= element.y + element.height
end