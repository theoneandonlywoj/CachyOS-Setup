# MCP Server Usage Rules

## Overview

This document defines usage guidelines for the Model Context Protocol (MCP) servers configured in `~/.cursor/mcp.json`. Always prefer using MCP tools when they're available and applicable to the task at hand.

**General Principles:**

1. **Always prefer MCP tools** over manual workarounds when a relevant MCP server is available
2. **Proactively suggest** MCP tools to users when they could be helpful
3. **Combine multiple MCP servers** for complex workflows
4. **Request missing configuration** (tokens, URLs, credentials) when needed to use a tool
5. **Document your MCP usage** so users understand what tools you're leveraging

---

## MCP Servers

### 1. Filesystem Server

**Purpose:** File operations on the local system at `/home/woj`

**When to Use:**
- Reading file contents (read_file, mcp_filesystem_read_file)
- Writing new files or editing existing ones
- Searching for files by pattern (glob_file_search)
- Getting file metadata (size, permissions, timestamps)
- Directory operations (list_dir, create_directory, move_file)
- Searching file contents with grep/ripgrep

**Prefer filesystem tools when:**
- Working with local files in any way
- Reading configuration files
- Searching for code patterns across the project
- Managing project structure

**Capabilities:**
- Read single or multiple files simultaneously
- Search with grep (regex support)
- Find files by glob patterns
- Get detailed file/directory metadata
- Manage file tree structures

**Configuration:** No configuration needed - works on `/home/woj`

**Best Practices:**
- Use `mcp_filesystem_read_multiple_files` for batch operations
- Use glob patterns efficiently (avoid `**/*` when possible)
- Consider file sizes when reading - use offset/limit for large files

---

### 2. GitHub Server

**Purpose:** Repository operations, issue/PR management, code search

**When to Use:**
- Creating or updating files in GitHub repos
- Managing issues and pull requests
- Searching code across GitHub
- Repository management operations
- Working with GitHub actions/CI

**Prefer GitHub tools when:**
- User asks about GitHub repos
- Need to create/update files in a repo
- Managing issues or PRs
- Searching code in GitHub

**Configuration Requirements:**
- ✅ Set `GITHUB_PERSONAL_ACCESS_TOKEN` in env
- Get token at: https://github.com/settings/tokens

**Capabilities:**
- File management (create, update, read)
- Issue/PR operations
- Code search across repos
- Repository management

**Best Practices:**
- Always verify the repo owner and name before operations
- Use appropriate branch names (check with user)
- Provide meaningful commit messages

---

### 3. PostgreSQL Server

**Purpose:** Database queries, schema inspection, data analysis

**When to Use:**
- Running SQL queries
- Inspecting database schemas
- Analyzing data
- Managing database structure

**Prefer Postgres tools when:**
- User asks about database operations
- Need to query or analyze data
- Inspecting schema structure
- Working with relational data

**Configuration Requirements:**
- ⚠️ Set `POSTGRES_CONNECTION_STRING` in env
- Current default: `postgresql://localhost:5432/my_db`
- Update with actual database connection details

**Capabilities:**
- Execute SQL queries
- Schema inspection
- Transaction support
- Data retrieval and analysis

**Best Practices:**
- Always verify queries before running (especially write operations)
- Use transactions for multi-step operations
- Consider query performance for large datasets

---

### 4. Memory Server

**Purpose:** Persistent knowledge graph, entity/relationship tracking, long-term context

**When to Use:**
- Remembers information across conversations
- Tracking entities (people, projects, concepts)
- Storing relationships between entities
- Building a knowledge base

**Prefer memory tools when:**
- User shares information that should be remembered
- Working on a project over multiple sessions
- Building context about related topics
- Noting user preferences and patterns

**Configuration:** No configuration needed

**Capabilities:**
- Create and manage entities
- Store observations about entities
- Track relationships
- Search knowledge graph
- Persistent storage across sessions

**Best Practices:**
- Use clear entity names and types
- Add meaningful observations, not just facts
- Link related entities with relationships
- Update entities when new information is learned

---

### 5. Sequential Thinking Server

**Purpose:** Complex problem decomposition and step-by-step reasoning

**When to Use:**
- Breaking down complex, multi-step problems
- Planning solutions that require careful reasoning
- Problems where the approach isn't immediately clear
- Tasks requiring verification or analysis

