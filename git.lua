function capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function cmd_to_table(word, cmd, drop_prefix)
    results_table = {}

    local raw_results = capture(cmd, true)
    local pos = 0
    local endpos = string.find(raw_results, "\n")
    while endpos ~= nil do
        local s = string.sub(raw_results, pos, endpos-1)
        s = string.sub(s, drop_prefix+1, string.len(s))
        if word == nil or string.starts(s, word) then
            results_table[#results_table+1] = s
        end
        pos = endpos+1
        endpos = string.find(raw_results, "\n", pos)
    end

    return results_table
end

function branches(word)
    return cmd_to_table(word, "git branch", 2)
end

local checkout_parser = clink.arg.new_parser():set_arguments({branches})
local branch_parser = clink.arg.new_parser():set_arguments({branches})
local git_parser = clink.arg.new_parser()
git_parser:set_arguments(
    {"checkout" .. checkout_parser,
    "branch" .. clink.arg.new_parser({"-d" .. branch_parser}),
    })

clink.arg.register_parser("git", git_parser)
