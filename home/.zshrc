for _zsh_file in ~/.config/zsh/*.zsh(N); do
    source "$_zsh_file"
done
unset _zsh_file

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
