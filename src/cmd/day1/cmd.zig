const std = @import("std");

pub const name: []const u8 = "day1";

pub fn run(
    allocator: std.mem.Allocator,
    args: [][]u8,
) !void {
    if (args.len < 1) {
        return error.MissingFileName;
    }

    // read file contents up to 16KB
    const contents = try std.fs.cwd().readFileAlloc(allocator, args[0], 16 * 1024);
    defer allocator.free(contents);

    // allocate lists and hash maps
    var left_list = std.ArrayList(u32).init(allocator);
    defer left_list.deinit();

    var right_list = std.ArrayList(u32).init(allocator);
    defer right_list.deinit();

    var right_map = std.AutoHashMap(u32, u32).init(allocator);
    defer right_map.deinit();

    // split the file contents based on newlines
    var it = std.mem.splitSequence(u8, contents, "\n");
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        // the file has a fixed format of three spaces, so we can split on that
        var n_it = std.mem.splitSequence(u8, line, "   ");

        const left = n_it.next().?;
        const right = n_it.next().?;

        const left_int = try std.fmt.parseUnsigned(u32, left, 10);
        try left_list.append(left_int);

        const right_int = try std.fmt.parseUnsigned(u32, right, 10);
        try right_list.append(right_int);

        // for the second task, we count the emount of entries in the
        // right map, so we don't have to run a second loop.
        const entry = try right_map.getOrPutValue(right_int, 0);
        entry.value_ptr.* += 1;
    }

    // sort the lists
    inline for (.{ left_list, right_list }) |l| {
        std.mem.sort(u32, l.items, {}, comptime std.sort.asc(u32));
    }

    // calculate the dotal distance
    var total_distance: u32 = 0;
    for (left_list.items, right_list.items) |l_value, r_value| {
        const abs = @abs(
            std.math.sub(u32, l_value, r_value) catch
                try std.math.sub(u32, r_value, l_value),
        );

        total_distance += abs;
    }
    std.debug.print("total distance: {}\n", .{total_distance});

    var similarity_score: u32 = 0;
    for (left_list.items) |left| {
        if (right_map.get(left)) |counter| {
            similarity_score += left * counter;
        }
    }
    std.debug.print("similarity score: {}\n", .{similarity_score});
}
