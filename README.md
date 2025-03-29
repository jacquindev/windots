<h3>
<div align="center">
<img src="./.github/assets/title.png" alt="title">

<br>

A Windows 11 Dotfiles Repo infused with <a href="https://catppuccin.com/">Catppuccin</a> Theme
<a href="https://twitter.com/intent/tweet?text=Windows%2011%20Dotfiles%20Infused%20With%20Catppuccin%20Theme&url=https://github.com/jacquindev/windots"><img src="https://img.shields.io/badge/Tweet-share-8AADF4?style=social&logo=x&logoColor=8AADF4&labelColor=302D41&color=8AADF4" alt="TWITTER"></a>&nbsp;&nbsp;

</div>

<br>

</h3>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/windots?style=for-the-badge&logo=github&logoColor=EBA0AC&label=Last%20Commit&labelColor=302D41&color=EBA0AC"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/"><img src="https://img.shields.io/github/repo-size/jacquindev/windots?style=for-the-badge&logo=hyprland&logoColor=F9E2AF&label=Size&labelColor=302D41&color=F9E2AF" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/windots?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/windots?style=for-the-badge&logo=starship&color=B7BDF8&logoColor=B7BDF8&labelColor=302D41"></a>&nbsp;&nbsp;
</p>
</div>

<hr>

> [!IMPORTANT]
> The below **screenshots** are taken on my main monitor, which has the **resolution of 3440x1440**.
> Configurations in this repository seem to work seamlessly on my **1920x1080** monitors as well.

<br>

<div align="center">
  <a href="#preview"><kbd> <br> 🌆 Preview <br> </kbd></a>&ensp;&ensp;
  <a href="#install"><kbd> <br> 🌷 Install <br> </kbd></a>&ensp;&ensp;
  <a href="#extras"><kbd> <br> 🧱 Extras <br> </kbd></a>&ensp;&ensp;
  <a href="#features"><kbd> <br> ✨ Features <br> </kbd></a>&ensp;&ensp;
  <a href="#credits"><kbd> <br> 🎉 Credits <br> </kbd></a>&ensp;&ensp;
  <a href="#author"><kbd> <br> 👤 Author <br> </kbd></a>&ensp;&ensp;
</div>

<hr>

## ⚠️ Disclaimer

Since I work with this repository everyday to maintain ***latest updates*** for my Windows machine, many apps or packages will be **add** / **remove** / **reconfigure** to fit my personal taste.

So, please keep in mind that:

- **This repository is under very active development.**
- You might expect bugs and breaking changes.

<br>

## ✨ Prerequisites