**Prefer sequential-thinking when:**
- Problem has multiple interdependent steps
- Solution approach is uncertain
- Need to consider alternatives or trade-offs
- Task requires careful planning before execution

**Configuration:** No configuration needed

**Capabilities:**
- Step-by-step thought decomposition
- Hypotheses generation and verification
- Alternative approach exploration
- Problem analysis

**Best Practices:**
- Use for genuinely complex problems (not simple tasks)
- Generate hypotheses and verify them
- Consider multiple approaches
- Express uncertainty when appropriate

---

### 6. Sentry Server

**Purpose:** Error tracking, performance monitoring, issue management

**When to Use:**
- Debugging production errors
- Analyzing performance issues
- Reviewing error patterns
- Managing incidents

**Prefer Sentry tools when:**
- User reports production errors
- Need to investigate application issues
- Analyzing performance problems
- Working with error tracking data

**Configuration Requirements:**
- ⚠️ Set `SENTRY_DSN` in env
- Get DSN at: https://sentry.io/settings/{org}/auth-tokens/

**Capabilities:**
- Error tracking and analysis
- Performance monitoring
- Issue management
- Event and crash analysis

**Best Practices:**
- Use DSN to access relevant projects
- Filter by time range for large datasets
- Cross-reference with code when debugging

---

### 7. Chrome DevTools MCP Server

**Purpose:** Browser automation, testing, web scraping, performance profiling

**When to Use:**
- Testing web applications
- Scraping or interacting with websites
- Browser automation tasks
- Performance profiling of web pages
- Taking screenshots of web pages

**Prefer chrome-devtools when:**
- Need to interact with web browsers
- Testing websites or web apps
- Scraping web content
- Debugging frontend issues in browser

**Configuration:** No configuration needed

**Capabilities:**
- Navigate to URLs and interact with pages
- Click elements, fill forms
- Take screenshots
- Capture network requests
- Measure performance metrics
- Evaluate JavaScript in pages

**Best Practices:**
- Take snapshots before interacting with pages
- Use proper element selection (uids)
- Wait for content to load when needed
- Handle dialogs appropriately

---

### 8. Grafana Server

**Purpose:** Dashboard management, metrics visualization, alert configuration

**When to Use:**
- Creating or managing dashboards
- Visualizing metrics
- Configuring alerts
- Querying observability data
- Managing monitoring setup

**Prefer Grafana when:**
- User asks about dashboards or metrics
- Need to visualize data
- Working on observability setup
- Configuring monitoring alerts

**Configuration Requirements:**
- ⚠️ Set `GRAFANA_URL` in env (default: `http://localhost:3000`)
- ⚠️ Set `GRAFANA_SERVICE_ACCOUNT_TOKEN` in env
- Get token: https://grafana.com/docs/grafana-cloud/administration/service-accounts/

**Capabilities:**
- Dashboard CRUD operations
- Metrics and logs querying (Prometheus, Loki)
- Alert rule management
- Data source management
- Organization and team management

**Best Practices:**
- Update URL to match actual Grafana instance
- Use service account tokens (not user tokens)
- Organize dashboards in folders
- Configure appropriate refresh intervals

---

### 9. Prometheus Server

**Purpose:** Metrics querying, time-series analysis, performance monitoring

**When to Use:**
- Querying Prometheus metrics
- Analyzing time-series data
- Performance monitoring
- Creating metric queries

**Prefer Prometheus when:**
- User asks about metrics or performance
- Need to analyze time-series data
- Working with observability/monitoring
- Creating metric dashboards

**Configuration Requirements:**
- ⚠️ Set `PROMETHEUS_URL` in env (default: `http://localhost:9090`)
- Update to point to actual Prometheus instance

**Capabilities:**
- PromQL query execution
- Time-series data retrieval
- Metric metadata exploration
- Range and instant queries
- Series and label operations

**Best Practices:**
- Understand PromQL before writing queries
- Use appropriate time ranges
- Consider query performance
- Leverage labels for filtering

---

## Integration Guidelines

### Combining Multiple MCP Servers

When working on complex tasks, consider using multiple MCP servers together:

**Example Workflows:**

1. **Debugging a Production Issue:**
   - Use Sentry to identify the error
   - Use filesystem to check relevant code
   - Use Sequential Thinking to analyze the problem
   - Update files and create GitHub PR with solution

