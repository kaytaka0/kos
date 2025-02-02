# ゼロからのOS自作入門　作業記録


内田公太氏の「ゼロからのOS自作入門」でのOS作成作業を記録として記す。




## 開発環境

- Ubuntu 20.04
- X11 forwardingによるGUIウィンドウの転送
  - Ubuntuマシンで開発＋Macから操作
  - Client:  M1 Maccbook Air
  - X11 Server: opensshの機能を利用
  - X11 Client: XQuartz
  - コード記述: VSCode Remote ssh + ssh



## Debug

- https://community.platformio.org/t/ld-fails-when-trying-to-create-a-unity-unit-test-on-an-m3-mac-with-platform-native/40072

> Ok, found out the problem - the issue is actually to do with the version of ‘ar’ that is used. The correct version is /usr/bin/ar - normally part of the Mac CommandLineTools. I had installed homebrew binutils which was at the beginning of the path, and the ar included by that causes the problem. The fix (at least to get platformio going properly) was to uninstall the binutils package using ‘brew uninstall binutils’
