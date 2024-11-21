local ohmyposh_dir = os.getenv('LOCALAPPDATA') .. '/Programs/oh-my-posh'
local ohmyposh_themes = ohmyposh_dir .. '/themes'
local ohmyposh_prompt = clink.promptfilter(1)

function ohmyposh_prompt:filter(prompt)
  return load(io.popen("oh-my-posh init cmd --config " .. ohmyposh_themes .. "/catppuccin_mocha.omp.json"):read("*a"))()
end
