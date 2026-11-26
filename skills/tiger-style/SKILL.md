---
name: tiger-style
description: Write and review code in TigerBeetle's TigerStyle, a safety-first style for any language. It asserts arguments, return values and invariants (at least two per function), puts a fixed limit on every loop and queue, bans recursion, keeps functions to 70 lines and lines to 100 columns, puts units last in names (latency_ms_max), handles every error, and says why in comments. Use whenever the user mentions TigerStyle, Tiger Style, TigerBeetle style, NASA's Power of Ten rules, assertion density, or safety-critical, defensive or zero-technical-debt coding, asks for code the TigerBeetle way, or asks to review, refactor or audit code against those rules. Also use in any repo whose CLAUDE.md, AGENTS.md or contributing guide names TigerStyle.
---

# TigerStyle

TigerStyle is the coding style of [TigerBeetle](https://github.com/tigerbeetle/tigerbeetle). It has three design goals, ranked: **safety, then performance, then developer experience**. Every rule below serves one of them. When two rules pull against each other, the higher goal wins.

The original guide is written for Zig. This skill applies its principles to any language. Rules that only make sense in Zig are listed at the end. The full original is in [references/TIGER_STYLE.md](references/TIGER_STYLE.md). Read it when you need the reasoning behind a rule, or exact wording to quote.

## Two modes

- **Writing code:** follow the rules as you write. Don't produce a draft and fix it later, because TigerStyle's point is "do it right the first time". Before you write, sketch the design, the limits, and the rough cost of each resource (see Performance).
- **Reviewing code:** check the code against the rules and report findings in the format under "Reviewing". Don't rewrite the code unless the user asks.

In both modes, follow the language's own conventions where a rule here would fight them (for example `camelCase` in JavaScript), and say so in one line. The goals matter more than the surface rules.

## Safety

**Control flow and limits**
- Use only simple, explicit control flow. Don't use recursion, so that every run that should be bounded is bounded.
- Put a limit on everything. Every loop and every queue has a fixed upper bound, and the code fails fast when it hits it. A loop that is meant never to end (an event loop) says so with an assertion or a comment.
- Use as few abstractions as you can, and only ones that fit the domain well. No abstraction is free, and each one can leak.
- Split compound conditions into nested `if`/`else`. Write `else { if … }` in place of long `else if` chains, so that every case is visible. Ask whether each `if` needs an `else` to cover the negative space.
- State conditions positively: prefer `if (index < count)` to `if (index >= count)`.
- Don't act directly in reaction to external events. Queue the work and process it at your own pace, in batches. This keeps control flow in your hands and puts a bound on the work done per tick.

**Assertions**

Assertions catch programmer errors. Operating errors (a missing file, a timeout, bad user input) are expected and must be handled. A failed assertion means the code is wrong, and the only correct response is to crash. Use the language's assert (`assert`, `debug_assert!`, `assert()`), or a small `invariant()` helper where none exists.
- Assert arguments, return values, preconditions, postconditions and invariants. Aim for **at least two assertions per function** on average.
- **Pair assertions:** check the same property on two different code paths, for example before writing data and again after reading it back.
- Assert the **positive space** (what you expect) and the **negative space** (what must never happen). Bugs are often found where data crosses from valid to invalid.
- Split compound assertions: `assert(a); assert(b);`, not `assert(a && b)`. A failure then tells you which one broke.
- Assert an implication with a one-line `if`: `if (a) assert(b);`.
- Assert relationships between constants at compile time or at startup (`static_assert`, `const _ = assert!(…)`, or a check at module load).
- An assertion that is obviously true can replace a comment where the fact is critical and surprising.
- Assertions don't replace understanding. Build the mental model first, write it down as assertions, then write the code.

**Memory, scope and errors**
- Allocate memory up front, at startup, where the language allows it. Don't allocate or free on hot paths after startup. In garbage-collected languages, the goal becomes: size pools and buffers ahead of time, and give every collection a maximum size.
- Declare each variable in the smallest possible scope, and keep few variables in scope at once.
- **Functions are 70 lines at most.** Keep branching in the parent function, and move straight-line work into helpers ("push `if`s up and `for`s down"). The parent owns the state, and helpers compute what to change. Keep leaf functions pure.
- Turn on the strictest compiler, type checker and linter settings, and treat warnings as errors.
- **Handle every error.** Most catastrophic failures in distributed systems come from mishandled non-fatal errors. Don't swallow errors, don't write `catch {}` or `except: pass`, and don't add an `unwrap()` without an assertion-grade reason.
- Pass options to library calls explicitly, instead of relying on defaults that could change (`timeout=`, `encoding=`, `flags`).
- Always say why. Comments explain the reason for a decision, not what the code does.

## Performance

- Design for performance from the start. The 1000x wins come at design time, when nothing can be measured yet.
- Before you build, sketch the cost on the back of an envelope: **network, disk, memory, CPU**, each by **bandwidth and latency**. Optimize the slowest resource first, adjusted for how often it is used.
- Keep the control plane (rare, heavily checked) separate from the data plane (hot, batched). Batching is what pays for the assertions.
- Batch network, disk, memory and CPU access. Give the CPU large, predictable chunks of work.
- Be explicit, and don't count on the compiler to optimize for you. Move hot loops into standalone functions that take primitive arguments, not `self`/`this`.

## Developer experience

**Naming**
- Get the nouns and verbs exactly right. Take time over names.
- Don't abbreviate, except for loop counters in tight math or sort code. Use long flags in scripts (`--force`, not `-f`).
- Capitalize acronyms as acronyms (`VSRState`, `HTTPClient`), unless the language's convention says otherwise.
- **Put units and qualifiers last**, from most to least significant: `latency_ms_max`, not `max_latency_ms`. Related names then sort and line up together (`latency_ms_min`).
- Give related names the same length where you can: `source`/`target`, not `src`/`dest`, so that `source_offset` and `target_offset` line up.
- Prefix a helper or callback with its caller's name: `read_sector()` and `read_sector_callback()`. Callbacks go last in the parameter list.
- Prefer nouns to adjectives (`pipeline`, not `preparing`), and don't give one name two meanings.
- Use named arguments or an options object when two arguments could be swapped (for example two integers).
- Put the most important code first in a file: `main` at the top. In a type, put fields first, then nested types, then methods.

**Comments and commits**
- Comments are full sentences: a capital letter, a full stop, and a space after `//`. A comment at the end of a line can be a phrase.
- Explain why, and for tests, explain how: start a test with what it checks and how it checks it.
- Write commit messages that explain the change. A pull request description isn't in `git blame`.

**State and off-by-one errors**
- Don't copy or alias state that could drift out of sync.
- Compute or check a value right before you use it, to close the gap between where it is checked and where it is used.
- Keep return types simple: `void` beats `bool`, which beats an integer, which beats an optional, which beats an error union or a `Result`.
- Treat `index`, `count` and `size` as different types. An index plus one is a count, and a count times the unit size is a size. Name them that way.
- Show how division rounds: use exact, floor or ceiling division on purpose, and assert where it matters.
- Watch for buffer bleeds: zero any padding and unused bytes before data leaves the process.
- Group allocation and its cleanup (`defer`, `finally`, `with`, RAII) together, with blank lines around the group.

**By the numbers**
- Run the language's formatter.
- **Lines are 100 columns at most.**
- Indent with 4 spaces where the language allows it.
- Use braces on an `if` unless it fits on one line.
- Keep dependencies to a minimum, close to zero. Each one is a risk to the supply chain, safety and performance.
- Keep the toolbox small: write scripts in the project's main language rather than shell, where that is practical.

## Reviewing

Report findings grouped by goal, most serious first:

```
## Safety
- path/file.ext:42 — `retry()` recurses with no depth limit. Rule: no recursion; bound every loop.
  Fix: loop with `attempts_max = 5` and assert `attempts <= attempts_max`.

## Performance
- …

## Developer experience
- …

## Summary
N findings (S safety, P performance, D developer experience). Assertions: X across Y functions (target is 2 per function).
```

- Give each finding: where it is, what is wrong, which rule it breaks, and a concrete fix.
- Count the assertions per function, and name the longest functions with their line counts. These are TigerStyle's own measurable checks.
- Don't pad the review with nits when there are safety findings. Say what is already good in one line.

## Zig-only rules

When the code is Zig, also apply these from the original guide:
- Use explicitly sized integer types (`u32`, `u64`), not `usize`, except when indexing.
- Pass arguments larger than 16 bytes as `*const` when you don't mean to copy them.
- Initialize large structs in place through an out pointer (`fn init(target: *T) !void`). In-place initialization spreads: a container of an in-place struct is initialized in place too.
- Use `@divExact`, `@divFloor` or `div_ceil` to show how division rounds.
- Use `snake_case` for file names too, including struct files.
- Thread singletons such as allocators positionally, from most general to most specific. Name allocators by kind: `gpa` or `arena`.
- Run `zig fmt`, and add a trailing comma to make it wrap.
- Functions run to completion without suspending, so that preconditions stay true.
