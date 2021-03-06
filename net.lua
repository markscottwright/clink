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

function running_services(word)
    return cmd_to_table(word, "sc query | findstr ^SERVICE_NAME", 
        string.len("SERVICE_NAME: "))
end

function stopped_services(word)
    return cmd_to_table(word, "sc query state= inactive | findstr ^SERVICE_NAME", 
        string.len("SERVICE_NAME: "))
end

function users()
	local results = capture("net user", false)
	local prefixstart, prefixend = string.find(results, "---+")
	local suffixstart, suffixend = string.find(results, 
            "The command completed successfully.")

	local usersstr = string.sub(results, prefixend+1, suffixstart-1)
	local usertable = {}
	for user in string.gmatch(usersstr, "%w+") do
		usertable[#usertable+1] = user
	end
	return usertable
end


local start_parser = clink.arg.new_parser():set_arguments({stopped_services})
local stop_parser = clink.arg.new_parser():set_arguments({running_services})
local user_parser = clink.arg.new_parser():set_arguments({users})
local server_workstation = clink.arg.new_parser():set_arguments(
    {"server", "workstation"})
local net_parser = clink.arg.new_parser()
net_parser:set_arguments(
    {"start" .. start_parser, "stop" .. stop_parser,
    "accounts", "computer", 
    "config" .. server_workstation, 
    "continue", "file", "group", "help",
    "helpmsg", "localgroup", "pause", "session", "share", "start", 
    "statistics" .. server_workstation,
    "stop", "time", "use", 
    "user" .. user_parser, "view"
    })

clink.arg.register_parser("net", net_parser)
