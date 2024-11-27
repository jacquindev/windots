<h3 align="center">
<div align="center">
<img src="./assets/title.png" alt="title">

<br>
<br>

A Windows 11 Dotfiles Repo infused with <a href="https://catppuccin.com/">Catppuccin</a> Theme
<a href="https://twitter.com/intent/tweet?text=Windows%2011%20Dotfiles%20Infused%20With%20Catppuccin%20Theme&url=https://github.com/jacquindev/windots"><img src="https://img.shields.io/badge/Tweet-share-8AADF4?style=social&logo=x&logoColor=8AADF4&labelColor=302D41&color=8AADF4" alt="TWITTER"></a>&nbsp;&nbsp;

</div>
</h3>

<hr>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/windots?style=for-the-badge&logo=github&logoColor=EBA0AC&label=Last%20Commit&labelColor=302D41&color=EBA0AC"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/"><img src="https://img.shields.io/github/repo-size/jacquindev/windots?style=for-the-badge&logo=hyprland&logoColor=F9E2AF&label=Size&labelColor=302D41&color=F9E2AF" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/windots?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/windots?style=for-the-badge&logo=starship&color=B7BDF8&logoColor=B7BDF8&labelColor=302D41"></a>&nbsp;&nbsp;
</p> 
</div>

> [!IMPORTANT]<br>
> **Screenshots** are taken on my main monitor, which has the **resolution of 3440x1440**.<br>
> Works seamlessly on my **1920x1080** monitors as well!

<div align="center">
  <a href="#preview"><kbd> <br> 🌆 Preview <br> </kbd></a>&ensp;&ensp;
  <a href="#install"><kbd> <br> 🌷 Install <br> </kbd></a>&ensp;&ensp;
  <a href="#extras"><kbd> <br> 🧱 Extras <br> </kbd></a>&ensp;&ensp;
  <a href="#features"><kbd> <br> ✨ Features <br> </kbd></a>&ensp;&ensp;
  <a href="#credits"><kbd> <br> 🎉 Credits <br> </kbd></a>&ensp;&ensp;
  <a href="#author"><kbd> <br> 👤 Author <br> </kbd></a>&ensp;&ensp;
</div>

<br>
<hr>

## ✨ Prerequisites

