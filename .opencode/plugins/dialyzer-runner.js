export const DialyzerRunner = async ({ $, directory }) => {
  const typeSpecPattern = /@spec\s|@type\s|@callback\s|@macrocallback\s|@opaque\s|@typep\s/;

  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool !== "edit" && input.tool !== "write") {
        return;
      }

      const filePath = output.args?.filePath;
      if (!filePath || !filePath.endsWith(".ex") && !filePath.endsWith(".exs")) {
        return;
      }

      const newString = output.args?.newString || "";
      const oldString = output.args?.oldString || "";

      const hasTypeSpecChange =
        typeSpecPattern.test(newString) ||
        typeSpecPattern.test(oldString);

      if (!hasTypeSpecChange) {
        return;
      }

      console.log("\n=== Type definitions changed, running Dialyzer... ===");
      const result = await $`cd ${directory} && mix dialyzer 2>&1`;

      if (result.stdout) {
        console.log(result.stdout);
      }

      if (result.stderr) {
        console.error(result.stderr);
      }
    },
  };
};