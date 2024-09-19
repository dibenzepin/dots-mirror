# ~

my dotfiles, with home-manager (+ extra config stuff)

||
|:-:|
|![a terminal showing neofetch output with ascii art](sample.png)|

## to use

- install nix (with the determinate sytems [installer](https://github.com/DeterminateSystems/nix-installer))
- for first run, run `make init`
- consequently, `make update` and `make switch` work

### packages

- [x] git (basic)
- [ ] git (advanced: auth, signing, etc.)
- [x] starship
- [x] neofetch
- [x] zoxide (+ fzf)
- [x] atuin
- [x] typst
- [x] jujustu

### fonts

- [x] fontconfig
- [x] code new roman nerd font
- [x] fira code nerd font
- [x] inter
- [x] apple color emoji

### files

- [x] `.zshrc` (source ~/.nix-zshrc)
- [x] `run-or-raise`

### todo

- [ ] look into [lix](https://lix.systems)
- [ ] add helix config

### random commands

- `sudo touch /etc/NetworkManager/conf.d/20-connectivity-fedora.conf` [^2]
- `sudo ln -s /usr/bin/wezterm /usr/bin/gnome-terminal` [^4]

#### ff `about:config` extras

- `browser.tabs.insertAfterCurrent`: true [^1]
- `apz.fling_min_velocity_threshold`: 2 [^3]
- `apz.gtk.pangesture.page_delta_mode_multiplier`: 0.5 [^3]
- `apz.overscroll.enabled`: true [^3]
- `apz.touch_acceleration_factor_y`: 0.5 [^3]

#### vscode `argv.json`

- `password-store`: "basic" [^5]

[^1]: cos i like having it not thrown to the end: [https://support.mozilla.org/en-US/questions/1348563](https://support.mozilla.org/en-US/questions/1348563) ([archive](https://web.archive.org/web/20240531224738/https://support.mozilla.org/en-US/questions/1348563))
[^2]: no moar captive portals: [https://unix.stackexchange.com/a/423708](https://support.mozilla.org/en-US/questions/1348563) ([archive](https://web.archive.org/web/20240531224903/https://unix.stackexchange.com/questions/419422/wifi-disable-hotspot-login-screen))
[^3]: better scrolling experience (overscroll!!): [https://discourse.gnome.org/t/add-touchpad-scroll-sensitivity-adjustment-feature/18097/11](https://discourse.gnome.org/t/add-touchpad-scroll-sensitivity-adjustment-feature/18097/11) ([archive](https://web.archive.org/web/20240531230223/https://discourse.gnome.org/t/add-touchpad-scroll-sensitivity-adjustment-feature/18097/11))
[^4]: just make kitty the default term: [https://askubuntu.com/a/1346310](https://askubuntu.com/a/1346310) ([archive](https://web.archive.org/web/20240602132636/https://askubuntu.com/questions/1346170/changing-terminal-emulator-from-gnome-terminal-to-kitty-breaks-some-functionalit))
[^5]: stop "unlock keyring" stuff: [https://github.com/microsoft/vscode/issues/187284](https://github.com/microsoft/vscode/issues/187284)
