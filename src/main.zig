const std = @import("std");
const polygotfs = @import("polygotfs");

pub fn main() !void {
    var operations = std.mem.zeroes(polygotfs.c.struct_fuse_operations);

    operations.rename = polygotfs.fuse_ops.rename;
    operations.symlink = polygotfs.fuse_ops.symlink;
    operations.getattr = polygotfs.fuse_ops.fuseGetattr;
    operations.statx = polygotfs.fuse_ops.fuseStat;
    operations.read = polygotfs.fuse_ops.fuseRead;

//     operations.readdir = polygotfs.fuse_ops.fuseReaddir;
//     operations.open = polygotfs.fuse_ops.fuseOpen;
//     operations.read = polygotfs.fuse_ops.fuseRead;
//     operations.release = fuse_ops.fuseRelease;

    // Start FUSE
    var args = [_][*c]const u8{
        "myfs",
        "/mnt/polygot",  // Mount point
        "-f",          // Foreground
        "-s",          // Single-threaded
    };

    // pub inline fn fuse_main(argc: anytype, argv: anytype, op: anytype, user_data: anytype) @TypeOf(fuse_main_fn(argc, argv, op, user_data))

    // pub fn fuse_main_real(arg_argc: c_int, arg_argv: [*c][*c]u8, arg_op: [*c]const struct_fuse_operations, arg_op_size: usize, arg_user_data: ?*anyopaque) callconv(.c) c_int

    const ret = polygotfs.c.fuse_main_real(
        args.len,
        @ptrCast(&args),
        &operations,
        @sizeOf(polygotfs.c.struct_fuse_operations),
        null,
    );

    std.process.exit(@intCast(ret));
}


