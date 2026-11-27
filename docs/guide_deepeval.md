# Beginner's Guide to DeepEval

This guide covers DeepEval from
[github.com/confident-ai/deepeval](https://github.com/confident-ai/deepeval).
DeepEval is a pytest-style framework for unit-testing LLM output: each test case
is scored by metrics from 0 to 1, and a judge model (an LLM) does the scoring.

## What this script installs

`deepeval.fish` installs the global `deepeval` CLI with `uv tool install deepeval`,
which puts it in `~/.local/bin` (added to the fish PATH if needed). uv itself is a
prerequisite: run `./python_and_uv.fish` first. The script also sets the universal
variable `DEEPEVAL_TELEMETRY_OPT_OUT=1` unless you have already set it.

The script does not touch your projects, API keys or `.env` files.

Each project still needs `uv add --dev deepeval`: your test files
`import deepeval`, and the global tool runs in its own isolated environment that
cannot import your app's code. That is why every project command below goes
through `uv run`, which uses the project's environment and DeepEval version.

## Install

From the root of this setup repository, run:

```fish
chmod +x deepeval.fish
./deepeval.fish
```

Check the global CLI:

```fish
deepeval --version
```

Open a new terminal first if the script has just set
`DEEPEVAL_TELEMETRY_OPT_OUT`: without it, DeepEval creates a `.deepeval/` folder
in the current directory.

Rerunning the script is safe: it runs `uv tool upgrade deepeval` and changes
nothing else.

## Start exploring

Run steps 2–7 from your project's root. DeepEval reads and saves its settings in
the current folder.

1. Add DeepEval to your project as a dev dependency (your tests import it, so it
   must live in the project environment):

   ```fish
   cd ~/my-llm-app
   uv init                  # only if there is no pyproject.toml yet
   uv add --dev deepeval
   ```

2. Choose the judge model DeepEval uses to score metrics. OpenAI is the default:
   just set `OPENAI_API_KEY` in step 3. Other providers include Anthropic
   (`set-anthropic`), Gemini (`set-gemini`), Ollama (`set-ollama`), Azure OpenAI
   (`set-azure-openai`) and a local model (`set-local-model`). For example:

   ```fish
   uv run deepeval set-anthropic -m <model> -i <cost-per-input-token> -o <cost-per-output-token> --save=dotenv
   ```

   Run `uv run deepeval set-<provider> --help` to list each provider's flags.
   To go back to the default, undo it with:

   ```fish
   uv run deepeval unset-<provider> --save=dotenv
   ```

3. Keep API keys in `.env.local` in the project root. DeepEval loads it from the
   current folder, and `--save=dotenv` writes there too:

   ```text
   OPENAI_API_KEY=...       # or ANTHROPIC_API_KEY=... / GOOGLE_API_KEY=...
   ```

   Keep secrets and local state out of git by adding these lines to your
   `.gitignore`:

   ```text
   .env.local
   .deepeval/
   ```

4. (Optional) Connect Confident AI for dashboards and shared test runs:

   ```fish
   uv run deepeval login
   ```

   In CI or other headless environments, pass the key directly:

   ```fish
   uv run deepeval login --api-key "$CONFIDENT_API_KEY"
   ```

5. Write a first test in `tests/test_example.py`. This is the quickstart from the
   upstream README (checked 2026-10-31):

   ```python
   import pytest
   from deepeval import assert_test
   from deepeval.metrics import GEval
   from deepeval.test_case import LLMTestCase, SingleTurnParams

   def test_case():
       correctness_metric = GEval(
           name="Correctness",
           criteria="Determine if the 'actual output' is correct based on the 'expected output'.",
           evaluation_params=[SingleTurnParams.ACTUAL_OUTPUT, SingleTurnParams.EXPECTED_OUTPUT],
           threshold=0.5
       )
       test_case = LLMTestCase(
           input="What if these shoes don't fit?",
           # Replace this with the actual output from your LLM application
           actual_output="You have 30 days to get a full refund at no extra cost.",
           expected_output="We offer a 30-day full refund at no extra costs.",
       )
       assert_test(test_case, [correctness_metric])
   ```

   Import names have changed between DeepEval releases. If an import fails,
   check the upstream README for the current names.

6. Run the test with the project's environment:

   ```fish
   uv run deepeval test run tests/test_example.py
   ```

7. Check which settings DeepEval resolved and where each value came from:

   ```fish
   uv run deepeval diagnose
   ```

DeepEval sends anonymous usage data by default. The script opts you out with
`set -Ux DEEPEVAL_TELEMETRY_OPT_OUT 1`; to opt back in, run
`set -Ux DEEPEVAL_TELEMETRY_OPT_OUT 0`.

## Common maintenance

Update the global CLI by rerunning `./deepeval.fish`, or with:

```fish
uv tool upgrade deepeval
```

In each project, upgrade the dev dependency with:

```fish
uv lock --upgrade-package deepeval
```

Remove the global CLI with:

```fish
uv tool uninstall deepeval
```

## Troubleshooting

- **`deepeval: command not found` after install:** rerun `./deepeval.fish`, which
  adds `~/.local/bin` to the fish PATH, then open a new terminal.
- **`ModuleNotFoundError` for your app when running tests:** use
  `uv run deepeval test run`, not the global `deepeval`; only the project
  environment can import your code.
- **Settings or API keys not picked up:** run commands from the project root,
  where `.env.local` lives, and check what DeepEval resolved with
  `uv run deepeval diagnose`.
- **DeepEval already installed by another owner (Mise, pipx):** the script stops
  and names the binary. Update it there, or remove it and rerun `./deepeval.fish`.
