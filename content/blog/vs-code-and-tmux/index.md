---
title: "Persistent terminals in VS Code with tmux"
date: 2022-03-12T21:33:01Z
draft: false
description: "How to get persistent terminal sessions in VS Code with tmux"
keywords: ["ssh", "VS Code", "Visual Studio Code"]
tags: ["development"]
math: false
toc: false
comments: true
---

Since I've started using [VS Code over SSH]({{< relref "vs-code-over-ssh" >}}),
I've encountered the slight irritation that the session will drop when I suspend my laptop.
This is to be expected, as the underlying TCP connection can't survive without regular keepalives.
Restarting the remote session means that I lose the integrated terminals that I have open,
meaning I have to go through and type out `yarn dev` or `go run` again.
What is particularly annoying is that the previously running programs will continue in the background,
so I have to go and manually kill them before I can work again.

The standard way to work around these sorts of problems is to use a terminal multiplexer,
such as the venerable [GNU Screen](https://www.gnu.org/software/screen/),
or the slightly more modern [tmux](https://github.com/tmux/tmux).
A terminal multiplexer is a program that allows you to open multiple terminals in one window,
and will persist these sessions even if your SSH connection drops.
I've previously used these for things like running game servers[^1],
and they also work great with VS Code
-- meaning you are able to restart your VS Code session,
and all your terminals will be in the same state.

[^1]: Specifically for Minecraft.
You can use a more standard approach like a systemd service,
but Minecraft servers sometimes need to be controlled via their `stdin`. 

You can set up VS Code to use a custom command to open a new terminal window.
Here is what I have in my `settings.json` file:

```json
{
    "terminal.integrated.profiles.linux": {
        "bash": null,
        "tmux": {
            "path": "bash",
            "args": ["-c", "tmux new -ADs ${PWD##*/}"],
            "icon": "terminal-tmux",
        },
    },
    "terminal.integrated.defaultProfile.linux": "tmux",
}
```

This creates a new terminal profile called `tmux`,
and sets it as the default profile -- meaning whenever you open the integrated terminal,
it will run the command specified.
In this case it runs `bash`, with the command `tmux new -ADs ${PWD##*/}`.
This will create a new tmux session with the name of the current working directory,
or attach to an existing session if one exists.
The `-D` flag ensures that only one terminal is connected to a session at a time.
The way that this works for me is that I will then have tmux sessions for each of my workspace folders,
then when needed I will create extra tabs in the tmux sessions.

{{< image src="workspace" alt="VS Code using tmux" >}}

There is a bit of jankiness here,
in that instead of just running `tmux new -ADs ${workspaceFolderBasename}`,
we have to use a shell parameter expansion.
This is because in a multi-folder workspace,
[`${workspaceFolderBasename}`](https://code.visualstudio.com/docs/editor/variables-reference#_predefined-variables) doesn't respect the folder I selected to open the terminal in
-- it always uses the folder of the currently open file.
We can emulate what I think `${workspaceFolderBasename}` should return using `${PWD##*/}`, which produces the basename of the current working directory.
This produces the desired effect of a separate tmux session for each of my workspace folders.

I still use this setup when I'm working in VS Code locally,
as it means I can close it when done for the day,
and then when I reopen it the next day I'll still have all my terminals open.
One amusing side effect of this workflow is that it seems to prevent the OOM killer from closing my terminal sessions,
only striking down VS Code itself.

You will probably want to configure tmux a little to make it more usable,
like rebinding the prefix to `Ctrl`+`a` (`set -g prefix C-a`) and turning on mouse mode (`set -g mouse on`).
One thing to watch out for with mouse mode is that it will use tmux's copy paste buffers,
which are still a bit of a mystery to me.
Luckily if you hold shift while selecting text it bypasses tmux's buffers,
so you can `Ctrl`+`c` `Ctrl`+`v` like usual.