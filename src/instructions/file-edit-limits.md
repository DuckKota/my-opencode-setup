<!-- file-edit-size-limits:start -->
## Critical Rule: Chunked Assembly for Large File Operations

To prevent output token truncation, broken JSON payloads, and tool failure:

- **Strict Payload Ceiling:** NEVER generate or replace more than **300 lines of content** in a single `write` or `edit` tool call.
- **Mandatory Chunked Assembly:** Whenever creating or significantly expanding a file expected to exceed 300 lines, you MUST construct it in steps:
  1. **Initialize:** Use `write` to establish the basic file outline, high-level structure, exports, or boilerplate.
  2. **Populate:** Use sequential, smaller `edit` calls to populate distinct sections, blocks, or content groups step-by-step.
- Do not attempt to write massive monolithic files in a single turn. 
<!-- file-edit-size-limits:stop -->