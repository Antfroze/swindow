local import = import('smake/libraryInstaller')
import('smake/gpp', true)

local utils = import('smake/utils/utils')
--- @type fs
local fs = import('smake/utils/fs')

local function moveCompiledFiles()
  local files = utils.ExecuteCommand('ls ./', '*all');

  for file in files:gmatch('%S+') do
    if file:match('o$') then
      utils.ExecuteCommand('mv ' .. file .. ' lib/')
    end
  end
end

local function removeCompiledFiles()
  local files = utils.ExecuteCommand('ls lib/', '*all');

  for file in files:gmatch('%S+') do
    if file:match('o$') then
      utils.ExecuteCommand('rm lib/' .. file)
    end
  end
end

function smake.build()
  if not fs.Exists("lib") then
    fs.CreateFolder("lib")
  end

  standard('c++2a')
  flags('-c')
  inputr('src', 'cpp')
  inputr('src', 'mm')
  include({ 'src', 'include' })

  generateCompileFlags()
  build()

  moveCompiledFiles()
  utils.ExecuteCommand('ar rcs lib/libswindow.a lib/*.o')
  removeCompiledFiles()
end

function smake.run()
  if not fs.Exists("out") then
    fs.CreateFolder("out")
  end

  standard('c++2a')
  inputr('src', 'cpp')
  inputr('src', 'mm')
  include({ 'src', 'include' })

  if platform.is_osx then
    framework('Cocoa', 'IOKit', 'CoreFoundation', 'CoreVideo')
  end

  generateCompileFlags()
  output('out/swindow')
  build()

  run('out/swindow')
end

smake.i = smake.install
