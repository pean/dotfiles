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
--   Ctrl + Alt + ;          Show letters on all windows, press to focus
--
-- WINDOW POSITIONING - FULL/MAXIMIZE
--   Ctrl + Alt + F          Maximize window (fill screen, not fullscreen)
--   Cmd + Shift + F         Same as above (overrides macOS fullscreen)
--
-- MOVE BETWEEN MONITORS
--   Ctrl + Alt + H          Move window to left monitor
--   Ctrl + Alt + L          Move window to right monitor
--   Ctrl + Alt + N          Move window to next monitor (cycles)
--
-- MOVE BETWEEN WORKSPACES
--   Ctrl + Alt + 1-0        Move window to workspace 1-10
--
-- WINDOW POSITIONING - HALVES
--   Ctrl + Alt + ←          Left half
--   Ctrl + Alt + →          Right half
--   Ctrl + Alt + ↑          Top half
--   Ctrl + Alt + ↓          Bottom half
--
-- CENTER & RESIZE
--   Ctrl + Alt + C          Center window (maintains size)
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
-- Workaround: Find existing Alacritty window, go there, create new window, bring back
local spaces = require("hs.spaces")

hs.hotkey.bind({"cmd", "alt"}, "N", function()
    local alacritty = hs.application.find("Alacritty")

    if not alacritty then
        -- No Alacritty running - just launch it
        hs.application.launchOrFocus("Alacritty")
        return
    end

    -- Get current space
    local currentSpace = spaces.focusedSpace()

    -- Get any Alacritty window
    local alacrittyWindow = alacritty:mainWindow()

    if not alacrittyWindow then
        -- Alacritty running but no windows - launch new instance
        hs.application.launchOrFocus("Alacritty")
        return
    end

    -- Go to the space with Alacritty window
    local alacrittySpace = spaces.windowSpaces(alacrittyWindow)[1]
    spaces.gotoSpace(alacrittySpace)

    -- Wait a moment, then send Cmd+N to create new window
    hs.timer.doAfter(0.1, function()
        alacritty:activate()
        hs.eventtap.keyStroke({"cmd"}, "N")

        -- Wait for new window, then move it back
        hs.timer.doAfter(0.3, function()
            local newWindow = alacritty:focusedWindow()
            if newWindow then
                spaces.moveWindowToSpace(newWindow, currentSpace)
                spaces.gotoSpace(currentSpace)
                newWindow:focus()
            end
        end)
    end)
end)

-- ============================================================================
-- WINDOW POSITIONING - FILL SCREEN (NOT FULLSCREEN)
-- ============================================================================
-- Maximize window to fill screen
hs.hotkey.bind({"ctrl", "alt"}, "F", function()
    local win = getFocusedWindow()
    if win then
        win:maximize()
    end
end)

-- Also keep Cmd+Shift+F to override macOS fullscreen
hs.hotkey.bind({"cmd", "shift"}, "F", function()
    local win = getFocusedWindow()
    if win then
        win:maximize()
    end
end)

-- ============================================================================
-- MOVE WINDOWS BETWEEN MONITORS
-- ============================================================================
-- Move window to left monitor
hs.hotkey.bind({"ctrl", "alt"}, "H", function()
    local win = getFocusedWindow()
    if win then
        win:moveOneScreenWest(false, true)
    end
end)

-- Move window to right monitor
hs.hotkey.bind({"ctrl", "alt"}, "L", function()
    local win = getFocusedWindow()
    if win then
        win:moveOneScreenEast(false, true)
    end
end)

-- Move window to next monitor (cycles through all monitors)
hs.hotkey.bind({"ctrl", "alt"}, "N", function()
    local win = getFocusedWindow()
    if win then
        win:moveToScreen(win:screen():next())
    end
end)

-- ============================================================================
-- MOVE WINDOWS BETWEEN WORKSPACES
-- ============================================================================
-- Move window to specific workspace (1-10)
local function moveWindowToWorkspace(workspaceNum)
    local win = getFocusedWindow()
    if not win then
        hs.alert.show("No focused window")
        return
    end

    -- Get all spaces for all screens
    local allSpaces = spaces.allSpaces()

    -- Get spaces for the main screen (where Mission Control shows workspace numbers)
    local mainScreen = hs.screen.primaryScreen()
    local screenUUID = mainScreen:getUUID()
    local screenSpaces = allSpaces[screenUUID]

    -- Debug logging
    print("=== Move to workspace " .. workspaceNum .. " ===")
    print("Screen UUID: " .. screenUUID)
    print("Total spaces found: " .. (screenSpaces and #screenSpaces or 0))
    print("Current space: " .. spaces.focusedSpace())

    if screenSpaces then
        for i, spaceID in ipairs(screenSpaces) do
            print("  Space " .. i .. ": " .. spaceID)
        end
    end

    if not screenSpaces then
        hs.alert.show("Could not get spaces")
        return
    end

    if #screenSpaces < workspaceNum then
        hs.alert.show("Workspace " .. workspaceNum .. " does not exist (only " .. #screenSpaces .. " spaces)")
        return
    end

    local targetSpace = screenSpaces[workspaceNum]
    print("Moving window " .. win:id() .. " to space " .. targetSpace)

    spaces.moveWindowToSpace(win, targetSpace)

    print("Move complete")
    hs.alert.show("Moved to workspace " .. workspaceNum)
end

-- Bind Ctrl + Alt + 1-9 and 0 (for workspace 10)
for i = 1, 9 do
    hs.hotkey.bind({"ctrl", "alt"}, tostring(i), function()
        moveWindowToWorkspace(i)
    end)
end

-- Handle 0 as workspace 10
hs.hotkey.bind({"ctrl", "alt"}, "0", function()
    moveWindowToWorkspace(10)
end)

-- ============================================================================
-- WINDOW POSITIONING - HALVES
-- ============================================================================
-- Left half
hs.hotkey.bind({"ctrl", "alt"}, "Left", function()
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
hs.hotkey.bind({"ctrl", "alt"}, "Right", function()
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
hs.hotkey.bind({"ctrl", "alt"}, "Up", function()
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
hs.hotkey.bind({"ctrl", "alt"}, "Down", function()
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
-- CENTER WINDOW
-- ============================================================================
-- Center window on screen (maintains size)
hs.hotkey.bind({"ctrl", "alt"}, "C", function()
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
hs.hotkey.bind({"ctrl", "alt"}, ";", function()
    hs.hints.windowHints()
end)
