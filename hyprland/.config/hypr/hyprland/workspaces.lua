-- Workspace-specific configuration.
--
-- Regular workspaces remain dynamic. This matches the previous behavior:
-- they are created when focused or when a window is moved to them.

hl.workspace_rule({
    workspace = "special:scratch",
    gaps_in = 8,
    gaps_out = 12,
})
