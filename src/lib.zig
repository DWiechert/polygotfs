//! ZUtils Library

pub const router = @import("router.zig");
pub const fuse_ops = @import("fuse_ops.zig");
pub const generated = @import("backends/generated.zig");
pub const c = fuse_ops.c;

// This runs all tests from imported files
// when running `zig build test --summary all`
test {
    @import("std").testing.refAllDecls(@This());
}
