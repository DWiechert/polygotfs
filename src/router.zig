const std = @import("std");

pub fn myGetFileContent(path: []const u8) []const u8 {
    std.log.info("myGetFileContent {s}", .{path});
    return "myGetFileContent";
}

pub fn myListFiles(path: []const u8) !std.ArrayList([]u8) {
    std.log.info("myListFiles {s}", .{path});
//     var list = std.ArrayList([]u8);
//     list.a
    return std.ArrayList([]u8).empty;
}
