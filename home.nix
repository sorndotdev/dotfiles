{ config, pkgs, llmStack, ... }:

let
    dotfiles = "${config.home.homeDirectory}/.dotfiles";
    llmStackDir = pkgs.runCommand "llm-stack-opencode" { } ''
        mkdir -p $out
        cp -r ${llmStack}/skills ${llmStack}/agents ${llmStack}/scripts $out/
        substituteInPlace $out/skills/cloudflare-api/SKILL.md \
            --replace-fail "<path>/scripts/cloudflare/cloudflare-api.py" "$out/scripts/cloudflare-api.py"
        for f in $out/skills/*/SKILL.md; do
            substituteInPlace "$f" --replace "<path>" "$out"
        done
        chmod -R +x $out/scripts
    '';
in

{
    home.username = "sorn";
    home.homeDirectory = "/Users/sorn";
    home.stateVersion = "24.11";
    home.packages = with pkgs; [
        ripgrep # fast search
        fd      # fast find
        fzf     # fuzzy finder
        jq      # json
        lazygit
        neovim
        nerd-fonts.hack
        python3
    ];
    fonts.fontconfig.enable = true;
    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          bindkey '^f' autosuggest-accept
          # shift/option+arrows jump words (CSI-u codes sent by wezterm)
          bindkey $'\x1b[1;2D' backward-word
          bindkey $'\x1b[1;2C' forward-word
          bindkey $'\x1b[1;3D' backward-word
          bindkey $'\x1b[1;3C' forward-word
        '';
        shellAliases = {
            ".." = "cd ..";
            add = "git add .";
            push = "git push";
            pull = "git pull";
            m = "git switch master";
            vi = "nvim";
            vim = "nvim";
            oc = "opencode --auto";
        };
    };
    programs.git.settings.user = {
        name = "sorn";
        email = "maksumic@protonmail.com";
    };
    programs.starship = {
        enable = true;
        settings = {
            add_newline = false;
            format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
            character = {
                success_symbol = "[❯](purple)";
                error_symbol = "[❯](red)";
            };
            cmd_duration.format = "[$duration]($style) ";
        };
    };
    home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
    };
    home.file.".config/wezterm".source =
    	config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
    home.file.".config/nvim".source =
    	config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    home.file.".config/tmux".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/tmux";
    home.file.".config/opencode/opencode.jsonc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/opencode/opencode.jsonc";
        force = true;
    };
    home.file.".config/opencode/tui.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/opencode/tui.json";
        force = true;
    };
    home.file.".config/opencode/agents".source = "${llmStackDir}/agents";
    home.file.".agents/skills".source = "${llmStackDir}/skills";
}
