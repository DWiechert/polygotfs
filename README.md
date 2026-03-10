# polygotfs
FUSE file system that supports many back-end services.

## Running
Start FUSE filesystem:
```
zig build run
```

In another terminal, run commands:
```
stat /mnt/polygot/a
ln /mnt/polygot/a
mv /mnt/polygot/a /mnt/polygot/b
....
```

## References
- https://richiejp.com/zig-fuse-one
  - Manually create FUSE Zig file with
  - `zig translate-c -DFUSE_USE_VERSION=31 -isystem /usr/include/fuse3 -isystem /usr/include/ /usr/include/fuse3/fuse.h > fuse31.zig`
  - Not included in this repo, using Zig build bindings instead
