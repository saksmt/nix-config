local OSD_TIMEOUT = 5

local function filter(tbl, predicate)
  local result = {}
  for _, t in ipairs(tbl) do
    if predicate(t) then
      table.insert(result, t)
    end
  end
  return result
end

local function is_lang(lang, codes)
  if not lang then return false end
  lang = lang:lower()
  for _, code in ipairs(codes) do
    if lang == code then return true end
  end
  return false
end

local function is_commentary(track)
  if not track.title then return false end
  local title = track.title:lower()
  return title:find("commentary") ~= nil or title:find("комментари") ~= nil or title:find("comentary") ~= nil or title:find("коментари") ~= nil
end

local function is_forced_sub(track)
  if track.forced then
    return true
  end
  if track.title then
    local title = track.title:lower()
    if title:find("signs") or title:find("songs") or title:find("forced")
        or title:find("надписи") or title:find("песни") then
      return true
    end
  end
  return false
end

-- Deterministic comparator: non-commentary first -> alphabetical by title -> container ID
local function compare_tracks(prefer_default)
  return function (a, b)
    local a_comm = is_commentary(a)
    local b_comm = is_commentary(b)
    if a_comm ~= b_comm then
      return not a_comm
    end

    if prefer_default then
      if a.default then
        return true
      elseif b.default then
        return true
      end
    end

    local a_title = (a.title or ""):lower()
    local b_title = (b.title or ""):lower()
    if a_title ~= b_title then
      return a_title < b_title
    end

    return a.id < b.id
  end
end

local function find_audio(tracks, codes, prefer_default)
  local result = filter(tracks, function (track)
    return track.type == "audio" and is_lang(track.lang, codes) and (not is_commentary(track))
  end)
  if #result == 0 then return nil end
  table.sort(result, compare_tracks(prefer_default))
  return result[1]
end

local function find_sub(tracks, codes, require_forced, prefer_default)
  local result = filter(tracks, function (track)
    return track.type == "sub"
      and is_lang(track.lang, codes)
      and (
        require_forced == nil
        or (is_forced_sub(track) == require_forced)
      )
  end)
  if #result == 0 then return nil end
  table.sort(result, compare_tracks(prefer_default))
  return result[1]
end

local function notify_selection(audio, sub)
  local audio_str = ""
  local sub_str = ""

  if audio then
    audio_str = "audio: " .. (audio.lang or "") .. "[" .. (audio.title or "default") .. "]"
    sub_str = "\n"
  end

  if sub then
    sub_str = sub_str .. "sub: " .. (sub.lang or "") .. "[" .. (sub.title or "default") .. "]"
  end
  mp.osd_message(audio_str .. sub_str, OSD_TIMEOUT)
end

local function select_tracks()
  local tracks = mp.get_property_native("track-list")
  if not tracks then return end

  local jpn_audio = find_audio(tracks, {"jpn", "ja"})

  if jpn_audio then
    local rus_audio = find_audio(tracks, {"rus", "ru"})
    local eng_audio = find_audio(tracks, {"eng", "en"})

    if rus_audio then
      mp.set_property("aid", rus_audio.id)
      local forced_sub = find_sub(tracks, {"rus", "ru"}, true)
      notify_selection(rus_audio, forced_sub)
      mp.set_property("sid", forced_sub and forced_sub.id or "no")
    elseif eng_audio then
      mp.set_property("aid", eng_audio.id)
      local forced_sub = find_sub(tracks, {"eng", "en"}, true)
      notify_selection(eng_audio, forced_sub)
      mp.set_property("sid", forced_sub and forced_sub.id or "no")
    else
      -- Neither Russian nor English dub exists -> play Japanese + Full Subs (English -> Russian)
      mp.set_property("aid", jpn_audio.id)
      local sub = find_sub(tracks, {"eng", "en"}, false)
               or find_sub(tracks, {"rus", "ru"}, false)
               or find_sub(tracks, {"eng", "en", "rus", "ru"}, nil)
      notify_selection(jpn_audio, sub)
      mp.set_property("sid", sub and sub.id or "no")
    end
    return
  end

  -- trust in properly set default flag is higher with non-fandub
  local rus_audio = find_audio(tracks, {"rus", "ru"}, true)
  local eng_audio = find_audio(tracks, {"eng", "en"}, true)

  if eng_audio then
    mp.set_property("aid", eng_audio.id)
    local forced_sub = find_sub(tracks, {"eng", "en"}, true)
    notify_selection(eng_audio, forced_sub)
    mp.set_property("sid", forced_sub and forced_sub.id or "no")
  elseif rus_audio then
    mp.set_property("aid", rus_audio.id)
    local forced_sub = find_sub(tracks, {"rus", "ru"}, true)
    notify_selection(rus_audio, forced_sub)
    mp.set_property("sid", forced_sub and forced_sub.id or "no")
  else
    mp.osd_message("No audio or sub auto-selected. Using defaults", OSD_TIMEOUT)
  end
end

mp.register_event("file-loaded", select_tracks)
