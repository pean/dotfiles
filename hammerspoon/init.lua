-- Hammerspoon Configuration
-- Managed by dotfiles + RCM
--
-- ============================================================================
-- HOTKEY REFERENCE
-- ============================================================================
--
-- TERMINAL
--   Cmd + Alt + N           Open new Alacritty on current space
--
-- WINDOW HINTS (VIM-STYLE WINDOW JUMPING)
--   Cmd + Shift + ;         Show letters on all windows, press to focus
--
-- WINDOW POSITIONING - FULL/MAXIMIZE
--   Cmd + Shift + F         Maximize window (fill screen, not fullscreen)
--
-- MOVE BETWEEN MONITORS
--   Cmd + Shift + H         Move window to left monitor
--   Cmd + Shift + L         Move window to right monitor
--   Cmd + Shift + N         Move window to next monitor (cycles)
--
-- WINDOW POSITIONING - HALVES
--   Cmd + Shift + ←         Left half
--   Cmd + Shift + →         Right half
--   Cmd + Shift + ↑         Top half
--   Cmd + Shift + ↓         Bottom half
--
-- WINDOW POSITIONING - QUARTERS
--   Ctrl + Cmd + U          Top-left quarter
--   Ctrl + Cmd + I          Top-right quarter
--   Ctrl + Cmd + J          Bottom-left quarter
--   Ctrl + Cmd + K          Bottom-right quarter
--
-- CENTER & RESIZE
--   Cmd + Shift + C         Center window (maintains size)
--   Ctrl + Cmd + C          Center window at 75% width/height
--   Ctrl + Cmd + =          Grow window (50px larger)
--   Ctrl + Cmd + -          Shrink window (50px smaller)
--
-- ============================================================================

-- Disable animation for faster window movements
hs.window.animationDuration = 0

-- Reload config automatically when this file changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end):start()

hs.alert.show("Hammerspoon config loaded")

-- Helper function to get focused window
local function getFocusedWindow()
    return hs.window.focusedWindow()
end

-- ============================================================================
-- TERMINAL LAUNCHER
-- ============================================================================
-- Open new Alacritty on current space
hs.hotkey.bind({"cmd", "alt"}, "N", function()
    hs.execute("open -n /Applications/Alacritty.app")
end)

-- ============================================================================
-- WINDOW POSITIONING - FILL SCREEN (NOT FULLSCREEN)
-- ============================================================================
-- Override macOS Cmd+Shift+F to maximize instead of fullscreen
hs.hotkey.bind({"cmd", "shift"}, "F", function()
    local win = getFocusedWindow()
    if win then
        win:maximize()
    end
end)

-- ============================================================================
-- MOVE WINDOWS BETWEEN MONITORS
-- ============================================================================
-- Move window to left monitor (solves Issue #3)
hs.hotkey.bind({"cmd", "shift"}, "H", function()
    local win = getFocusedWindow()
    if win then
        win:moveOneScreenWest(false, true)
    end
end)

-- Move window to right monitor
hs.hotkey.bind({"cmd", "shift"}, "L", function()
    local win = getFocusedWindow()
    if win then
        win:moveOneScreenEast(false, true)
    end
end)

-- Move window to next monitor (cycles through all monitors)
hs.hotkey.bind({"cmd", "shift"}, "N", function()
    local win = getFocusedWindow()
    if win then
        win:moveToScreen(win:screen():next())
    end
end)

-- ============================================================================
-- WINDOW POSITIONING - HALVES
-- ============================================================================
-- Left half
hs.hotkey.bind({"cmd", "shift"}, "Left", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end)

-- Right half
hs.hotkey.bind({"cmd", "shift"}, "Right", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end)

-- Top half
hs.hotkey.bind({"cmd", "shift"}, "Up", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- Bottom half
hs.hotkey.bind({"cmd", "shift"}, "Down", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x
        f.y = max.y + (max.h / 2)
        f.w = max.w
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- ============================================================================
-- WINDOW POSITIONING - QUARTERS
-- ============================================================================
-- Top-left quarter
hs.hotkey.bind({"ctrl", "cmd"}, "U", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- Top-right quarter
hs.hotkey.bind({"ctrl", "cmd"}, "I", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- Bottom-left quarter
hs.hotkey.bind({"ctrl", "cmd"}, "J", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x
        f.y = max.y + (max.h / 2)
        f.w = max.w / 2
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- Bottom-right quarter
hs.hotkey.bind({"ctrl", "cmd"}, "K", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        f.x = max.x + (max.w / 2)
        f.y = max.y + (max.h / 2)
        f.w = max.w / 2
        f.h = max.h / 2
        win:setFrame(f)
    end
end)

-- ============================================================================
-- CENTER WINDOW
-- ============================================================================
-- Center window on screen (maintains size)
hs.hotkey.bind({"cmd", "shift"}, "C", function()
    local win = getFocusedWindow()
    if win then
        win:centerOnScreen()
    end
end)

-- Center window at 75% width and 75% height
hs.hotkey.bind({"ctrl", "cmd"}, "C", function()
    local win = getFocusedWindow()
    if win then
        local screen = win:screen()
        local max = screen:frame()
        local f = {}

        -- 75% width and height
        f.w = max.w * 0.75
        f.h = max.h * 0.75

        -- Center it
        f.x = max.x + (max.w - f.w) / 2
        f.y = max.y + (max.h - f.h) / 2

        win:setFrame(f)
    end
end)

-- ============================================================================
-- WINDOW RESIZING
-- ============================================================================
-- Grow window (increase size by 50px in all directions)
hs.hotkey.bind({"ctrl", "cmd"}, "=", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        f.x = f.x - 25
        f.y = f.y - 25
        f.w = f.w + 50
        f.h = f.h + 50
        win:setFrame(f)
    end
end)

-- Shrink window (decrease size by 50px in all directions)
hs.hotkey.bind({"ctrl", "cmd"}, "-", function()
    local win = getFocusedWindow()
    if win then
        local f = win:frame()
        f.x = f.x + 25
        f.y = f.y + 25
        f.w = f.w - 50
        f.h = f.h - 50
        win:setFrame(f)
    end
end)

-- ============================================================================
-- WINDOW HINTS - VIM-STYLE WINDOW JUMPING
-- ============================================================================
-- Configure window hints appearance (Nord theme colors)
hs.hints.style = "vimperator"  -- Show letters in a box overlay
hs.hints.fontSize = 24         -- Large, easy to read
hs.hints.fontName = "Monaspace Krypton NF"
hs.hints.showTitleThresh = 0   -- Never show window titles, just letters
hs.hints.hintChars = {"A", "S", "D", "F", "J", "K", "L", "Q", "W", "E", "R", "U", "I", "O", "P"}  -- Home row + top row

-- Show window hints - press letter to focus that window
hs.hotkey.bind({"cmd", "shift"}, ";", function()
    hs.hints.windowHints()
end)
