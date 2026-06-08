const std = @import("std");
const calc = @import("calc.zig");
const context_mod = @import("context.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(allocator);
    // No need to free args or GPA, arena handles it

    var ctx = context_mod.Context.init(allocator);
    defer ctx.deinit();

    if (args.len == 2) {
        // Direct expression mode
        const expr = args[1];
        const result = calc.eval(allocator, expr, &ctx) catch |err| {
            std.debug.print("Error: {}\n", .{err});
            return;
        };
        std.debug.print("{s}\n", .{result});
        allocator.free(result);
    } else if (args.len == 1) {
        // Interactive REPL mode
        const stdin = std.Io.File.stdin();

        std.debug.print("zalc - Advanced CLI Calculator\n", .{});
        std.debug.print("Type 'quit' to exit, 'help' for commands\n\n", .{});

        var buffer: [256]u8 = undefined;

        while (true) {
            std.debug.print("> ", .{});

            const bytes_read = try stdin.readStreaming(init.io, &[_][]u8{buffer[0..]});
            if (bytes_read == 0) break;

            const line = std.mem.trim(u8, buffer[0..bytes_read], "\n\r");

            if (std.mem.eql(u8, line, "quit") or std.mem.eql(u8, line, "exit")) {
                break;
            }

            if (std.mem.eql(u8, line, "help")) {
                std.debug.print(
                    \\Available commands:
                    \\  quit/exit     - Exit calculator
                    \\  help          - Show this help
                    \\  history       - Show calculation history
                    \\  vars          - Show all variables
                    \\  clear         - Clear history and variables
                    \\
                    \\Examples:
                    \\  2 + 3 * 4
                    \\  sin(0.5)
                    \\  x = 5
                    \\  y = x * 2
                    \\  0xFF + 0b1010
                    \\  sqrt(16)
                    \\
                , .{});
                continue;
            }

            if (std.mem.eql(u8, line, "history")) {
                std.debug.print("Calculation History:\n", .{});
                for (ctx.history.items, 0..) |item, i| {
                    std.debug.print("  {d}: {s}\n", .{ i + 1, item });
                }
                continue;
            }

            if (std.mem.eql(u8, line, "vars")) {
                std.debug.print("Variables:\n", .{});
                var iter = ctx.variables.iterator();
                while (iter.next()) |entry| {
                    std.debug.print("  {s} = {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
                }
                continue;
            }

            if (std.mem.eql(u8, line, "clear")) {
                ctx.variables.clearRetainingCapacity();
                ctx.history.clearRetainingCapacity();
                std.debug.print("Cleared history and variables.\n", .{});
                continue;
            }

            const result = calc.eval(allocator, line, &ctx) catch |err| {
                std.debug.print("Error: {}\n", .{err});
                continue;
            };
            std.debug.print("= {s}\n", .{result});
            allocator.free(result);
        }
    } else {
        std.debug.print("Usage:\n{s} \"expr\"\nor\n{s} (argless for REPL)\n", .{ args[0], args[0] });
    }
}
