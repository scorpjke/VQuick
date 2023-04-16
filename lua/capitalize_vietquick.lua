local cap_pls = 0

local cap_table = {["đ"]="Đ", ["a"]="A", ["ă"]="Ă", ["â"]="Â", ["e"]="E", ["ê"]="Ê", ["i"]="I", ["o"]="O", ["ô"]="Ô", ["ơ"]="Ơ", ["u"]="U", ["ư"]="Ư", ["y"]="Y", ["á"]="Á", ["ắ"]="Ắ", ["ấ"]="Ấ", ["é"]="É", ["ế"]="Ế", ["í"]="Í", ["ó"]="Ó", ["ố"]="Ố", ["ớ"]="Ớ", ["ú"]="Ú", ["ứ"]="Ứ", ["ý"]="Ý", ["à"]="À", ["ằ"]="Ằ", ["ầ"]="Ầ", ["è"]="È", ["ề"]="Ề", ["ì"]="Ì", ["ò"]="Ò", ["ồ"]="Ồ", ["ờ"]="Ờ", ["ù"]="Ù", ["ừ"]="Ừ", ["ỳ"]="Ỳ", ["ả"]="Ả", ["ẳ"]="Ẳ", ["ẩ"]="Ẩ", ["ẻ"]="Ẻ", ["ể"]="Ể", ["ỉ"]="Ỉ", ["ỏ"]="Ỏ", ["ổ"]="Ổ", ["ở"]="Ở", ["ủ"]="Ủ", ["ử"]="Ử", ["ỷ"]="Ỷ", ["ã"]="Ã", ["ẵ"]="Ẵ", ["ẫ"]="Ẫ", ["ẽ"]="Ẽ", ["ễ"]="Ễ", ["ĩ"]="Ĩ", ["õ"]="Õ", ["ỗ"]="Ỗ", ["ỡ"]="Ỡ", ["ũ"]="Ũ", ["ữ"]="Ữ", ["ỹ"]="Ỹ", ["ạ"]="Ạ", ["ặ"]="Ặ", ["ậ"]="Ậ", ["ẹ"]="Ẹ", ["ệ"]="Ệ", ["ị"]="Ị", ["ọ"]="Ọ", ["ộ"]="Ộ", ["ợ"]="Ợ", ["ụ"]="Ụ", ["ự"]="Ự", ["ỵ"]="Ỵ"}

local function capitalize_letter(letter)
   return cap_table[letter] or (letter:gsub("^%l", string.upper))
end

local function capitalize_first(word)
	for L,U in pairs(cap_table) do
	  local res, count = word:gsub("^" .. L, U)
	  if count>0 then
		return res
	  end
	end
	
	return (word:gsub("^%l", string.upper))
end

local function capitalize_each_word(word)
	  local res = (capitalize_first(word)):gsub("([ %-])([^ ]+)", function(x,y)
		 return x .. capitalize_first(y)
	  end)
	  return res
end

local function capitalize_all_letters(word)
	for L,U in pairs(cap_table) do
	  word = word:gsub(L, U)
	end
	
	return string.upper(word)
end

local shift_down = false

local function processor(key, env)
   local composing = env.engine.context:is_composing()
   if not composing then
	  cap_pls = 0
   end

   --if key:release() == false and not key:ctrl() and key:shift() and composing then
   --if composing and key:repr() == "Shift+Shift_L" then
	--  shift_down = true
   --end

   if composing and key:repr() == "Control+Release+s" then
	  local inp = env.engine.context.input
	  env.engine.context.input = inp:gsub("..", "%1;")
	  env.engine.context:commit()
	  return 1 
   end

   --log.error(key:repr())

   --if shift_down and composing and key:repr() == "Release+Shift_L" then
   if composing and key:repr() == "Tab" then
	  cap_pls = cap_pls + 1
	  local inp = env.engine.context.input
	  env.engine.context.input = ""
	  env.engine.context.input = inp
	  shift_down = false
	  return 1
   end

   if composing and key:repr() == "Control+Release+c" then
	  cap_pls = 3
	  local inp = env.engine.context.input
	  env.engine.context.input = ""
	  env.engine.context.input = inp
	  shift_down = false
	  return 1
   end

   return 2
end

local function filter(inp,env)
   for cand in inp:iter() do
	  if cand.text == " "  then
		 yield(cand)
		 goto next_iter
	  end
	  --local new_cand = Candidate("date", cand.start, cand._end, cand.text ,cap_pls) --cand.comment 

	  local s = cand.text
	  if cap_pls == 1 then
		 s = capitalize_first(cand.text)
	  elseif cap_pls == 2 then
		 s = capitalize_each_word(cand.text)
	  elseif cap_pls == 3 then
		 s = capitalize_all_letters(cand.text)
	  end

	  cand:get_genuine().text = s
	  yield(cand)

	  --yield(Candidate(s, cand._start, cand._end, s, cand.comment ))
	  ::next_iter::
   end
end

local function init(env)
   cap_pls = 0
end

return { init = init, processor = processor, filter = filter }