# Development Process

**IMPORTANT: Review this document at the start of each new branch/PR.**

After reviewing, output to the console:
> "Reviewed develop_process.md. I will follow TDD: one test, one commit, 2 files max."

## TDD Cycle (The Core Loop)

Each cycle produces ONE small commit:

1. **Write ONE failing test** - A single test for one specific behavior
2. **Run test** - Confirm it fails (red)
3. **Write minimal code** - Just enough to pass that ONE test
4. **Run test** - Confirm it passes (green)
5. **Run full suite** - `bin/rails test` to catch regressions
6. **Commit** - Usually 2 files only: test file + implementation file

Repeat until feature is complete.

## Commit Guidelines

- **Most commits = 2 files**: test file + implementation file
- **Exception**: Interface changes may touch more files
- **Never**: Write a giant test file with many tests, then a giant implementation
- **Always**: One test at a time, one commit at a time

## Branch/PR Workflow

1. **Create branch** - `git checkout -b feature/your-feature`
2. **TDD cycles** - Multiple small commits following the cycle above
3. **Push branch** - `git push -u origin feature/your-feature`
4. **Create PR** - Include summary and test plan
5. **Wait for review** - Developer reviews and merges
6. **Next task** - After merge, discuss what's next

## PR Size Guidelines

- **Target**: 6-8 files per PR
- **Manageable**: Keep PRs mentally reviewable by a human
- **Exception**: Interface changes affecting many files (but keep clean)

## Before Starting Any New Branch

Ask yourself:
1. Do I have user approval on the plan?
2. Am I clear on what ONE small test I'll write first?
3. Will my first commit be just 2 files?

## Anti-Patterns to Avoid

- Writing all tests at once, then all implementation
- Large commits with many unrelated changes
- Skipping the "run test to see it fail" step
- Committing without running the full test suite