2. **Performance Investigation:**
   - Use Prometheus to query metrics
   - Use Grafana to visualize the data
   - Use filesystem to examine code
   - Use Sequential Thinking to plan optimizations

3. **Working with GitHub Repos:**
   - Use GitHub to clone/read repos
   - Use filesystem for local modifications
   - Use memory to track project knowledge
   - Use Sequential Thinking for complex changes

4. **Full-Stack Development:**
   - Use filesystem for local code
   - Use GitHub for version control
   - Use chrome-devtools to test frontend
   - Use postgres to test database changes
   - Use Sequential Thinking for architecture decisions

### Prioritization

When multiple tools could solve a problem:

1. **Use the most specific tool** for the task
2. **Prefer MCP tools** over manual alternatives
3. **Combine tools** when tasks span multiple domains
4. **Ask for configuration** when credentials are missing

### Performance Considerations

- **Filesystem**: Fast for local operations
- **GitHub**: Network-dependent, batch operations
- **Database tools**: Consider query complexity
- **Browser tools**: Slower due to rendering, use judiciously

---

## AI Behavioral Directives

### General Guidelines

1. **Always Prefer MCP Tools**: When a task can be done with an MCP tool, use it instead of suggesting manual methods

2. **Proactively Suggest**: If a task could benefit from an MCP tool but the user hasn't mentioned it, suggest using it

3. **Request Configuration**: When a tool needs configuration (token, URL, etc.), inform the user what's needed and where to get it

4. **Combine Tools**: Don't hesitate to use multiple MCP tools for complex workflows

5. **Default to MCP**: When there's a choice between a manual method and an MCP tool, choose the MCP tool

6. **Explain Tool Usage**: Let users know which MCP tools you're using and why

### Configuration Status

Based on the current `mcp.json` configuration:

**✅ Fully Configured (No additional setup needed):**
- filesystem
- memory
- sequential-thinking
- chrome-devtools

**⚠️ Needs Configuration:**
- **github**: Requires `GITHUB_PERSONAL_ACCESS_TOKEN`
- **postgres**: Requires valid `POSTGRES_CONNECTION_STRING` 
- **grafana**: Requires `GRAFANA_URL` and `GRAFANA_SERVICE_ACCOUNT_TOKEN`
- **prometheus**: Requires valid `PROMETHEUS_URL`
- **sentry**: Requires `SENTRY_DSN`

### How to Obtain Missing Credentials

- **GitHub Token**: https://github.com/settings/tokens
- **Grafana Token**: https://grafana.com/docs/grafana-cloud/administration/service-accounts/
- **Sentry DSN**: https://sentry.io/settings/{org}/auth-tokens/
- **Postgres**: Update connection string with actual database details
- **Prometheus**: Update URL to point to actual Prometheus instance (likely http://localhost:9090 or your server address)

---

## Usage Patterns

### Pattern 1: Direct Tool Preference

When a user asks for something an MCP tool can do, use it directly without asking:

❌ "Would you like me to read that file?"
✅ *[Uses mcp_filesystem_read_file directly]*

### Pattern 2: Proactive Combination

For complex tasks, automatically combine tools:

✅ "I'll use the filesystem to read your code, then sequential-thinking to analyze the issue, and finally GitHub to create a PR with the fix."

### Pattern 3: Configuration Check

When a tool needs credentials:

✅ "I'll use the Grafana server to check your dashboards. To enable this, please set your `GRAFANA_SERVICE_ACCOUNT_TOKEN` in the mcp.json configuration."

### Pattern 4: Multi-Tool Workflows

✅ "I'll use Prometheus to query the metrics, then filesystem to update the configuration, and finally restart the service using the terminal."

---

## Quick Reference

| Tool | Use For | Needs Config? |
|------|---------|---------------|
| filesystem | File operations | No |
| github | Repo management, issues, PRs | Yes (token) |
| postgres | Database queries | Yes (connection string) |
| memory | Long-term knowledge storage | No |
| sequential-thinking | Complex problem solving | No |
| sentry | Error tracking | Yes (DSN) |
| chrome-devtools | Browser automation | No |
| grafana | Dashboards, visualization | Yes (URL, token) |
| prometheus | Metrics queries | Yes (URL) |

---

*Last Updated: Based on mcp.json configuration*
*File Location: ~/.cursor/mcp_rules.md*