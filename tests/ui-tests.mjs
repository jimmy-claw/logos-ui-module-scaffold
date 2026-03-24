#!/usr/bin/env node
// Example UI integration tests for a logos-app module
// Usage: node tests/ui-tests.mjs              # run all (app must be running)
//       node tests/ui-tests.mjs --ci ./result/bin/logos-basecamp  # CI mode

import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dirname, "..");

// LOGOS_QT_MCP can be overridden; default looks for basecamp's built mcp
const qtMcpRoot = process.env.LOGOS_QT_MCP || resolve(projectRoot, "result-mcp");

// If framework not built yet, skip tests gracefully
let framework;
try {
  const path = resolve(qtMcpRoot, "test-framework/framework.mjs");
  framework = await import("file://" + path);
} catch {
  console.log("logos-qt-mcp not found. Run: cd ~/logos-basecamp && nix build .#x86_64-linux.logosQtMcp -o result-mcp");
  process.exit(0);
}

const { test, run } = framework;

// ─── YOUR TESTS HERE ────────────────────────────────────────────────────────────

test("your_module: open and verify UI loads", async (app) => {
  await app.click("your_module");
  await app.expectTexts(["expected content"]);
});

// ─── END TESTS ────────────────────────────────────────────────────────────────

// Run all tests (app must already be running, or use --ci flag)
run();
