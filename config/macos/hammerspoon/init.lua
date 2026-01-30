-- Hammerspoon Configuration
-- Powerful automation for macOS
-- https://www.hammerspoon.org/

-- Reload config when this file changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()

-- Notify when config is loaded
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()

-- Window Management Helpers
-- Since we use Aerospace for tiling, these are supplementary utilities

-- Center window on screen
function centerWindow()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  
  f.x = max.x + (max.w - f.w) / 2
  f.y = max.y + (max.h - f.h) / 2
  win:setFrame(f)
end

-- Maximize window (useful for floating windows)
function maximizeWindow()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:maximize()
end

-- Hotkey bindings
-- Using hyper key (caps lock mapped to control in kanata, right alt is hyper)
-- But we'll use ctrl+alt+cmd as an alternative
local hyper = {"ctrl", "alt", "cmd"}

-- Application shortcuts
hs.hotkey.bind(hyper, "c", function()
  hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind(hyper, "t", function()
  hs.application.launchOrFocus("kitty")
end)

hs.hotkey.bind(hyper, "s", function()
  hs.application.launchOrFocus("Safari")
end)

hs.hotkey.bind(hyper, "m", function()
  hs.application.launchOrFocus("Mail")
end)

hs.hotkey.bind(hyper, "n", function()
  hs.application.launchOrFocus("Notion")
end)

hs.hotkey.bind(hyper, "v", function()
  hs.application.launchOrFocus("Visual Studio Code")
end)

-- Window management
hs.hotkey.bind(hyper, "return", maximizeWindow)
hs.hotkey.bind(hyper, "c", centerWindow)

-- Clipboard manager (simple)
hs.hotkey.bind(hyper, "v", function()
  hs.eventtap.keyStroke({"cmd"}, "v")
end)

-- Quick web search
hs.hotkey.bind(hyper, "g", function()
  local input, ok = hs.dialog.textPrompt("Google Search", "Enter search query:", "", "Search", "Cancel")
  if ok and input ~= "" then
    local query = hs.http.encodeForQuery(input)
    hs.execute("open 'https://www.google.com/search?q=" .. query .. "'")
  end
end)

-- Screen lock
hs.hotkey.bind(hyper, "l", function()
  hs.caffeinate.lockScreen()
end)

-- System commands
-- Sleep display
hs.hotkey.bind(hyper, "s", function()
  hs.execute("pmset displaysleepnow")
end)

-- Reload hammerspoon config manually
hs.hotkey.bind(hyper, "r", hs.reload)

-- Audio device switching (if you have multiple audio devices)
function cycleAudioDevice()
  local current = hs.audiodevice.defaultOutputDevice()
  local all = hs.audiodevice.allOutputDevices()
  
  for i, device in ipairs(all) do
    if device:name() == current:name() then
      local next = all[(i % #all) + 1]
      next:setDefaultOutputDevice()
      hs.notify.new({
        title="Audio Device Changed",
        informativeText="Switched to: " .. next:name()
      }):send()
      return
    end
  end
end

hs.hotkey.bind(hyper, "a", cycleAudioDevice)

-- URL Dispatcher
-- Automatically open certain URLs in specific browsers
hs.urldispatch.httpCallback = function(scheme, host, params, fullUrl)
  -- Example: Open work URLs in Chrome, everything else in Safari
  if host:match("github%.com") or host:match("gitlab%.com") then
    hs.execute("open -na Google Chrome '" .. fullUrl .. "'")
    return true
  end
  return false
end

-- WiFi watcher - notify when connecting to different networks
wifiWatcher = nil
homeSSID = "MyHomeNetwork" -- Change this to your home WiFi name
lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
  local newSSID = hs.wifi.currentNetwork()
  
  if newSSID == homeSSID and lastSSID ~= homeSSID then
    -- Just connected to home network
    hs.notify.new({
      title="Network Change",
      informativeText="Connected to home network"
    }):send()
  elseif newSSID ~= homeSSID and lastSSID == homeSSID then
    -- Left home network
    hs.notify.new({
      title="Network Change",
      informativeText="Left home network"
    }):send()
  end
  
  lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

-- Battery warning
function batteryWarning()
  local percentage = hs.battery.percentage()
  local isCharging = hs.battery.isCharging()
  
  if percentage < 20 and not isCharging then
    hs.notify.new({
      title="Low Battery",
      informativeText="Battery at " .. math.floor(percentage) .. "% - Plug in charger!",
      withdrawAfter=0
    }):send()
  end
end

batteryWatcher = hs.battery.watcher.new(batteryWarning)
batteryWatcher:start()

-- Markdown mode for specific apps
-- Auto-convert markdown shortcuts in supported apps
local markdownApps = {"Notion", "Obsidian", "Typora"}

hs.application.watcher.new(function(appName, eventType)
  if eventType == hs.application.watcher.activated then
    for _, app in ipairs(markdownApps) do
      if appName == app then
        -- Enable markdown shortcuts
        -- You can add specific markdown automation here
        return
      end
    end
  end
end):start()

-- Print "Config loaded" to console
print("Hammerspoon config loaded successfully!")
