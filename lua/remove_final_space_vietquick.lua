local function trim(s)
   return s:gsub("^ +", ""):gsub(" +$", "")
end

local function filter(inp,env)
    for cand in inp:iter() do
      --log.error(dump(cand))
      --log.error("start: " .. cand._start .. ", end: " .. cand._end)
      --log.error(cand.type, cand.quality)
      --or (cand._end - cand._start) <
      if cand.text == " "  then
         yield(cand)
         goto next_iter
      end

      local comment_code = cand.comment
      if (cand.type ~= "completion") then
         local codes = env.reverse:lookup(cand.text)
         --codes = env.engine.context.input 
         local input = env.engine.context.input
         codes = codes:gsub("^" .. input .. " ", ""):gsub(" " .. input .. "$", ""):gsub("^" .. input .. "$", "")
         if codes ~= "" then
            comment_code = cand.comment .. "(" .. codes .. ")"
         end
      end

      local s = cand.text:gsub(" $", "")

      if cand._start and cand._start > 0 then
          s = " " .. s
      end

      if string.len(s) > 0 then
          local new_cand = Candidate("date", cand.start, cand._end, s, comment_code) --cand.comment 
          yield(new_cand)
      end

      ::next_iter::
   end
end


local function init(env)
   env.reverse = ReverseDb("build/vietquick.reverse.bin")
end

return { init = init, func = filter }