const std = @import("std");
const generated = @import("backends/generated.zig");
const c = @import("fuse_ops.zig").c;

pub const Stat = struct {
    mode: u32,
    nlink: u64,
    size: i64,
    uid: u32,
    gid: u32,
};


pub fn getattr(path: []const u8) Stat {
    std.log.info("router.getattr {s}", .{path});


    // Strip the initial '/' so add +1 to left size calculations
    if (std.mem.indexOf(u8, path[1..], "/")) |i| {
        const backend = path[1..i+1];
        const file_path = path[i+2..];

        if (std.mem.eql(u8, "local", backend)) {
           return generated.getattr(file_path);
        }
    } else {
        // Single segment = backend root directory
        return .{
            // Directory that has permission model 755 (rwxrxrx)
            .mode = c.S_IFDIR | 0o755,
            .nlink = 2,
            .size = 0,
            .uid = 0,
            .gid = 0,
        };
    }
    std.log.warn("Unknown path: {s}", .{path});
    return .{
        .mode = 0,
        .nlink = 0,
        .size = 0,
        .uid = 0,
        .gid = 0,
    };
}

pub fn read(path: []const u8, buffer: [] u8) i32 {
    std.log.info("router.read {s}", .{path});

    // Strip the initial '/' so add +1 to left size calculations
    if (std.mem.indexOf(u8, path[1..], "/")) |i| {
        const backend = path[1..i+1];
        const file_path = path[i+2..];

        if (std.mem.eql(u8, "local", backend)) {
            return generated.read(file_path, buffer);
        }
    }

    std.log.warn("Unknown path: {s}", .{path});
    return 0;
}


