export const SessionExporter = async ({ client, $, directory }) => {
  return {
    "session.idle": async (event) => {
      const session = event.session;
      if (!session) {
        return;
      }

      try {
        const sessionId = session.id || session;
        const branchResult = await $`git branch --show-current 2>&1`;
        const branch = (branchResult.stdout || "unknown").trim();

        const timestamp = new Date().toISOString().split("T")[0];
        const safeBranch = branch.replace(/[^a-zA-Z0-9]/g, "-");
        const filename = `sessions/${timestamp}-${safeBranch}.md`;

        const sessionData = await client.session.get({ path: { id: sessionId } });
        const messages = await client.session.messages({ path: { id: sessionId } });

        let summary = `# Session Summary\n\n`;
        summary += `**Date**: ${timestamp}\n`;
        summary += `**Branch**: ${branch}\n`;
        summary += `**Model**: ${sessionData?.data?.model || "unknown"}\n\n`;

        if (messages?.data) {
          const userMessages = messages.data.filter(m => m.info?.role === "user");
          const assistantMessages = messages.data.filter(m => m.info?.role === "assistant");

          summary += `## Activity\n\n`;
          summary += `- User messages: ${userMessages.length}\n`;
          summary += `- Assistant responses: ${assistantMessages.length}\n\n`;

          if (userMessages.length > 0) {
            summary += `## Last User Request\n\n`;
            const lastUserMsg = userMessages[userMessages.length - 1];
            const text = lastUserMsg.parts?.[0]?.text || "No content";
            summary += `${text.slice(0, 500)}${text.length > 500 ? "..." : ""}\n\n`;
          }
        }

        summary += `---\n*Exported from OpenCode session*\n`;

        await $`mkdir -p ${directory}/sessions`;
        await $`echo ${summary} > ${directory}/${filename}`;

        console.log(`\n=== Session exported to ${filename} ===`);
      } catch (error) {
        console.error("Failed to export session:", error.message);
      }
    },
  };
};