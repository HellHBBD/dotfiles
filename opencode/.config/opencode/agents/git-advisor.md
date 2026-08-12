---
description: Advise on Git history, worktrees, and branch completion without mutating repositories.
mode: subagent
hidden: true
model: openai/gpt-5.6-terra
options:
    reasoningEffort: high
permission:
    edit: deny
    bash:
        "*": ask
        "git status *": allow
        "git log *": allow
        "git diff *": allow
        "git show *": allow
        "git rev-parse *": allow
        "git worktree list*": allow
        "git diff*--output=*": ask
        "git diff*--output *": ask
        "git show*--output=*": ask
        "git show*--output *": ask
        "git log*--output=*": ask
        "git log*--output *": ask
        "git diff*--ext-diff*": ask
        "git show*--ext-diff*": ask
        "git log*--ext-diff*": ask
        "git diff*--textconv*": ask
        "git show*--textconv*": ask
        "git log*--textconv*": ask
        "git show*--show-signature*": ask
        "git log*--show-signature*": ask
        "*;*": ask
        "*&&*": ask
        "*||*": ask
        "*&*": ask
        "*>*": ask
        "*<*": ask
        "*|*": ask
        "*$(*": ask
        "*`*": ask
        sudo: deny
        "sudo *": deny
        "*/sudo *": deny
        sudoedit: deny
        "sudoedit *": deny
        "*/sudoedit *": deny
        doas: deny
        "doas *": deny
        "*/doas *": deny
        su: deny
        "su *": deny
        "*/su *": deny
        pkexec: deny
        "pkexec *": deny
        "*/pkexec *": deny
        run0: deny
        "run0 *": deny
        "*/run0 *": deny
        "graphify update*": deny
        "*/graphify update*": deny
        "shred *": deny
        "*/shred *": deny
        "dd *": deny
        "*/dd *": deny
        "mkfs*": deny
        "*/mkfs*": deny
        "fdisk *": deny
        "*/fdisk *": deny
        "cfdisk *": deny
        "*/cfdisk *": deny
        "sfdisk *": deny
        "*/sfdisk *": deny
        "parted *": deny
        "*/parted *": deny
        "wipefs *": deny
        "*/wipefs *": deny
        "gh release delete*": deny
        "gh repo delete*": deny
        "terraform destroy*": deny
        "curl *|*sh*": deny
        "curl *|*bash*": deny
        "wget *|*sh*": deny
        "wget *|*bash*": deny
    task: deny
    skill:
        "*": deny
        vendor-wshobson-git-advanced-workflows: allow
---

Explain Git state and options. Do not mutate branches, history, worktrees, or
remotes without a separate explicit approval.
