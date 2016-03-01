package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('@dev_mico')
HTTPS = require('ssl.https')
----config----
local bot_api_key = "178744823:AAEsCkFhiu7Ksew48tF3fgLzE4NxjfGfi4I"
local you = 203189872 --your id
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key

local nl = [[]]--put any welcome message between [[]]



----utilites----

function is_admin(msg)-- Check if user is admin or not
  local var = false
  local admins = you
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

function sendRequest(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end

function getMe()
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end

function getUpdates(offset)

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end


forwardMessage = function(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)

end

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end


function bot_run()
	bot = nil
	while not bot do 
	
			bot = getMe()
	
	end

	bot = bot.result

	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.." \nbased by @dev_mico\nyouId : "..you
	print(bot_info)

	last_update = last_update or 0

	is_running = true

end

function msg_processor(msg)

	if msg.date < os.time() - 5 then -- Ignore old msgs
		return
    end
if msg.text ~='/start' and msg.from.id ~= you then 
forwardMessage(you,msg.chat.id,msg.message_id)
elseif msg.reply_to_message and msg.text ~='/start' and msg.from.id == you then 
forwardMessage(msg.reply_to_message.forward_from.id,msg.chat.id,msg.message_id)
elseif msg.text:match("^/[sS]tart") or msg.text:match("^/[Hh]elp") then
 sendMessage(msg.chat.id, nl, true, false, true)

return end

end
bot_run() -- Run main function
while is_running do -- Start a loop 
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response and you ~= nil then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
		end
	else
		print("Check api token or id")
--		return "conectin failed"
	end

end
print("Bot halted")
