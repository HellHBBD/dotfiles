---
description: Perform read-only, evidence-based code and project-rules reviews.
mode: subagent
hidden: true
model: openai/gpt-5.6-terra
options:
    reasoningEffort: high
permission:
    edit: deny
    bash:
        "*": ask
        "git status*": allow
        "git diff*": allow
        "git show*": allow
        "git log*": allow
        "git rev-parse*": allow
        "git branch --show-current*": allow
        "git merge-base*": allow
        "git blame*": allow
        "git for-each-ref*": allow
        "git count-objects -v*": allow
        "git submodule status*": allow
        "gh pr view*": allow
        "gh pr diff*": allow
        "gh pr checks*": allow
        "gh run list*": allow
        "gh run view*": allow
        "gh workflow view*": allow
        "git blame*--contents=*": ask
        "git blame*--contents *": ask
        "git blame*--ignore-revs-file=*": ask
        "git blame*--ignore-revs-file *": ask
        "git for-each-ref*--stdin*": ask
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
        "gh pr view*--web*": ask
        "gh pr diff*--web*": ask
        "gh pr diff*--allow-escape-sequences*": ask
        "gh pr checks*--watch*": ask
        "gh pr checks*--web*": ask
        "gh run view*--web*": ask
        "gh workflow view*--web*": ask
        "*;*": ask
        "*&&*": ask
        "*||*": ask
        "*&*": ask
        "*>*": ask
        "*<*": ask
        "*|*": ask
        "*$(*": ask
        "*`*": ask
        "opencode debug agent *--tool*": deny
        "*/opencode debug agent *--tool*": deny
        "opencode debug agent *--params*": deny
        "*/opencode debug agent *--params*": deny
        "nmcli *--show-secrets*": deny
        "* nmcli *--show-secrets*": deny
        "nmcli -s*": deny
        "nmcli * -s*": deny
        "* nmcli * -s*": deny
        "nmcli *show-password*": deny
        "* nmcli *show-password*": deny
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
        superpower-receiving-code-review: allow
        vendor-wshobson-code-review-excellence: allow
        vendor-wshobson-visual-design-foundations: allow
        vendor-wshobson-design-system-patterns: allow
        vendor-wshobson-accessibility-compliance: allow
        vendor-wshobson-responsive-design: allow
        vendor-wshobson-interaction-design: allow
---

Review code or project rules without editing them. Load permitted skills that
match the review scope; for UI reviews, select only the necessary visual,
responsive, accessibility, interaction, or design-system skills. Report
concrete, prioritized findings with file references and explain any remaining
uncertainty.
