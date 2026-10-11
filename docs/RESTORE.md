# Review and apply a restore

`omarchy-cloud-sync restore` prints configured destination mappings without
downloading or writing data. Review them before using `restore --apply`.

Apply downloads to a fresh private staging folder, checks the configured paths,
preserves overwritten files and permissions in a recovery journal, and rolls
back applied files if an operation fails. Custom folders retain their configured
paths. Missing downloads, failed commands, symlink traversal and outside-home
paths are reported as failures. Root files and symlinks require a separate manual
restore. Files are copied without deleting unrelated destination files.

Credential filename exclusions are mandatory even when a custom configuration
omits them. Existing credentials are never intentionally included in recovery
copies. The checks cannot detect every possible secret hidden in arbitrary data.
Fresh installations must explicitly enable selected backup folders.
