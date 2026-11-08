# My .zshrc
This .zshrc basically sets keybinds, completion, history, $PROMPT, the 4 dependencies below, and some aliases for ls & adding colours
### Requirements
#### Debian
`zsh-syntax-highlighting zsh-autosuggestions command-not-found bat (for man page colouring)`
#### Arch
`zsh-syntax-highlighting zsh-autosuggestions pkgfile bat`
#### Fedora
`zsh-syntax-highlighting zsh-autosuggestions bat`

### Install
```
mv $HOME/.zshrc $HOME/.zshrc.old
curl -o $HOME/.zshrc https://raw.githubusercontent.com/ethanp4/zshrc/refs/heads/main/.zshrc
```

# Powershell
I have made the robot make a clone of it for powershell
### Requirements
Windows comes preinstalled with powershell 5, you might want to install powershell 7 manually

```
winget install ajeetdsouza.zoxide Git.Git
Install-Module Microsoft.WinGet.CommandNotFound
```

### Install
```
mv $profile "$(echo $profile).old"
curl -o $HOME/.zshrc https://raw.githubusercontent.com/ethanp4/zshrc/refs/heads/main/Microsoft.PowerShell_profile.ps1
```
