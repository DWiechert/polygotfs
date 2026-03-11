const std = @import("std");
const polygotfs = @import("polygotfs");

pub fn main() !void {
    var operations = std.mem.zeroes(polygotfs.c.struct_fuse_operations);

    operations.getattr = polygotfs.fuse_ops.fuseGetattr;
    operations.read = polygotfs.fuse_ops.fuseRead;
    operations.readdir = polygotfs.fuse_ops.fuseReaddir;

    // Start FUSE
    var args = [_][*c]const u8{
        "polygotfs",
        "/mnt/polygot",  // Mount point
        "-f",          // Foreground
        "-s",          // Single-threaded
    };

    const ret = polygotfs.c.fuse_main_real(
        args.len,
        @ptrCast(&args),
        &operations,
        @sizeOf(polygotfs.c.struct_fuse_operations),
        null,
    );

    std.process.exit(@intCast(ret));
}


