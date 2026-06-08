const std = @import("std");
const calc = @import("calc.zig");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    if (args.len == 2) { // direct expr mode
        const expr = args[1];
        std.debug.print("{s}\n", .{calc.eval(expr)});
    } else if (args.len == 1) { // argless/cli mode
        std.debug.print("unimplemented\n", .{});
    } else {
        std.debug.print("Usage:\n{s} \"expr\"\nor\n{s} (argless)\n", .{ args[0], args[0] });
    }
}
