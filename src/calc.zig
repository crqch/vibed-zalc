const std = @import("std");
const evaluator = @import("evaluator.zig");
const context_mod = @import("context.zig");

pub fn eval(allocator: std.mem.Allocator, expr: []const u8, ctx: *context_mod.Context) ![]const u8 {
    const result = try evaluator.evaluate(allocator, expr, ctx);
    try ctx.addToHistory(expr);
    return try std.fmt.allocPrint(allocator, "{d}", .{result});
}