- **[Git for Windows](https://gitforwindows.org/)**
- **[PowerShell 7](https://github.com/PowerShell/PowerShell)**

<h2 id="preview">🌆 Preview</h2>

- 2 status bar options: [Rainmeter](https://github.com/modkavartini/catppuccin/tree/main) / [Yasb](./config/yasb)

### Yasb's Catppuccin Statusbar

![yasb1](./assets/yasb1.png)<br/><br/>
![yasb2](./assets/yasb2.png)<br/><br/>

### Rainmeter's Catppuccin Statusbar

![rainmeter1](./assets/rainmeter1.png)<br/><br/>
![rainmeter2](./assets/rainmeter2.png)<br/><br/>
![rainmeter3](./assets/rainmeter3.png)<br/><br/>

- Transparent File Explorer

### [ExplorerBlurMica](https://github.com/Maplespe/ExplorerBlurMica) + [Catppuccin Themes](https://www.deviantart.com/niivu/art/Catppuccin-for-Windows-11-1076249390)

![fileexplorer](./assets/fileexplorer.png)

<hr>

<div align="center">
  <video src="https://github.com/user-attachments/assets/c6e214f5-d4ca-4bf6-81e3-16e74a1a08bc"></video>
  <video src="https://github.com/user-attachments/assets/b068e898-1007-4f19-8076-7b8637e261dc"></video>
</div>

<hr>

<h2 id="install">🌷 Install</h2>

- Simply clone this repo to `your_location`
- `cd` into `your_location`

```bash
git clone https://github.com/jacquindev/windots.git your_location
```

- In your PowerShell Terminal, run: `.\Setup.ps1`

```pwsh
.\Setup.ps1
```

> [!NOTE]
> Before running the `Setup.ps1` script, please check the [appList.json](./appList.json) to **ADD/REMOVE** the apps you would like to install.

<br>

<details open>
<summary><b>😎 Clink Setup</b></summary>
  
- In your **`Command Prompt`** console, type:

```cmd
clink installscripts "your_location\clink\clink-custom"
clink installscripts "your_location\clink\clink-completions"
clink installscripts "your_location\clink\clink-gizmos"
```

- Replace _`your_location`_ with full path to where you cloned this repository.

</details>

<br>

<details open>
<summary><b>🌟 WSL Setup</b></summary>
<br>

- Any configurations related to **WSL** are maintained in this repo: 👉👉 **[dotfiles](https://github.com/jacquindev/dotfiles)** 👈👈

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
  <td><img src="./assets/cursors.png" alt="cursors"></td>
</tr>
<tr>
  <td><a href="https://www.deviantart.com/niivu/art/Catppuccin-for-Windows-11-1076249390">Themes</a></td>
  <td><img src="./assets/themes.png" alt="thems"></td>
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
  <a href="./config/spicetify/comfy.js">⚙️</a>
</td>
<tr>
</tr>
</table>
</div>
</details>

<hr>

<h2 id="features">✨ Features</h2>

- 💫 All packages to install are listed in **[appList.json file](./appList.json)** - Easy to maintain!
- 🎨 Main theme [Catppuccin](https://github.com/catppuccin/catppuccin) for everything!
- 🎀 Minimal [Yasb](https://github.com/amnweb/yasb) status bar
- 💖 Beautiful **_[wallpapers](https://github.com/jacquindev/windots/tree/main/windows/walls#readme)_**, and [live wallpapers](./windows/walls/live-walls/) for [Lively Wallpapers](https://www.rocksdanister.com/lively/)
- 🪟 [Komorebi](./config/komorebi) / [GlazeWM](./config/glazewm/config.yaml) config
- 🌸 All-In-One VSCode setup (**_[extensions list](./vscode/extensions.list)_**)
- ⚙️ [Rainmeter](./windows/rainmeter/) setup
- \>\_ Sleek [Windows Terminal config](./windows/settings.json)
- 🌈 Oh-My-Posh [minimal theme](./dotposh/posh-zen.toml) (with Spotify status if playing!)
- 🦄 **Super fast** PowerShell startup time *(load asynchronously)* + **[custom functions](./dotposh/Modules/)**
- 🍄 Simple fastfetch configuration, which I copied from [scottmckendry's config](https://github.com/scottmckendry/Windots/tree/main/fastfetch)
- 🥂 Many addons for Git!

<details>
<summary><b>🖥️ CLI/TUI Apps</b></summary>

| Entry                 | App                                                                                           |
| --------------------- | --------------------------------------------------------------------------------------------- |
| **Terminal Emulator** | [Windows Terminal](https://github.com/microsoft/terminal) [⚙️](./windows/settings.json)       |
| **File Explorer**     | [yazi](https://github.com/sxyazi/yazi) [⚙️](./config/yazi/)                                   |
| **Fuzzy File Finder** | [fzf](https://github.com/junegunn/fzf)                                                        |
| **System Monitor**    | [btop](https://github.com/aristocratos/btop)                                                  |
| **System Fetch**      | [fastfetch](https://github.com/fastfetch-cli/fastfetch) [⚙️](./config/fastfetch/config.jsonc) |
| **Git TUI**           | [lazygit](https://github.com/jesseduffield/lazygit) [⚙️](./config/lazygit/config.yml)         |

</details>

<details>
<summary><b>🌎 Replacement</b></summary>

| Entry | App                                                                      |
| ----- | ------------------------------------------------------------------------ |
| cat   | [bat](https://github.com/sharkdp/bat) [⚙️](./config/bat/config)          |
| cd    | [zoxide](https://github.com/ajeetdsouza/zoxide)                          |
| ls    | [eza](https://github.com/eza-community/eza) [⚙️](./config/eza/theme.yml) |
| find  | [fd](https://github.com/sharkdp/fd)                                      |
| grep  | [ripgrep](https://github.com/sharkdp/ripgrep)                            |

</details>

<details>
<summary><b>🎧 Spotify</b></summary>
<br>
<table style="width:100%">
<tr>
  <th><a href="https://spicetify.app/">spicetify</a></th>
  <th><a href="https://github.com/Rigellute/spotify-tui">spotify-tui</a> <a href="./config/spotify-tui/config.yml">⚙️</a></th>
</tr>
<tr style="height:400px,width:630px">
  <td><video alt="spicetify" src="https://github.com/user-attachments/assets/a622561e-1c6e-421a-87fe-4ef675c0a54f"></video></td>
  <td><video alt="spotify-tui" src="https://github.com/user-attachments/assets/577c96b1-4e57-4864-b19c-48b06a10c3c5"></video></td>
</tr>
</table>
</details>

<details>
<summary><b>🖱️ GUI Apps</b></summary>

| Entry            | App                                            |
| ---------------- | ---------------------------------------------- |
| **App Launcher** | [Flow Launcher](https://www.flowlauncher.com/) |
| **Music Player** | [Spotify](https://open.spotify.com/)           |
| **Web Browser**  | [Zen Browser](https://www.zen-browser.com/)    |

</details>
<details>
<summary><b>📌 Git Addons</b></summary>

| Installer | Link                                                                                          | Description                                                        |
| --------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| winget    | **[GitHub Desktop](https://github.com/apps/desktop)**                                         | Simple collaboration from your desktop                             |
| scoop     | **[gh](https://github.com/cli/cli)**                                                          | Bring GitHub to the command line                                   |
| scoop     | **[git-crypt](https://github.com/AGWA/git-crypt)**                                            | Transparent file encryption in Git                                 |
| scoop     | **[git-filter-repo](https://github.com/newren/git-filter-repo)**                              | Quickly rewrite git repository history (filter-branch replacement) |
| scoop     | **[git-lfs](https://git-lfs.com/)**                                                           | Improve then handling of large files                               |
| scoop     | **[git-sizer](https://github.com/github/git-sizer)**                                          | Compute various size metrics for a Git repository                  |
| scoop     | **[bfg](https://rtyley.github.io/bfg-repo-cleaner/)**                                         | Remove large or troublesome blobs (required **java** installed)    |
| npm       | **[commitizen](https://github.com/commitizen/cz-cli)** + **[cz-git](https://cz-git.qbb.sh/)** | Write better Git commits                                           |
| npm       | **[git-open](https://github.com/paulirish/git-open)**                                         | Open the GitHub page or website for a repository in your browser   |
| npm       | **[git-recent](https://github.com/paulirish/git-recent)**                                     | See your latest local git branches, formatted real fancy           |

</details>
<details>
<summary><b>📝 Text Editor / Note Taking</b></summary>

- [Notepad++](https://notepad-plus-plus.org/)
- [Obsidian](https://obsidian.md/)
- [VSCode](https://code.visualstudio.com/) [⚙️](./vscode/settings.json)

</details>

<hr>
<h2 id="credits">🎉 Credits</h2>

Big thanks for those inspirations:

- [scottmckendry's Windots](https://github.com/scottmckendry/Windots)
- [ashish0kumar's windots](https://github.com/ashish0kumar/windots)
- [MattFTW's Dotfiles](https://github.com/Matt-FTW/dotfiles) - Most of my wallpapers are from here.
- [DevDrive PowerShell's Scripts](https://github.com/ran-dall/Dev-Drive) - I copied most of DevDrive's functions for PowerShell here.

<hr>
<h2 id="author">👤 Author</h2>

**Jacquin Moon**

- Github: [@jacquindev](https://github.com/jacquindev)
- Email: jacquindev@outlook.com

<hr>
<h2 id="license">📜 License</h2>

This repository is released under the [MIT License](https://github.com/jacquindev/windots/blob/main/LICENSE).

Feel free to use and modify these dotfiles to suit your needs.

<hr>
<h2>Show your support</h2>

Give a ⭐️ if this project helped you!
