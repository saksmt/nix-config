-- beware, slop ahead!
local pending_pos = nil
local thumb_info = nil

local options = require("mp.options")
local opts = {
  lock_fullscreen = false,
}
options.read_options(opts, "staged_seek")

-- this prevents exiting from fullscreen in couch potato mode
if opts.lock_fullscreen then
  mp.observe_property("fullscreen", "bool", function(_, is_fs)
    if is_fs == false then
      mp.set_property_bool("fullscreen", true)
    end
  end)
end

-- auto open menu on idle
mp.observe_property("idle-active", "bool", function(_, is_idle)
  if is_idle then
    mp.add_timeout(0.1, function()
      if mp.get_property_bool("idle-active") then
        mp.commandv("script-message-to", "extra_uosc_menu", "open-menu", "fs")
      end
    end)
  end
end)

mp.register_script_message("thumbfast-info", function(json)
  local utils = require("mp.utils")
  thumb_info = utils.parse_json(json)
end)

local function step_seek(delta)
  local duration = mp.get_property_number("duration")
  if not duration then return end
  if pending_pos == nil then
    pending_pos = mp.get_property_number("time-pos", 0)
  end
  pending_pos = math.max(0, math.min(duration, pending_pos + delta))
  mp.commandv("script-message-to", "uosc", "flash-elements", "timeline")
  mp.osd_message(string.format("Seek -> %s (Enter/A to jump, Esc/B to cancel)", mp.format_time(pending_pos)), 2)

  if thumb_info and not thumb_info.disabled then
    local osd_w, osd_h = mp.get_osd_size()
    if osd_w and osd_w > 0 and duration > 0 then
      local ratio = pending_pos / duration
      local tw = thumb_info.width or 200
      local th = thumb_info.height or 112
      local x = math.floor(math.max(10, math.min(osd_w - tw - 10, osd_w * ratio - tw / 2)))
      local y = math.floor(math.max(10, osd_h - th - 60))
      mp.commandv("script-message-to", "thumbfast", "thumb", pending_pos, x, y)
    end
  end
end

local function clear_preview()
  mp.commandv("script-message-to", "thumbfast", "clear")
end

mp.add_key_binding(nil, "step-back", function() step_seek(-10) end, { repeatable = true })
mp.add_key_binding(nil, "step-fwd",  function() step_seek(10)  end, { repeatable = true })

mp.add_key_binding(nil, "confirm-or-pause", function()
  if pending_pos ~= nil then
    mp.commandv("seek", pending_pos, "absolute", "exact")
    pending_pos = nil
    mp.osd_message("", 0)
    clear_preview()
  else
    mp.commandv("cycle", "pause")
  end
end)

mp.add_key_binding(nil, "confirm-only", function()
  if pending_pos ~= nil then
    mp.commandv("seek", pending_pos, "absolute", "exact")
    pending_pos = nil
    mp.osd_message("", 0)
    clear_preview()
  end
end)

mp.add_key_binding(nil, "cancel-seek", function()
  if pending_pos ~= nil then
    pending_pos = nil
    mp.osd_message("Seek canceled", 1)
    clear_preview()
  end
end)

mp.add_key_binding(nil, "cancel-or-unfullscreen", function()
  if pending_pos ~= nil then
    pending_pos = nil
    mp.osd_message("Seek canceled", 1)
    clear_preview()
  else
    mp.set_property("fullscreen", "no")
  end
end)
