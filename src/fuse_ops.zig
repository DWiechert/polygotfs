const std = @import("std");
const router = @import("router.zig");
const Stat = @import("router.zig").Stat;

pub const c = @cImport({
    @cDefine("FUSE_USE_VERSION", "31");
    @cInclude("fuse3/fuse.h");
});


pub fn fuseGetattr(path: [*c]const u8, stbuf: [*c]c.struct_stat, _: ?*c.struct_fuse_file_info) callconv(.c) c_int {
    std.log.info("fuseGetattr: {s}", .{path});
    const zig_path = std.mem.span(path);

    const stat: Stat = router.getattr(zig_path);
    stbuf.*.st_mode = @as(c_uint, stat.mode);
    stbuf.*.st_nlink = @as(c_ulong, stat.nlink);
    stbuf.*.st_size = @as(c_long, stat.size);
    stbuf.*.st_uid = @as(c_uint, stat.uid);
    stbuf.*.st_gid = @as(c_uint, stat.gid);

    return 0;
}

pub fn fuseRead(path: [*c]const u8, buffer: [*c]u8, size: usize, _: c.off_t, _: ?*c.struct_fuse_file_info) callconv(.c) c_int {
    std.log.info("fuseRead: {s}\t{s}\t{d}", .{path, buffer, size});
    const zig_path = std.mem.span(path);
    const zig_buffer = buffer[0..size];
    const read_size = router.read(zig_path, zig_buffer);
    return @as(c_int, read_size);
}

// [*c]const u8, ?*anyopaque, fuse_fill_dir_t, off_t, ?*struct_fuse_file_info, enum_fuse_readdir_flags
pub fn fuseReaddir(path: [*c]const u8, buf: ?*anyopaque, filler: c.fuse_fill_dir_t, _: c.off_t, _: ?*c.struct_fuse_file_info, _: c.enum_fuse_readdir_flags) callconv(.c) c_int {
    const zig_path = std.mem.span(path);

    // Add . and ..
    _ = filler.?(buf, ".", null, 0, c.FUSE_FILL_DIR_DEFAULTS);
    _ = filler.?(buf, "..", null, 0, c.FUSE_FILL_DIR_DEFAULTS);

    // List files in this directory
    const allocator = std.heap.page_allocator;
    var paths: std.ArrayList([]const u8) = .empty;
    defer paths.deinit(allocator);
    router.readdir(zig_path, &paths);

    for (paths.items) |filename| {
        _ = filler.?(buf, filename.ptr, null, 0, c.FUSE_FILL_DIR_DEFAULTS);
    }

    return 0;
}


// pub fn fuseStat(path: [*c]const u8, flags: c_int, mask: c_int, _: ?*c.struct_statx, _: ?*c.struct_fuse_file_info) callconv(.c) c_int {
//     std.log.info("fuseStat: {s}\t{d}\t{d}", .{path, flags, mask});
//     // TODO: Implement
//     return 0;
// }

//
// pub fn rename(source: [*c]const u8, target: [*c]const u8, flags: c_uint) callconv(.c) c_int {
//     _ = flags;
//
//     const zig_source = std.mem.span(source);
//     const zig_target = std.mem.span(target);
//
//     std.log.info("rename from {s} to {s}", .{zig_source, zig_target});
//     // TODO: Implement
//     return 0;
// }
//
// pub fn symlink(source: [*c]const u8, target: [*c]const u8) callconv(.c) c_int {
//     const zig_source = std.mem.span(source);
//     const zig_target = std.mem.span(target);
//
//     std.log.info("symlink rename from {s} to {s}", .{zig_source, zig_target});
//     // TODO: Implement
//     return 0;
// }



// pub fn fuseRead(
//     path: [*c]const u8,
//     buf: [*c]u8,
//     size: usize,
//     offset: c.off_t,
//     file_info: *c.struct_fuse_file_info,
// ) callconv(.c) c_int {
//     _ = file_info;
//
//     const zig_path = std.mem.span(path);
//
//     // Get file content from your backend
//     const content = router.myGetFileContent(zig_path);
// //     catch {
// //         return -c.ENOENT;
// //     };
//
//     // Handle offset and size
//     const start: usize = @intCast(offset);
//     if (start >= content.len) return 0;
//
//     const end = @min(start + size, content.len);
//     const bytes_to_copy = end - start;
//
//     @memcpy(buf[0..bytes_to_copy], content[start..end]);
//
//     return @intCast(bytes_to_copy);
// }
