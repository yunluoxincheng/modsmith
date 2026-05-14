# OpenSpec Workflow

## 1. Purpose

This document defines how ModSmith AI uses OpenSpec for controlled changes.

The goal is to prevent uncontrolled scope growth and undocumented generator behavior.

## 2. When OpenSpec Is Required

Create an OpenSpec change when a change affects:

- ModSpec structure.
- Generated project files.
- Generator behavior.
- Public API behavior.
- Job states.
- AI agent behavior.
- Sandbox behavior.
- Version or loader support.
- Security rules.
- Database schema.
- User-visible product behavior.

## 3. When OpenSpec May Be Skipped

OpenSpec may be skipped for:

- Typo fixes.
- Formatting fixes.
- Comments.
- Local refactors that do not change behavior.
- Test cleanup that does not alter expected behavior.
- Documentation wording changes that do not change policy.

When unsure, create a small OpenSpec change.

## 4. Change Directory Structure

Use one folder per proposed change:

```text
openspec/changes/<change-id>/
  proposal.md
  design.md
  tasks.md
  specs/
    <domain>/
      spec.md
```

Example:

```text
openspec/changes/add-basic-item-generation/
  proposal.md
  design.md
  tasks.md
  specs/
    mod-generation/
      spec.md
```

## 5. Change ID Rules

Use short kebab-case IDs:

```text
add-basic-item-generation
add-modspec-validation
add-sandbox-build-runner
refine-repair-loop
```

Avoid vague names such as:

```text
update-docs
big-refactor
fix-stuff
```

## 6. Proposal Requirements

`proposal.md` should explain:

- Problem.
- Proposed change.
- Scope.
- Non-goals.
- User impact.
- Risks.

## 7. Design Requirements

`design.md` should explain:

- Architecture changes.
- Data model changes.
- API changes.
- Validation rules.
- Generator behavior.
- Security implications.
- Alternatives considered.

Small changes may keep design short, but the relevant decisions must be explicit.

## 8. Task Requirements

`tasks.md` should contain an actionable checklist:

```text
- [ ] Add ModSpec field.
- [ ] Update validator.
- [ ] Update Forge generator.
- [ ] Add tests.
- [ ] Update docs.
- [ ] Verify sample build.
```

Tasks should be specific enough for an implementation agent to follow without expanding scope.

## 9. Delta Spec Requirements

Delta specs should use requirement-style language.

Example:

```markdown
### Requirement: Generate basic item resources

The system SHALL generate required item resources for each valid basic item in the ModSpec.

#### Scenario: Valid basic item

- GIVEN a valid ModSpec containing a basic item
- WHEN the Forge 1.20.1 generator runs
- THEN it SHALL generate item registration code
- AND it SHALL generate an item model JSON
- AND it SHALL generate language entries
```

## 10. Implementation Flow

Recommended flow:

```text
1. Create OpenSpec change.
2. Review proposal and design.
3. Implement tasks one by one.
4. Add tests.
5. Run build.
6. Update docs.
7. Merge change.
8. Archive or apply change to current specs.
```

## 11. Agent Prompt Pattern

When asking an AI coding agent to work on a feature, use this pattern:

```text
Read AGENTS.md and docs/ first.
Then inspect openspec/specs/.
Create an OpenSpec change named <change-id>.
Do not implement code yet.
First write proposal.md, design.md, tasks.md, and delta spec.
Keep the change focused on <specific feature>.
```

For implementation:

```text
Read AGENTS.md, docs/, and openspec/changes/<change-id>/.
Implement only the tasks listed in tasks.md.
Do not expand scope.
Add or update tests.
Run relevant build checks.
```

## 12. Completion Rule

A change is not complete until:

- Implementation matches the spec.
- Tests are added or updated.
- Documentation is updated.
- Generated sample project builds if the change affects generation.

## 13. Workflow Rule

OpenSpec should control meaningful behavior changes without blocking small improvements. Keep changes focused, explicit, and traceable.
