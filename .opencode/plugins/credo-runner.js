export const CredoRunner = async ({ $, directory }) => {
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool !== "edit" && input.tool !== "write") {
        return;
      }

      const filePath = output.args?.filePath;
      if (!filePath) {
        return;
      }

      const elixirExtensions = [".ex", ".exs", ".heex", ".eex"];
      const isElixirFile = elixirExtensions.some(ext => filePath.endsWith(ext));

      if (!isElixirFile) {
        return;
      }

      console.log("\n=== Running mix format... ===");
      await $`cd ${directory} && mix format 2>&1`;

      console.log("\n=== Running Credo... ===");
      const result = await $`cd ${directory} && mix credo 2>&1`;

      if (result.stdout) {
        console.log(result.stdout);
      }

      if (result.stderr) {
        console.error(result.stderr);
      }
    },
  };
};