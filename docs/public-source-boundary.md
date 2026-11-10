[← GlassPort showcase](../README.md)

# Public source boundary

GlassPort is an independent product with a private implementation. This showcase publishes approved product screenshots, architectural explanations and **separately authored demonstration code**, but not GlassPort application source.

## Not published

- AppKit, SwiftTerm, SSH, PTY or application implementation source and direct excerpts
- Private XCTest fixtures, production integration tests, build/export scripts, Xcode project or provisioning materials
- Real SSH hosts, private aliases, configuration files, passwords, keys or session history
- Private issue and task identifiers, logs, internal release plans, user data or implementation diffs
- Proprietary product assets beyond the specifically accepted screenshots

## Allowed public example

The `samples/CompanionLayoutCore/` and `samples/WorkspaceRestoreCore/` packages are separately authored demonstrations. The latter uses deliberately different JSON fields and layout roles from the private storage schema. Neither reproduces private data models, AppKit rendering, SSH lifecycle or production tests. Passing their tests proves only the standalone examples.

The companion-split behavior is already publicly described in the [architecture note](native-workspace-architecture.md) and visible in accepted screenshots. Publishing an illustration of that general idea is not permission to disclose the private implementation.

The safety workflow only permits explicitly named sample source files. It can detect certain files and strings but **cannot determine code provenance**; every future proposed public sample needs human source/diff review.

## Licensing

A public GitHub repository is not a grant to use or redistribute the private GlassPort application. No open-source license for the product is implied by the example.

[Return to showcase](../README.md)
