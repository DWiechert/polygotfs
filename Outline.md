# polygotfs — Project Outline

## Current State
- FUSE filesystem in Zig with libfuse 3.1 bindings
- `fuse_ops.zig` — C ABI translation (getattr, read, readdir, rename, symlink)
- `router.zig` — path parsing and backend dispatch
- `generated` backend — uuid and timestamp virtual files working

---

## Next Steps

### 1. Local Backend
- Add a `local` backend that mirrors a real directory on disk
- Read-only to start
- Full recursive directory tree support
- `getattr`, `readdir`, and `read` ops

### 2. TOML Config
- Accept a config file path as a positional CLI argument: `zig build run -- polygot.toml`
- Parse backend config sections at startup
- Only backends with a config section are active
- Example config:
  ```toml
  [local]
  mount = "/home/dan/Documents"

  [b2]
  apiKey = "<api key>"
  apiSecret = "<api secret>"
  bucket = "<bucket>"
  ```
- Find and integrate a Zig TOML parsing library

### 3. V-Table Refactor
- Replace per-backend if/else chains in router with a `HashMap([]const u8, Backend)`
- `Backend` is a vtable struct:
  ```zig
  const Backend = struct {
      ptr: *anyopaque,
      getattr: *const fn(*anyopaque, []const u8) Stat,
      readdir: *const fn(*anyopaque, []const u8, *std.ArrayList([]const u8)) void,
      read: *const fn(*anyopaque, []const u8, []u8) i32,
  };
  ```
- Active backends registered in `main` based on parsed TOML config
- Do after local backend is working alongside generated

### 4. B2 Backend
- Backblaze B2 support via API
- Config: apiKey, apiSecret, bucket
- Read-only to start
- Ops: getattr, readdir, read
