# scimex
一个macOS简体中文输入法的插件

## 简介
通过向输入法进程注入代码, 实现下面几个功能:
1. 使用 <kbd>Shift</kbd> 切换中英文
2. 使用 <kbd>CapsLock</kbd> 切换大写英文
3. 中文状态下使用英文标点

由于使用了代码注入技术, 所以需要关闭部分[SIP功能](https://support.apple.com/zh-cn/HT204899).

## 如何关闭SIP
1. 开机时按住 <kbd>Command</kbd> + <kbd>R</kbd>, 进入RecoveryHD模式
2. 点击菜单上的 `实用工具` -> `终端`, 进入终端
3. 在终端中执行命令 `csrutil enable --without debug`
4. 重新启动

## 注意事项
1. 考虑到本插件的使用人群, 所以直接使用了中文.
2. 目前只有基础功能, 并且没有做配置选项, 一旦启用则会开插件的全部功能.
3. 如有其他需求, 请自行修改并编译.
4. 欢迎贡献代码.