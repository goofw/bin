version=$(basename $(curl -fsSL -o /dev/null -w %{url_effective} https://github.com/tmux/tmux-builds/releases/latest))
curl -fsSL https://github.com/tmux/tmux-builds/releases/latest/download/https://github.com/tmux/tmux-builds/releases/download/v3.6a/tmux-${version:1}-linux-x86_64.tar.gz | tar -xz tmux
mv tmux tmux-static
