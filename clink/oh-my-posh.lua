__ohmyposh_dir = os.getenv('USERPROFILE')..'/AppData/Local/Programs/oh-my-posh'

local ohmyposh_themes = __ohmyposh_dir..'/themes'
local ohmyposh_prompt = clink.promptfilter(1)
function ohmyposh_prompt:filter(prompt)
    return load(io.popen("oh-my-posh init cmd --config "..ohmyposh_themes.."/ys.omp.json"):read("*a"))()
end