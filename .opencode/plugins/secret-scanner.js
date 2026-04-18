import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

export const SecretScanner = async ({ $, directory }) => {
  const secretPatterns = [
    { pattern: /sk-[a-zA-Z0-9]{20,}/, name: "OpenAI/Anthropic API Key" },
    { pattern: /api[_-]?key["\s]*[=:]["\s]*[a-zA-Z0-9]{20,}/i, name: "Generic API Key" },
    { pattern: /secret[_-]?key["\s]*[=:]["\s]*[a-zA-Z0-9]{20,}/i, name: "Secret Key" },
    { pattern: /AKIA[0-9A-Z]{16}/, name: "AWS Access Key ID" },
    { pattern: /AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN/, name: "AWS Secret" },
    { pattern: /-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY-----/, name: "Private Key" },
    { pattern: /Bearer\s+[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+/, name: "Bearer Token" },
    { pattern: /ghp_[a-zA-Z0-9]{36}/, name: "GitHub Personal Access Token" },
    { pattern: /gho_[a-zA-Z0-9]{36}/, name: "GitHub OAuth Token" },
    { pattern: /glpat-[a-zA-Z0-9\-_]{20,}/, name: "GitLab PAT" },
    { pattern: /password["\s]*[=:]["\s]*[^\s"']{8,}/i, name: "Password in config" },
    { pattern: /token["\s]*[=:]["\s]*[a-zA-Z0-9]{20,}/i, name: "Generic Token" },
    { pattern: /xox[baprs]-[a-zA-Z0-9]{10,}/, name: "Slack Token" },
  ];

  const dangerousCommands = ["git commit", "git push"];

  function parseGitFiles(output) {
    return (output || "")
      .split("\n")
      .map((file) => file.trim())
      .filter(Boolean);
  }

  async function scanForSecrets(files) {
    const findings = [];

    for (const file of files) {
      try {
        const fileContent = await readFile(resolve(directory, file), "utf8");

        for (const { pattern, name } of secretPatterns) {
          const matches = fileContent.match(pattern);
          if (matches) {
            for (const match of matches) {
              const masked = match.slice(0, 4) + "..." + match.slice(-4);
              findings.push({ file, name, match: masked });
            }
          }
        }
      } catch {
        // Skip files that can't be read
      }
    }

    return findings;
  }

  async function getStagedFiles() {
    try {
      const result =
        await $`cd ${directory} && git diff --cached --name-only --diff-filter=ACMR 2>&1`;
      return parseGitFiles(result.stdout);
    } catch {
      return [];
    }
  }

  async function getUnpushedFiles() {
    try {
      const upstreamResult =
        await $`cd ${directory} && git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null`;
      const upstream = (upstreamResult.stdout || "").trim();

      if (upstream) {
        const result =
          await $`cd ${directory} && git diff --name-only --diff-filter=ACMR ${upstream}...HEAD 2>&1`;
        return parseGitFiles(result.stdout);
      }
    } catch {
      // Fall back to the most recent commit when no upstream exists.
    }

    try {
      const result =
        await $`cd ${directory} && git diff --name-only --diff-filter=ACMR HEAD~1..HEAD 2>&1`;
      return parseGitFiles(result.stdout);
    } catch {
      return [];
    }
  }

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") {
        return;
      }

      const command = input.args?.command || "";
      const isDangerous = dangerousCommands.some((cmd) => command.includes(cmd));

      if (!isDangerous) {
        return;
      }

      let filesToScan = [];

      if (command.includes("git commit")) {
        filesToScan = await getStagedFiles();
      } else if (command.includes("git push")) {
        filesToScan = await getUnpushedFiles();
      } else {
        return;
      }

      if (filesToScan.length === 0) {
        return;
      }

      const findings = await scanForSecrets(filesToScan);

      if (findings.length > 0) {
        const errorMsg = [
          "\n🚨 SECRET SCANNER BLOCKED THIS COMMAND",
          "\nPotential secrets detected:",
          ...findings.map((f) => `  - ${f.name} in ${f.file}: ${f.match}`),
          "\nPlease remove or redact secrets before committing or pushing.",
          "\nIf this is a false positive, adjust the plugin patterns in .opencode/plugins/secret-scanner.js.",
        ].join("\n");

        throw new Error(errorMsg);
      }
    },
  };
};
