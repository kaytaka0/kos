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
