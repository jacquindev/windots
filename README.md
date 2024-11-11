<h1 align="center">👋 windots 👋</h1>

> [!NOTE]
> I am using **3440x1440** monitor as my main display.
> Please remember to adjust your settings (eg: Komorebi/GlazeWM) according to your monitor resolution.

<br>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/windots?style=for-the-badge&logo=github&logoColor=eba0ac&label=Last%20Commit&labelColor=302D41&color=eba0ac"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/"><img src="https://img.shields.io/github/repo-size/jacquindev/windots?style=for-the-badge&logo=hyprland&logoColor=f9e2af&label=Size&labelColor=302D41&color=f9e2af" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/dotfiles?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/windots/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/windots?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
</p>  
</div>

<br>

<div align="center">
  <a href="#preview"><kbd> <br> 🌆 Preview <br> </kbd></a>&ensp;&ensp;
  <a href="#install"><kbd> <br> 🌷 Install <br> </kbd></a>&ensp;&ensp;
  <a href="#features"><kbd> <br> ✨ Features <br> </kbd></a>&ensp;&ensp;
  <a href="#credits"><kbd> <br> 🎉 Credits <br> </kbd></a>&ensp;&ensp;
  <a href="#author"><kbd> <br> 👤 Author <br> </kbd></a>&ensp;&ensp;
</div>

<h2 id="preview">🌆 Preview</h2>

- 2 status bar options: [Rainmeter](./windows/rainmeter/skins/catppuccin_1.4.1.rmskin) / [Yasb](./config/yasb)

### Yasb's Catppuccin Statusbar

![image1](https://github.com/user-attachments/assets/002f4976-1fe5-4d3f-8522-d73f21f77a32)
![image2](https://github.com/user-attachments/assets/7ac89878-c98b-4c09-8dd5-608ee72b9c0e)

### Rainmeter's Catppuccin Statusbar

![image3](https://github.com/user-attachments/assets/ea59ed02-34b4-4f0e-ac62-fb6517817c1f)<br/><br/>
![image4](https://github.com/user-attachments/assets/ba8b4031-249c-442e-9afd-939f680e1c9e)<br/><br/>
![image5](https://github.com/user-attachments/assets/814adafb-fa16-4144-b429-6ec6f08b7da9)<br/><br/>

<hr/>

https://github.com/user-attachments/assets/c6e214f5-d4ca-4bf6-81e3-16e74a1a08bc

https://github.com/user-attachments/assets/b068e898-1007-4f19-8076-7b8637e261dc

<h2 id="install">🌷 Install</h2>

- Simply clone this repo to `your_location`
- `cd` in `your_location`

```bash
git clone https://github.com/jacquindev/windots.git your_location
```

- In your PowerShell Terminal, run: `.\Setup.ps1`

```pwsh
.\Setup.ps1
```

<h2 id="features">✨ Features</h2>

- 💎 All packages to install are listed in **[appList.json](./appList.json)** - Easy to maintain!
- 🎀 [Yasb](https://github.com/amnweb/yasb) status bar that compatible with Komorebi
- 🎨 Main theme [Catppuccin](https://github.com/catppuccin/catppuccin) for everything!
- 💖 Beautiful wallpapers, including [images](./windows/walls/pics/) & [videos](./windows/walls/live-walls/) for [Lively Wallpapers](https://www.rocksdanister.com/lively/)
- 🪟 [Komorebi](./config/komorebi) / [GlazeWM](./config/glazewm/config.yaml) config
- 🌸 All-In-One VSCode setup (automatically install extensions based on the **[list](./vscode/extensions.list)**)
- ⚙️ Minimal [Rainmeter](./windows/rainmeter/) setup
- \>\_ Sleek Windows Terminal config
- 🌈 [Oh-My-Posh config](./dotposh/posh-zen.toml) minimal theme (with [Spotify](https://open.spotify.com/) status if using)
- 🦄 [PowerShell](https://github.com/PowerShell/PowerShell) setup & **[custom functions](./dotposh/Modules/)**
- 🍄 Simple [fastfetch](https://github.com/fastfetch-cli/fastfetch) config, which I copied the config from [scottmckendry's config](https://github.com/scottmckendry/Windots/tree/main/fastfetch)
- 🥂 Many addons for Git!

<hr/>

### 🖥️ CLI/TUI Apps

| Entry                 | App                                                                                           |
| --------------------- | --------------------------------------------------------------------------------------------- |
| **Terminal Emulator** | [Windows Terminal](https://github.com/microsoft/terminal) [⚙️](./windows/settings.json)       |
| **File Explorer**     | [yazi](https://github.com/sxyazi/yazi) [⚙️](./config/yazi/)                                   |
| **Fuzzy File Finder** | [fzf](https://github.com/junegunn/fzf)                                                        |
| **System Monitor**    | [btop](https://github.com/aristocratos/btop)                                                  |
| **System Fetch**      | [fastfetch](https://github.com/fastfetch-cli/fastfetch) [⚙️](./config/fastfetch/config.jsonc) |
| **Git TUI**           | [lazygit](https://github.com/jesseduffield/lazygit) [⚙️](./config/lazygit/config.yml)         |

#### 🌎 Replacement

| Entry | App                                                                      |
| ----- | ------------------------------------------------------------------------ |
| cat   | [bat](https://github.com/sharkdp/bat) [⚙️](./config/bat/config)          |
| cd    | [zoxide](https://github.com/ajeetdsouza/zoxide)                          |
| ls    | [eza](https://github.com/eza-community/eza) [⚙️](./config/eza/theme.yml) |
| find  | [fd](https://github.com/sharkdp/fd)                                      |
| grep  | [ripgrep](https://github.com/sharkdp/ripgrep)                            |

#### 🎧 Spotify

- [Spicetify](https://spicetify.app/)
- [spotify-tui](https://github.com/Rigellute/spotify-tui) [⚙️](./config/spotify-tui/config.yml)

### 🖱️ GUI Apps

| Entry            | App                                            |
| ---------------- | ---------------------------------------------- |
| **App Launcher** | [Flow Launcher](https://www.flowlauncher.com/) |
| **Music Player** | [Spotify](https://open.spotify.com/)           |
| **Web Browser**  | [Zen Browser](https://www.zen-browser.com/)    |

#### 📝 Text Editor / Note Taking

- [Notepad++](https://notepad-plus-plus.org/)
- [Obsidian](https://obsidian.md/)
- [VSCode](https://code.visualstudio.com/) [⚙️](./vscode/settings.json)

<h2 id="credits">🎉 Credits</h2>

Big thanks for those inspirations:

- [scottmckendry's Windots](https://github.com/scottmckendry/Windots)
- [ashish0kumar's windots](https://github.com/ashish0kumar/windots)
- [MattFTW's Dotfiles](https://github.com/Matt-FTW/dotfiles) - Most of my wallpapers are from here.
- [DevDrive PowerShell's Scripts](https://github.com/ran-dall/Dev-Drive) - I copied most of DevDrive's functions for PowerShell here.

<h2 id="author">👤 Author</h2>

**Jacquin Moon**

- Github: [@jacquindev](https://github.com/jacquindev)
- Email: jacquindev@outlook.com

## 📜 License

Feel free to use and modify these dotfiles to suit your needs.

## Show your support

Give a ⭐️ if this project helped you!
