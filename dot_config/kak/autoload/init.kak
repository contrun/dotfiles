hook global BufCreate .*[.](sbt) %{
    set-option buffer filetype scala
}

hook global RegisterModified '"' %{ nop %sh{
    printf %s "$kak_main_reg_dquote" | clipboard
}}

nop %sh{
    [[ -d "%val{config}/plugins/plug.kak/" ]] || git clone https://github.com/robertmeta/plug.kak.git "%val{config}/plugins/plug.kak/"
}
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "lePerdu/kakboard" %{
    hook global WinCreate .* %{ kakboard-enable }
}

plug "https://gitlab.com/Screwtapello/kakoune-state-save" config %{
    hook global KakBegin .* %{
        state-save-reg-load colon
        state-save-reg-load pipe
        state-save-reg-load slash
    }

    hook global KakEnd .* %{
        state-save-reg-save colon
        state-save-reg-save pipe
        state-save-reg-save slash
    }

    hook global FocusOut .* %{ state-save-reg-save dquote }
    hook global FocusIn  .* %{ state-save-reg-load dquote }
}

plug "kak-lsp/kak-lsp" do %{
    cargo build --release --locked
    cargo install --force --path .
} config %{
    # uncomment to enable debugging
    eval %sh{echo ${kak_opt_lsp_cmd} >> /tmp/kak-lsp.log}
    set global lsp_cmd "kak-lsp -s %val{session} -vvv --log /tmp/kak-lsp.log"

    # this is not necessary; the `lsp-enable-window` will take care of it
    # eval %sh{${kak_opt_lsp_cmd} --kakoune -s $kak_session}

    set global lsp_diagnostic_line_error_sign '║'
    set global lsp_diagnostic_line_warning_sign '┊'

    define-command ne -docstring 'go to next error/warning from lsp' %{ lsp-find-error --include-warnings }
    define-command pe -docstring 'go to previous error/warning from lsp' %{ lsp-find-error --previous --include-warnings }
    define-command ee -docstring 'go to current error/warning from lsp' %{ lsp-find-error --include-warnings; lsp-find-error --previous --include-warnings }

    define-command lsp-restart -docstring 'restart lsp server' %{ lsp-stop; lsp-start }
    hook global WinSetOption filetype=(c|cpp|cc|rust|javascript|typescript|go|haskell|sh|css|html|latex|nix|python|ruby|terraform|scala) %{
        set-option window lsp_auto_highlight_references true
        set-option window lsp_hover_anchor false
        lsp-auto-hover-enable
        echo "Enabling LSP for filtetype %opt{filetype}"
        lsp-enable-window
    }

    hook global WinSetOption filetype=(scala) %{
        set global lsp_server_configuration metals.superMethodLenses=true
    }

    hook global WinSetOption filetype=(rust) %{
        set window lsp_server_configuration rust.clippy_preference="on"
    }

    hook global WinSetOption filetype=rust %{
        hook window BufWritePre .* %{
            evaluate-commands %sh{
                test -f rustfmt.toml && printf lsp-formatting-sync
            }
        }
    }

    hook global KakEnd .* lsp-exit
}

plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ': fzf-mode<ret>'
}

plug "danr/kakoune-easymotion" config %{
    map global user w :easy-motion-w<ret>
    map global user W :easy-motion-W<ret>
    map global user j :easy-motion-j<ret>
}