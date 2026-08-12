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
