#!/bin/bash
# ~/.config/install.sh

# 1. 自动映射家目录的配置文件（手工打链接）
echo "正在创建软连接..."
ln -sf ~/.config/tmux.conf ~/.tmux.conf
# 如果你还有其他需要放回家目录的文件，可以继续在这里加，比如：
# ln -sf ~/.config/zshrc ~/.zshrc

# 2. 配置 zsh
echo "正在配置 zsh..."
if ! grep -q "source ~/.config/zshrc" ~/.zshrc 2>/dev/null; then
  echo "source ~/.config/zshrc" >>~/.zshrc
fi

# ==========================================
# 3. 检测系统并安装常用软件
# ==========================================
echo "正在检测操作系统..."
if [ -f /etc/os-release ]; then
  # 读取系统信息
  . /etc/os-release
  OS=$ID
  VERSION_ID=$VERSION_ID
else
  echo "❌ 无法检测操作系统，跳过软件自动安装。"
  exit 1
fi

if [ "$OS" == "arch" ]; then
  echo "🟢 检测到 Arch Linux，正在使用 pacman 安装..."
  # Arch 比较省事，都在官方仓库里
  sudo pacman -Syu --needed zsh neovim tmux yazi fastfetch ffmpeg p7zip jq poppler fd ripgrep fzf zoxide imagemagick curl wget

elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
  echo "🟠 检测到 Ubuntu/Debian，正在使用 apt 安装..."
  sudo apt update
  # 安装基础工具、网络工具和 Yazi 的必须依赖项
  sudo apt install -y curl wget zsh neovim tmux ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick

  # ---------- 安装 Yazi ----------
  echo "📦 正在从 GitHub 下载最新版 Yazi (musl deb)..."
  # 调用 GitHub API 获取最新版 release 信息，提取以 musl.deb 结尾的下载链接
  YAZI_URL=$(curl -s https://gh-proxy.org/https://api.github.com/repos/sxyazi/yazi/releases/latest | grep "browser_download_url" | grep "yazi-x86_64-unknown-linux-musl.deb" | cut -d '"' -f 4)

  if [ -n "$YAZI_URL" ]; then
    wget -qO /tmp/yazi.deb "$YAZI_URL"
    sudo dpkg -i /tmp/yazi.deb
    rm /tmp/yazi.deb
    echo "✅ Yazi 安装成功！"
  else
    echo "❌ 获取 Yazi 下载链接失败，请检查网络（可能是 GitHub 访问不畅）。"
  fi

  # ---------- 安装 Fastfetch ----------
  if [ "$OS" == "ubuntu" ]; then
    # 提取 Ubuntu 的大版本号（比如 22.04 提取出 22，24.04 提取出 24）
    UBUNTU_MAJOR=$(echo "$VERSION_ID" | cut -d'.' -f1)
    if [ "$UBUNTU_MAJOR" -lt 25 ]; then
      echo "🦤 你的 Ubuntu 版本低于 25，正在添加 PPA 仓库安装 fastfetch..."
      sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
      sudo apt update
      sudo apt install -y fastfetch
    else
      echo "🦤 你的 Ubuntu 版本为 25 或以上，尝试直接使用 apt 安装 fastfetch..."
      sudo apt install -y fastfetch
    fi
  else
    # 针对原版 Debian 系统
    echo "🌀 Debian 系统尝试直接 apt 安装 fastfetch..."
    sudo apt install -y fastfetch
  fi
else
  echo "⚠️ 不支持的操作系统：$OS，请手动安装相关软件。"
fi

echo "🍾 部署完成"

# 需要解决的问题
# 1.默认使用的是bash，是不是应该使用切换到zsh作为默认
# 2.fastfetch 的 add-apt-repository: command not found docker上面的问题，是不是个例
# 3..oh-my-zsh没有配置
# 4. pokemon-colorscripts 是fastfetch的包，需要自动安装。还是怎么搞。
#
