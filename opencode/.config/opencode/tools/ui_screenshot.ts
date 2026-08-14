import { tool } from "@opencode-ai/plugin";
import { mkdir, lstat } from "node:fs/promises";
import { join } from "node:path";

const runtimeDir = process.env.XDG_RUNTIME_DIR;

function exact(value: string) {
    return value.length > 0 && value.length <= 256 && !value.includes("\0");
}

function safeSegment(value: string) {
    return /^[A-Za-z0-9_-]+$/.test(value);
}

type Client = {
    address?: string;
    at?: [number, number];
    class?: string;
    mapped?: boolean;
    size?: [number, number];
    title?: string;
};

function address(value: string) {
    return /^0x[0-9a-f]+$/.test(value);
}

async function matchingClients(
    className?: string,
    title?: string,
    windowAddress?: string,
) {
    const clients = (await Bun.$`hyprctl -j clients`.json()) as Client[];
    return clients.filter(
        (client) =>
            client.mapped !== false &&
            (!className || client.class === className) &&
            (!title || client.title === title) &&
            (!windowAddress || client.address === windowAddress),
    );
}

async function privateDirectory(path: string) {
    await mkdir(path, { recursive: true, mode: 0o700 });
    const metadata = await lstat(path);
    if (
        !metadata.isDirectory() ||
        metadata.isSymbolicLink() ||
        metadata.uid !== process.getuid() ||
        (metadata.mode & 0o077) !== 0
    ) {
        throw new Error(
            "The UI screenshot artifact directory is not private and safe.",
        );
    }
}

export default tool({
    description:
        "Capture the visible screen region occupied by one uniquely matched Hyprland window. The image cannot include content obscured by another window.",
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
    async execute(args, context) {
        if (!runtimeDir) {
            throw new Error(
                "XDG_RUNTIME_DIR is required for UI screenshot artifacts.",
            );
        }
        if (
            !safeSegment(context.sessionID) ||
            !safeSegment(context.messageID)
        ) {
            throw new Error(
                "OpenCode supplied an unsafe UI screenshot artifact identifier.",
            );
        }
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

        const matches = await matchingClients(
            args.class,
            args.title,
            args.address,
        );
        if (matches.length === 0) {
            return "No Hyprland windows matched the supplied exact selector.";
        }
        if (matches.length !== 1) {
            return `${matches.length} Hyprland windows matched the supplied exact selector; refine it.`;
        }

        // Give the approval UI time to disappear, then re-resolve geometry.
        await Bun.sleep(750);
        const settledMatches = await matchingClients(
            args.class,
            args.title,
            args.address,
        );
        if (settledMatches.length !== 1) {
            return "The matched window changed while capture approval was pending; retry the review.";
        }
        const client = settledMatches[0];
        const [x, y] = client.at ?? [];
        const [width, height] = client.size ?? [];
        if (
            ![x, y, width, height].every(Number.isSafeInteger) ||
            width <= 0 ||
            height <= 0
        ) {
            throw new Error(
                "The matched window has invalid Hyprland geometry.",
            );
        }

        const reviewDir = join(runtimeDir, "opencode-ui-review");
        const directory = join(reviewDir, context.sessionID);
        await privateDirectory(reviewDir);
        await privateDirectory(directory);

        const output = join(
            directory,
            `window-${context.messageID}-${crypto.randomUUID()}.png`,
        );
        try {
            await lstat(output);
            throw new Error("The UI screenshot artifact already exists.");
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
        }
        const geometry = `${x},${y} ${width}x${height}`;
        await Bun.$`grim -g ${geometry} ${output}`.quiet();
        return JSON.stringify({
            status: "captured",
            path: output,
            scope: "visible-unoccluded-region",
        });
    },
});