- **[Git for Windows](https://gitforwindows.org/)**
- **[PowerShell 7](https://github.com/PowerShell/PowerShell)**

***Highly Recommended:***

- **[Windows Terminal](https://aka.ms/terminal)** or **[Windows Terminal Preview](https://aka.ms/terminal-preview)**

<br>

<h2 id="preview">🌆 Preview</h2>

- 2 status bar options: [Rainmeter](https://github.com/modkavartini/catppuccin/tree/main) / [Yasb](./config/config/yasb)

### Yasb's Catppuccin Statusbar

![yasb1](./.github/assets/yasb1.png)<br/><br/>
![lazygit](./.github/assets/lazygit.png)<br/><br/>
![preview](./.github/assets/preview.png)<br/><br/>
![yasb3](./.github/assets/yasb3.png)<br/><br/>

### Rainmeter's Catppuccin Statusbar

![rainmeter1](./.github/assets/rainmeter1.png)<br/><br/>
![rainmeter2](./.github/assets/rainmeter2.png)<br/><br/>
![rainmeter3](./.github/assets/rainmeter3.png)<br/><br/>

- Transparent File Explorer

### [ExplorerBlurMica](https://github.com/Maplespe/ExplorerBlurMica) + [Catppuccin Themes](https://www.deviantart.com/niivu/art/Catppuccin-for-Windows-11-1076249390)

![fileexplorer](./.github/assets/fileexplorer.png)

<hr>

<h2 id="install">🌷 Install</h2>

- Simply clone this repo to `your_location`

```bash
git clone https://github.com/jacquindev/windots.git your_location
cd `your_location`
```

- In your **elevated** PowerShell Terminal, run: `.\Setup.ps1`

```pwsh
. .\Setup.ps1
```

<h4>⁉️ Overriding Defaults</h4>

> [!IMPORTANT]
> Before running the `Setup.ps1` script, please check the **[appList.json](./appList.json)** file to **ADD/REMOVE** the apps you would like to install.<br/>
>
> <b><i><ins>VSCode Extensions:</ins></i></b><br/>
> Edit the **[VSCode's extensions list](./extensions.list)** to **ADD/REMOVE** the extensions you would like to install.

<br>

<details open>
<summary><b>😎 Clink Setup</b></summary>

- In your **`Command Prompt`** console, type:

  ```cmd
  clink installscripts "your_location\clink\clink-custom"
  clink installscripts "your_location\clink\clink-completions"
  clink installscripts "your_location\clink\clink-gizmos"
  clink installscripts "your_location\clink\more-clink-completions"
  ```

- Replace _`your_location`_ with full path to where you cloned this repository.

</details>

> [!NOTE]
> The [`clink-custom`](./clink/clink-custom/) directory contains Lua scripts to [extend `clink`](https://chrisant996.github.io/clink/clink.html#extending-clink) based on the programs you use.
> If you don't have any of the corresponding programs, you can disable them by commenting out the files or simply remove them:
>
> - `oh-my-posh` - [`clink/clink-custom/oh-my-posh.lua`](./clink/clink-custom/oh-my-posh.lua)
> - `starship` - [`clink/clink-custom/starship.lua`](./clink/clink-custom/starship.lua)
> - `vfox` - [`clink/clink-custom/vfox.lua`](./clink/clink-custom/vfox.lua)
> - `zoxide` - [`clink/clink-custom/zoxide.lua`](./clink/clink-custom/zoxide.lua)

<br>

<details open>
<summary><b>🌟 Bootstrap WSL</b></summary>
<br>

> [!IMPORTANT]
> - WSL setup can be done automatically by using [Ansible](https://docs.ansible.com/ansible/latest/index.html). Any details can be found here: https://github.com/jacquindev/automated-wsl2-setup.
> - WSL dotfiles are maintained in [this](https://github.com/jacquindev/dotfiles) repository: https://github.com/jacquindev/dotfiles.

</details>
<br>

<h3 id="extras">⛏🧱 Extra Setup (optional)</h3>

Follow the below links to download and learn to how to setup:

<details>
<summary><b>🌈 Catppuccin Themes 🎨</b></summary>
<br>
<div align="center">
<table>
<tr>
  <td><a href="https://www.deviantart.com/niivu/art/Catppuccin-Cursors-921387705">Cursors</a></td>
  <td><img src="./.github/assets/cursors.png" alt="cursors"></td>
</tr>
<tr>
  <td><a href="https://www.deviantart.com/niivu/art/Catppuccin-for-Windows-11-1076249390">Themes</a></td>
  <td><img src="./.github/assets/themes.png" alt="themes"></td>
</tr>
</table>
</div>
</details>

<details>
<summary><b>🎸 Spicetify Setup 🎧</b></summary>
<br>
<div align="left">
<table>
<tr>
<th>Addons</th>
<th>Name</th>
</tr>
<tr>
<td>Extensions</td>
<td>
  <a href="https://github.com/surfbryce/beautiful-lyrics">Beautiful Lyrics</a>&nbsp;
  <a href="https://github.com/spicetify/cli">Bookmark</a>&nbsp;
  <a href="https://github.com/huhridge/huh-spicetify-extensions">Full App Display</a>&nbsp;
  <a href="https://github.com/spicetify/cli">Shuffle+</a>&nbsp;
  <a href="https://github.com/spicetify/cli">Trash Bin</a>&nbsp;
</td>
</tr>
<td>Themes</td>
<td>
  <a href="https://github.com/Comfy-Themes/Spicetify">Comfy Themes</a>&nbsp;
  <a href="./config/config/spicetify/comfy.js">⚙️</a>
</td>
<tr>
</tr>
</table>
</div>
</details>

<br>

<h2 id="features">✨ Features</h2>

- 💫 All packages to install are listed in **[appList.json file](./appList.json)** - Easy to maintain!
- 🎨 Main theme [Catppuccin](https://github.com/catppuccin/catppuccin) for everything!
- 🎀 Minimal [Yasb](https://github.com/amnweb/yasb) status bar
- 💖 Beautiful **_[wallpapers](https://github.com/jacquindev/windots/tree/main/windows/walls#readme)_**, and [live wallpapers](./windows/walls/live-walls/) for [Lively Wallpapers](https://www.rocksdanister.com/lively/)
- 🪟 [Komorebi](./config/komorebi) config
- 🌸 All-In-One VSCode setup (**_[extensions list](./extensions.list)_**)
- ⚙️ [Rainmeter](./windows/rainmeter/) setup
- \>\_ Sleek [Windows Terminal config](./config/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json)
- 🌈 Oh-My-Posh [minimal theme](./dotposh/posh-zen.toml) (with Spotify status if playing)
- 🦄 **Super fast** PowerShell startup time _(load asynchronously)_ + [custom configurations & modules](./dotposh/)
- 🍄 Simple fastfetch configuration, which I copied from [scottmckendry's config](https://github.com/scottmckendry/Windots/tree/main/fastfetch)
- 🥂 Many [addons](#git-addons) for Git!
- 🐱 Use [MISE](https://mise.jdx.dev/) *(mise-en-place)* to manage [development tools](https://mise.jdx.dev/dev-tools/). Learn more about `mise` here: https://mise.jdx.dev/

<details open>
<br>
<summary><b>🖥️ CLI/TUI Apps</b></summary>

| Entry                 | App                                                                                           |
| --------------------- | --------------------------------------------------------------------------------------------- |
| **Terminal Emulator** | [Windows Terminal](https://github.com/microsoft/terminal) [⚙️](./config/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json)       |
| **File Explorer**     | [yazi](https://github.com/sxyazi/yazi) [⚙️](./config/config/yazi/)                                   |
| **Fuzzy File Finder** | [fzf](https://github.com/junegunn/fzf)                                                        |
| **System Monitor**    | [btop](https://github.com/aristocratos/btop)                                                  |
| **System Fetch**      | [fastfetch](https://github.com/fastfetch-cli/fastfetch) [⚙️](./config/AppData/Local/fastfetch/config.jsonc) |
| **Git TUI**           | [lazygit](https://github.com/jesseduffield/lazygit) [⚙️](./config/AppData/Local/lazygit/config.yml)         |

</details>

<br>

<details open>
<br>
<summary><b>🌎 Replacement</b></summary>

| Entry | App                                                                      |
| ----- | ------------------------------------------------------------------------- |
| cat   | [bat](https://github.com/sharkdp/bat) [⚙️](./config/AppData/Roaming/bat/config) |
| cd    | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| ls    | [eza](https://github.com/eza-community/eza) [⚙️](./config/eza/theme.yml) |
| find  | [fd](https://github.com/sharkdp/fd) |
| grep  | [ripgrep](https://github.com/sharkdp/ripgrep) |

</details>

<br>

<details open>
<br>
<summary><b>🖱️ GUI Apps</b></summary>

| Entry            | App                                            |
| ---------------- | ---------------------------------------------- |
| **App Launcher** | [Flow Launcher](https://www.flowlauncher.com/) |
| **Music Player** | [Spotify](https://open.spotify.com/)           |

</details>

<br>

<details open>
<br>
<summary id="git-addons"><b>📌 Git Addons</b></summary>

| Installer | Link | Description |
| --- | --- | --- |
| winget | **[GitHub Desktop](https://github.com/apps/desktop)** | Simple collaboration from your desktop.|
| winget | **[GitKraken Desktop](https://www.gitkraken.com/)** | Dev Tools that simplify & supercharge Git. |
| scoop | **[gh](https://github.com/cli/cli)** | Bring GitHub to the command line. |
| scoop | **[git-aliases](https://github.com/AGWA/git-crypt)** | Oh My Zsh's Git aliases for PowerShell. |
| scoop | **[git-crypt](https://github.com/AGWA/git-crypt)** | Transparent file encryption in Git. |
| scoop | **[git-filter-repo](https://github.com/newren/git-filter-repo)** | Quickly rewrite git repository history (filter-branch replacement). |
| scoop | **[git-lfs](https://git-lfs.com/)** | Improve then handling of large files. |
| scoop | **[git-sizer](https://github.com/github/git-sizer)** | Compute various size metrics for a Git repository. |
| scoop | **[gitleaks](https://github.com/gitleaks/gitleaks)** | Detect secrets like passwords, API keys, and tokens. |
| npm | **[commitizen](https://github.com/commitizen/cz-cli)** + **[cz-git](https://cz-git.qbb.sh/)** | Write better Git commits. |
| npm | **[git-open](https://github.com/paulirish/git-open)** | Open the GitHub page or website for a repository in your browser. |
| npm | **[git-recent](https://github.com/paulirish/git-recent)** | See your latest local git branches, formatted real fancy. |
| | **[git aliases](https://github.com/GitAlias/gitalias/blob/main/gitalias.txt)** | Include [git aliases](./config/config/gitaliases) for `git` command for faster version control. |

</details>



<details open>
<br>
<summary><b>📝 Text Editor / Note Taking</b></summary>

- [Notepad++](https://notepad-plus-plus.org/)
- [Obsidian](https://obsidian.md/)
- [Visual Studio Code](https://code.visualstudio.com/) [⚙️](./config/AppData/Roaming/Code/User/settings.json)

</details>

<br>

<h2 id="credits">🎉 Credits</h2>

Big thanks for those inspirations:

- [scottmckendry's Windots](https://github.com/scottmckendry/Windots)
- [ashish0kumar's windots](https://github.com/ashish0kumar/windots)
- [MattFTW's Dotfiles](https://github.com/Matt-FTW/dotfiles) - Most of my wallpapers are from here.
- [DevDrive PowerShell's Scripts](https://github.com/ran-dall/Dev-Drive) - I copied most of DevDrive's functions for PowerShell here.

<br>

<h2 id="author">👤 Author</h2>

- Name: **Jacquin Moon**
- Github: [@jacquindev](https://github.com/jacquindev)
- Email: jacquindev@outlook.com

<br>

<h2 id="license">📜 License</h2>

This repository is released under the [MIT License](https://github.com/jacquindev/windots/blob/main/LICENSE).

Feel free to use and modify these dotfiles to suit your needs.

<br>

## Show your support

Please give a ⭐️ if this project helped you!

<a href="https://www.buymeacoffee.com/jacquindev" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="43" width="176"></a>
