const std = @import("std");
const Stat = @import("../router.zig").Stat;
const c = @import("../fuse_ops.zig").c;
const TimeLibrary = @import("datetime");
const Datetime = TimeLibrary.datetime.Datetime;

const UUID_SIZE: u32 = 36;
const TIMESTAMP_SIZE = 25;

pub fn getattr(path: []const u8) Stat {
    if (std.mem.eql(u8, "uuid", path)) {
        return .{
            // Regular file that has permission model 444 (r--r--r--)
            .mode = c.S_IFREG | 0o444,
            .nlink = 0,
            .size = UUID_SIZE,
            .uid = 0,
            .gid = 0,
        };
    }

    if (std.mem.eql(u8, "timestamp", path)) {
        return .{
            // Regular file that has permission model 444 (r--r--r--)
            .mode = c.S_IFREG | 0o444,
            .nlink = 0,
            .size = TIMESTAMP_SIZE,
            .uid = 0,
            .gid = 0,
        };
    }

    return .{
        .mode = 0,
        .nlink = 0,
        .size = 16,
        .uid = 0,
        .gid = 0,
    };
}

/// Convert hash bytes to hex string
fn hashToHex(hash: [16]u8, output: *[36]u8) void {
    _ = std.fmt.bufPrint(output, "{x:0>2}{x:0>2}{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}", .{
        hash[0], hash[1], hash[2],  hash[3],  hash[4],  hash[5],  hash[6],  hash[7],
        hash[8], hash[9], hash[10], hash[11], hash[12], hash[13], hash[14], hash[15],
    }) catch unreachable;
}

pub fn read(path: []const u8, buffer: [] u8) i32 {
    if (std.mem.eql(u8, "uuid", path)) {
        var bytes: [16]u8 = undefined;
        std.crypto.random.bytes(&bytes);
        var hex: [36]u8 = undefined;
        hashToHex(bytes, &hex);
        @memcpy(buffer[0..UUID_SIZE], &hex);
        return UUID_SIZE;
    }

    if (std.mem.eql(u8, "timestamp", path)) {
        const now = Datetime.now();
        if (now.formatISO8601Buf(buffer, false)) |_| {
            return TIMESTAMP_SIZE;
        } else |err| {
            std.log.err("Error formatting timestamp: {}", .{err});
            return 0;
        }
    }

    return 0;
}
