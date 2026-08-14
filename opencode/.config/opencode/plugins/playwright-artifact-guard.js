// Keep runtime evidence inside the fixed MCP output directory. The MCP may
// create its own filenames, but agents cannot select a path via tool arguments.
export const PlaywrightArtifactGuard = async () => ({
    "tool.execute.before": async (input, output) => {
        if (!input.tool.startsWith("playwright_")) return;
        if (Object.hasOwn(output.args ?? {}, "filename")) {
            throw new Error(
                "Playwright artifact filenames are disabled; use the fixed runtime artifact directory.",
            );
        }

        if (input.tool !== "playwright_browser_navigate") return;
        const url = output.args?.url;
        if (typeof url !== "string") {
            throw new Error("Playwright navigation requires a loopback URL.");
        }
        let parsed;
        try {
            parsed = new URL(url);
        } catch {
            throw new Error(
                "Playwright navigation requires a valid loopback URL.",
            );
        }
        if (
            !["http:", "https:"].includes(parsed.protocol) ||
            !["localhost", "127.0.0.1"].includes(parsed.hostname) ||
            parsed.username ||
            parsed.password
        ) {
            throw new Error(
                "Playwright navigation is limited to credential-free localhost or 127.0.0.1 URLs.",
            );
        }
    },
});
