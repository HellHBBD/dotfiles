import { tool } from "@opencode-ai/plugin";

function exact(value: string) {
    return value.length > 0 && value.length <= 256 && !value.includes("\0");
}

function address(value: string) {
    return /^0x[0-9a-f]+$/.test(value);
}

export default tool({
    description:
        "Check whether an exact Hyprland class, title, and/or address selector identifies one window without exposing unrelated window metadata.",
    args: {
        class: tool.schema
            .string()
            .optional()
            .describe("Exact Hyprland window class."),
        title: tool.schema
            .string()
            .optional()
            .describe("Exact Hyprland window title."),
        address: tool.schema
            .string()
            .optional()
            .describe("Exact ephemeral Hyprland window address."),
    },
    async execute(args) {
        if (
            (!args.class && !args.title && !args.address) ||
            (args.class && !exact(args.class)) ||
            (args.title && !exact(args.title)) ||
            (args.address && !address(args.address))
        ) {
            throw new Error(
                "Provide an exact non-empty class, title, and/or address selector.",
            );
        }
        const clients = await Bun.$`hyprctl -j clients`.json();
        const count = clients.filter(
            (client: {
                address?: string;
                class?: string;
                mapped?: boolean;
                title?: string;
            }) =>
                client.mapped !== false &&
                (!args.class || client.class === args.class) &&
                (!args.title || client.title === args.title) &&
                (!args.address || client.address === args.address),
        ).length;
        if (count === 1)
            return "The supplied exact selector identifies one window.";
        if (count === 0)
            return "No window matches the supplied exact selector.";
        return `${count} windows match the supplied exact selector; refine it.`;
    },
});
