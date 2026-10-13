for _openjdk in /opt/homebrew/opt/openjdk/bin /usr/local/opt/openjdk/bin; do
    [ -d "$_openjdk" ] && export PATH="$_openjdk:$PATH"
done
unset _openjdk
