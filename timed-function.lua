local functions = {}

TimedFunction = {}

TimedFunction.new = function(fn, timeout)
  table.insert(functions, {
    func = fn,
    time = timeout,
  })
end

TimedFunction.update_all = function(dt)
  for i, fn in pairs(functions) do
    fn.time = fn.time - dt
    if fn.time < 0 then
      fn()
      functions[i] = nil
    end
  end
end