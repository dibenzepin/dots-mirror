# macOS

- Every time an app is reinstalled/updated, you'll need to give it permissions again (e.g. Full Disk Access, Keychain Access, Developer Tools). This is most prevalent in Zed which has a pretty fast release schedule. This can be worked around by using the Homebrew version of the app.
- Vesktop/Chrome cannot stream the entire screen of a high-resolution Retina display (in this case, a 15" MacBook Air set to the "More Space" scaling factor) due to inherent limitations in the amount of data that can be used for a frame in OpenH264. You can work around this by temporarily lowering your resoltution to stream, or by streaming an individual app/window.
- in a mac for nix-collect-garbage -d to work you need to add nix and wait4path to full disk access even though it's invisible: https://github.com/NixOS/nix/issues/6765#issuecomment-2889356952 (todo add to setup guide)
