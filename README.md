# polygotfs
FUSE file system that supports many back-end services.

## Running
Start FUSE filesystem:
```
zig build run
```

In another terminal, run commands:
```
ls /mnt/polygot
ls /mnt/polygot/generated
cat /mnt/polygot/generated/uuid
cat /mnt/polygot/generated/timestamp
```

To unmount:
```
fusermount -u /mnt/polygot
```

## Backends

### generated (working)
Virtual files that are auto-generated on each read. No configuration required.

| File | Description |
|------|-------------|
| `uuid` | UUID-shaped random hex string (fresh each read) |
| `timestamp` | Current ISO 8601 timestamp (fresh each read) |

Example:
```
$ cat /mnt/polygot/generated/uuid
ccd8f33b-ad81-d24d-f43d-3f9366cc92c9

$ cat /mnt/polygot/generated/timestamp
2025-03-11T08:02:00Z
```

### local (planned)
Mirror a local directory as read-only. Configured via TOML config file.

### b2 (planned)
Backblaze B2 bucket as read-only. Configured via TOML config file.

## Configuration
Configuration is provided via a TOML file passed as a positional argument:
```
zig build run -- polygot.toml
```

Example config:
```toml
[local]
mount = "/home/dan/Documents"

[b2]
apiKey = "<api key>"
apiSecret = "<api secret>"
bucket = "<bucket>"
```

Only backends with a config section are active.

## References
- https://richiejp.com/zig-fuse-one
  - Manually create FUSE Zig file with
  - `zig translate-c -DFUSE_USE_VERSION=31 -isystem /usr/include/fuse3 -isystem /usr/include/ /usr/include/fuse3/fuse.h > fuse31.zig`
  - Not included in this repo, using Zig build bindings instead
