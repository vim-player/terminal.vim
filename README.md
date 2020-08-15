# terminal.vim

> commands for terminal

## Commands

### Top

- `:TermvimTopOpen` 顶部打开 terminal
- `:TermvimTopHide` 隐藏顶部 terminal
- `:TermvimTopToggle`: toggle
- `let g:termvim_top_size = 10`

### Bottom

- `:TermvimBottomOpen` 底部打开 terminal
- `:TermvimBottomHide` 隐藏底部 terminal
- `:TermvimBottomToggle`: toggle
- `let g:termvim_bottom_size = 10`

### Left

- `:TermvimLeftOpen` 左边打开 terminal
- `:TermvimLeftHide` 隐藏左边 terminal
- `:TermvimLeftToggle`: toggle
- `let g:termvim_left_size = 10`

### Right

- `:TermvimRightOpen` 右边打开 terminal
- `:TermvimRightHide` 隐藏右边 terminal
- `:TermvimRightToggle`: toggle
- `let g:termvim_right_size = 10`

### Watching

- `:TermvimWatch yarn webpack --watch`

> `yarn webpack --watch` 可以是任何命令

在当前 buffer 打开终端运行 `yarn webpack --watch` 命令,
如果终端隐藏，在终端输出的时候自动打开新 tab 查看结果，
按 `q` 或 `<Esc>` 关闭 tab
