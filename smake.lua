local import = import('smake/libraryInstaller')
import('smake/gpp', true)

--- @type fs
local fs = import('smake/utils/fs')

function smake.build(shouldRun)
  runIn('build', 'cmake -G Ninja .. && ninja')

  fs.Move('build/compile_commands.json', './')

  if shouldRun then
    run('build/swindow')
  end
end

function smake.clean()
  if fs.Exists("build") then
    fs.DeleteFolder('build')
  end

  fs.CreateFolder("build")
end
