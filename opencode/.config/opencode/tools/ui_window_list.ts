import { tool } from "@opencode-ai/plugin";

type Client = {
    address?: string;
    class?: string;
    mapped?: boolean;
    title?: string;
    workspace?: { name?: string };
};

function quote(value: string) {
    return JSON.stringify(value);
}

export default tool({
    description:
        "List mapped Hyprland windows and copyable exact selectors. Use only after the user explicitly asks to list desktop windows.",
    args: {},
    async execute() {
        const clients = (await Bun.$`hyprctl -j clients`.json()) as Client[];
        const windows = clients
            .filter((client) => client.mapped !== false)
            .sort((left, right) =>
                [
                    left.workspace?.name ?? "",
                    left.class ?? "",
                    left.title ?? "",
                    left.address ?? "",
                ]
                    .join("\0")
                    .localeCompare(
                        [
                            right.workspace?.name ?? "",
                            right.class ?? "",
                            right.title ?? "",
                            right.address ?? "",
                        ].join("\0"),
                    ),
            );
        if (windows.length === 0)
            return "No mapped Hyprland windows are available.";

        return [
            "Window titles may contain sensitive information.",
            ...windows.map((client, index) => {
                const className = client.class ?? "";
                const title = client.title ?? "";
                const workspace = client.workspace?.name ?? "unknown";
                const duplicates = windows.filter(
                    (other) =>
                        other.class === client.class &&
                        other.title === client.title,
                ).length;
                const selector =
                    duplicates > 1 && client.address
                        ? `/ui-review window class=${quote(className)} title=${quote(title)} address=${quote(client.address)}`
                        : `/ui-review window class=${quote(className)} title=${quote(title)}`;
                return `${index + 1}. workspace=${quote(workspace)}\n   class=${quote(className)}\n   title=${quote(title)}\n   ${selector}`;
            }),
        ].join("\n");
    },
});
