set -o vi

ble-import integration/fzf-completion
ble-import integration/fzf-key-bindings

function blerc/kyemap-vi-load-hook {
    bleopt keymap_vi_mode_show=

    ble-bind -m vi_nmap --cursor 2
    ble-bind -m vi_imap --cursor 5
    ble-bind -m vi_omap --cursor 4
    ble-bind -m vi_xmap --cursor 2
    ble-bind -m vi_cmap --cursor 0
}
blehook/eval-after-load keymap_vi blerc/kyemap-vi-load-hook
