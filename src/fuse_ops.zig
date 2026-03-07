const std = @import("std");
const router = @import("router.zig");

pub const c = @cImport({
    @cDefine("FUSE_USE_VERSION", "31");
    @cInclude("fuse3/fuse.h");
});

pub fn rename(source: [*c]const u8, target: [*c]const u8, flags: c_uint) callconv(.c) c_int {
    _ = flags;

    const zig_source = std.mem.span(source);
    const zig_target = std.mem.span(target);

    std.log.info("rename from {s} to {s}", .{zig_source, zig_target});
    return 0;
}

pub fn symlink(source: [*c]const u8, target: [*c]const u8) callconv(.c) c_int {
    const zig_source = std.mem.span(source);
    const zig_target = std.mem.span(target);

    std.log.info("symlink rename from {s} to {s}", .{zig_source, zig_target});
    return 0;
}

pub fn fuseGetattr(path: [*c]const u8, stbuf: [*c]c.struct_stat, _: ?*c.struct_fuse_file_info) callconv(.c) c_int {
    std.log.info("fuseGetattr: {s}", .{path});
    const zig_path = std.mem.span(path);
//      _ = file_info;

    // Clear stat buffer
    @memset(@as([*]u8, @ptrCast(stbuf))[0..@sizeOf(c.struct_stat)], 0);

    // Is it root directory?
    if (std.mem.eql(u8, zig_path, "/")) {
        stbuf.*.st_mode = c.S_IFDIR | 0o755;
        stbuf.*.st_nlink = 2;
        return 0;
    }

    // Check if file exists in your storage
    const content = router.myGetFileContent(zig_path);
//     catch {
//         return -c.ENOENT; // File not found
//     };

    // It's a file
    stbuf.*.st_mode = c.S_IFREG | 0o644;
    stbuf.*.st_nlink = 1;
    stbuf.*.st_size = @intCast(content.len);

    return 0;
}

pub fn fuseStat(path: [*c]const u8, flags: c_int, mask: c_int, _: ?*c.struct_statx, _: ?*c.struct_fuse_file_info) callconv(.c) c_int {
    std.log.info("fuseStat: {s}\t{d}\t{d}", .{path, flags, mask});
    return 0;
}


// pub fn fuseReaddir(
//     path: [*c]const u8,
//     buf: ?*anyopaque,
//     filler: c.fuse_fill_dir_t,
//     offset: c.off_t,
//     file_info: ?[*c]c.struct_fuse_file_info,
//     flags: c.enum_fuse_readdir_flags,
// ) callconv(.c) c_int {
//     _ = offset;
//     _ = file_info;
//     _ = flags;
//
//     const zig_path = std.mem.span(path);
//
//     // Add . and ..
//     _ = filler.?(buf, ".", null, 0, c.FUSE_FILL_DIR_DEFAULTS);
//     _ = filler.?(buf, "..", null, 0, c.FUSE_FILL_DIR_DEFAULTS);
//
//     // List files in this directory
//     const files = router.myListFiles(zig_path) catch {
//         return -c.ENOENT;
//     };
//
//     for (files.items) |filename| {
//         _ = filler.?(buf, filename.ptr, null, 0, c.FUSE_FILL_DIR_DEFAULTS);
//     }
//
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
