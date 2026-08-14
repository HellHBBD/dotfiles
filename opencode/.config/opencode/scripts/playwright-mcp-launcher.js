const { lstat, mkdir } = require("node:fs/promises");
const { join } = require("node:path");
const { spawn } = require("node:child_process");

const runtimeRoot =
    "/home/hellhbbd/.local/share/opencode-extension-manager/runtime/vendor-microsoft-playwright-mcp/0.0.79";
const runtimeDir = process.env.XDG_RUNTIME_DIR;

async function main() {
    if (!runtimeDir) {
        throw new Error(
            "XDG_RUNTIME_DIR is required for Playwright MCP artifacts.",
        );
    }

    const outputDir = join(runtimeDir, "opencode-playwright");
    await mkdir(outputDir, { recursive: true, mode: 0o700 });
    const metadata = await lstat(outputDir);
    if (
        !metadata.isDirectory() ||
        metadata.isSymbolicLink() ||
        metadata.uid !== process.getuid() ||
        (metadata.mode & 0o077) !== 0
    ) {
        throw new Error(
            "The Playwright MCP artifact directory is not private and safe.",
        );
    }

    const child = spawn(
        process.execPath,
        [
            join(runtimeRoot, "node_modules", "@playwright", "mcp", "cli.js"),
            "--headless",
            "--isolated",
            "--browser",
            "chromium",
            "--executable-path",
            join(
                runtimeRoot,
                "browsers",
                "chromium",
                "chrome-linux64",
                "chrome",
            ),
            "--block-service-workers",
            "--codegen",
            "none",
            "--output-dir",
            outputDir,
            "--output-max-size",
            "52428800",
            "--allowed-origins",
            "http://localhost:*;https://localhost:*;http://127.0.0.1:*;https://127.0.0.1:*;https://fonts.googleapis.com;https://fonts.gstatic.com;https://cdn.jsdelivr.net",
        ],
        { stdio: "inherit" },
    );

    child.once("exit", (code, signal) => {
        process.exitCode = code ?? (signal ? 1 : 0);
    });
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
