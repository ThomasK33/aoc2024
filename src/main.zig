const std = @import("std");
const cmds = @import("./cmd/all.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        return error.MissingSubcommand;
    }

    inline for (cmds.all) |value| {
        if (std.mem.eql(u8, value.name, args[1])) {
            // strip the binary name and subcommand name before passing
            // it to the subcommand.
            return value.run(allocator, args[2..]);
        }
    }

    return error.UnknownSubcommand;
}

test {
    std.testing.refAllDecls(@This());
}
