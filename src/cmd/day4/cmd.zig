const std = @import("std");

pub const name: []const u8 = "day4";

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

    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    var report_it = std.mem.splitScalar(u8, contents, '\n');
    while (report_it.next()) |next| {
        if (next.len != 0) {
            try list.append(next);
        }
    }

    if (args.len > 1) {
        part2(list.items);
    } else {
        part1(list.items);
    }
}

fn part1(matrix: [][]const u8) void {
    const max_y = matrix.len;
    const max_x = matrix[0].len;

    const search = "XMAS";
    const reversed_search = "SAMX";

    var result: u32 = 0;

    for (0..max_y) |y| {
        for (0..max_x) |x| {
            // forward and reverse search
            if (x + search.len <= max_x and
                (std.mem.eql(u8, matrix[y][x .. x + search.len], search) or
                std.mem.eql(u8, matrix[y][x .. x + reversed_search.len], reversed_search)))
            {
                result += 1;
            }

            // downward forward and reverse search
            if (y + search.len <= max_y) {
                var word: [4]u8 = undefined;
                for (0..search.len) |i| {
                    word[i] = matrix[y + i][x];
                }

                if (std.mem.eql(u8, &word, search) or std.mem.eql(u8, &word, reversed_search)) {
                    result += 1;
                }
            }

            // diagonal right
            if (y + search.len <= max_y and x + search.len <= max_x) {
                var word: [4]u8 = undefined;
                for (0..search.len) |i| {
                    word[i] = matrix[y + i][x + i];
                }
                if (std.mem.eql(u8, &word, search) or std.mem.eql(u8, &word, reversed_search)) {
                    result += 1;
                }
            }

            // diagonal left
            if (x >= search.len - 1 and y + search.len <= max_y and 0 <= x - (search.len - 1)) {
                var word: [4]u8 = undefined;
                for (0..search.len) |i| {
                    word[i] = matrix[y + i][x - i];
                }
                if (std.mem.eql(u8, &word, search) or std.mem.eql(u8, &word, reversed_search)) {
                    result += 1;
                }
            }
        }
    }

    std.debug.print("result: {}\n", .{result});
}

fn part2(matrix: [][]const u8) void {
    const max_y = matrix.len;
    const max_x = matrix[0].len;

    const search = "MAS";
    const reversed_search = "SAM";

    var result: u32 = 0;

    for (0..max_y) |y| {
        for (0..max_x) |x| {
            // diagonal right
            if (y + search.len <= max_y and x + search.len <= max_x) {
                var word: [3]u8 = undefined;
                for (0..search.len) |i| {
                    word[i] = matrix[y + i][x + i];
                }
                if (std.mem.eql(u8, &word, search) or std.mem.eql(u8, &word, reversed_search)) {
                    var word2: [3]u8 = undefined;
                    for (0..search.len) |i| {
                        word2[i] = matrix[y + (search.len - i) - 1][x + i];
                    }
                    if (std.mem.eql(u8, &word2, search) or std.mem.eql(u8, &word2, reversed_search)) {
                        result += 1;
                    }
                }
            }
        }
    }

    std.debug.print("result: {}\n", .{result});
}
