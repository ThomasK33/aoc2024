const std = @import("std");

pub const name: []const u8 = "day2";

pub fn run(
    allocator: std.mem.Allocator,
    args: [][]u8,
) !void {
    if (args.len < 1) {
        return error.MissingFileName;
    }

    // read file contents up to 16KB
    const contents = try std.fs.cwd().readFileAlloc(allocator, args[0], 32 * 1024);
    defer allocator.free(contents);

    const dampener = args.len > 1;

    var safe_reports: u32 = 0;

    // split the file contents based on newlines
    var report_it = std.mem.splitSequence(u8, contents, "\n");

    while (report_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const levels = try parse_levels(allocator, line);
        defer allocator.free(levels);

        if (is_safe(levels)) {
            safe_reports += 1;
        } else if (dampener and can_be_safe_with_one_removal(allocator, levels)) {
            safe_reports += 1;
        }
    }

    std.debug.print("safe reports: {}\n", .{safe_reports});
}

fn parse_levels(allocator: std.mem.Allocator, line: []const u8) ![]const u32 {
    var levels = std.ArrayList(u32).init(allocator);
    var tokens = std.mem.splitScalar(u8, line, ' ');
    while (tokens.next()) |token| {
        const level = try std.fmt.parseInt(u32, token, 10);
        try levels.append(level);
    }
    return levels.toOwnedSlice();
}

fn is_safe(levels: []const u32) bool {
    if (levels.len < 2) return true;

    const direction: i2 = if (levels[1] > levels[0]) 1 else -1;
    for (levels[1..], 0..) |level, i| {
        const diff: i32 = @as(i32, @intCast(level)) - @as(i32, @intCast(levels[i]));
        if (diff * direction <= 0 or @abs(diff) > 3) {
            return false;
        }
    }
    return true;
}

fn can_be_safe_with_one_removal(allocator: std.mem.Allocator, levels: []const u32) bool {
    for (0..levels.len) |i| {
        var new_levels = std.ArrayList(u32).init(allocator);
        defer new_levels.deinit();

        for (levels, 0..) |level, j| {
            if (i != j) {
                new_levels.append(level) catch return false;
            }
        }
        if (is_safe(new_levels.items)) {
            return true;
        }
    }
    return false;
}
