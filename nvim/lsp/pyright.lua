local os_name = vim.loop.os_uname().sysname
local config_path
if os_name == 'Linux' then
  config_path = '.venv/bin/python'
elseif os_name == 'Windows_NT' then
  config_path = '.venv/Scripts/python.exe'
end

return {
  settings = {
    -- 仮想環境パスは pyrightconfig.jsonで管理
    -- pyrightconfig.jsonはllmに書いてもらう
    -- python = {
    --   pythonPath = config_path,
    --   analysis = {
    --     ignore = { '*' },
    --   },
    -- },
    pyright = {
      disableOrganizeImports = true,
    },
  }
}
