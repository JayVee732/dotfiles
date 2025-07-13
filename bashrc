# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Programs
alias protontricks='flatpak run com.github.Matoking.protrontricks'
alias protontricks-launch='flatpak run --command=protontricks-launch com.github.Matoking.protontricks'
alias kid3-cli='flatpak run --command=kid3-cli org.kde.kid3'
alias code='flatpak run com.vscodium.codium'
alias n='nano'
alias sn='sudo nano'
alias dosbox='flatpak run com.dosbox_x.DOSBox-X'
alias gearlever='flatpak run it.mijorus.gearlever'

# Commands
alias yt='yt-dlp -f "bv+ba/b" --add-metadata -ic'
alias yta='yt-dlp -f "ba" --add-metadata -ic'
alias gap='git add -p'
alias psbbn='distrobox enter --root psbbn'
