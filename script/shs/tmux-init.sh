BACKEND_SESSION="backend"
HOME_SESSION="home"

# MINECRAFT_DIR="$HOME/.local/share/PrismLauncher/instances/server/minecraft"
# MINECRAFT_WORLD_DIR="$HOME/.local/share/PrismLauncher/instances/server/minecraft/world"
# GEMINI_DIR="$HOME/gemini-balance"
# CLAUDE_DIR="$HOME/.claude-code-router"

tmux new-session -d -s "$BACKEND_SESSION" -n "Backend Process" -c "$HOME"
# tmux new-window -t "$BACKEND_SESSION" -n "Minecraft Server" -c "$MINECRAFT_DIR"
# tmux split-window -h -t "${BACKEND_SESSION}:Minecraft Server" -c "$MINECRAFT_WORLD_DIR"
# tmux select-pane -t backend:"Minecraft Server".1
tmux select-window -t "${BACKEND_SESSION}:Backend Process"

tmux new-session -d -s "$HOME_SESSION" -c "$HOME"

# PROJECT_NAME="schedule"
# PROJECT_PATH="$HOME/schedule"
# tmux new-session -d -s "$PROJECT_NAME" -n "AI" -c "$PROJECT_PATH"
# tmux new-window -t "$PROJECT_NAME" -n "Code" -c "$PROJECT_PATH"
# tmux new-window -t "$PROJECT_NAME" -n "Build" -c "$PROJECT_PATH"
# tmux select-window -t "${PROJECT_NAME}:Code"
