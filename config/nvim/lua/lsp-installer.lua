-- Simple LSP server installer script
-- This helps install common LSP servers

local M = {}

M.install_commands = {
  -- TypeScript/JavaScript
  tsserver = "npm install -g typescript typescript-language-server",
  
  -- Ruby
  solargraph = "gem install solargraph",
  
  -- Python
  pyright = "npm install -g pyright",
  
  -- Lua
  lua_ls = function()
    print("For lua-language-server, please install from: https://github.com/LuaLS/lua-language-server")
    print("Or use: brew install lua-language-server")
  end,
  
  -- Additional servers you might want:
  eslint = "npm install -g vscode-langservers-extracted",
  json = "npm install -g vscode-langservers-extracted",
  html = "npm install -g vscode-langservers-extracted",
  css = "npm install -g vscode-langservers-extracted",
}

function M.print_install_commands()
  print("LSP Server Installation Commands:")
  print("================================")
  for server, cmd in pairs(M.install_commands) do
    if type(cmd) == "function" then
      print(server .. ":")
      cmd()
    else
      print(server .. ": " .. cmd)
    end
    print("")
  end
end

return M
