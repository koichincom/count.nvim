const std = @import("std");
const print = std.debug.print;
const c = @cImport({
    @cInclude("md4c.h");
});

const FileExtension = enum(c_int) {
    md,
    mdx,
    qmd,
    rmd,
};

const CountMask = extern struct {
    word: bool = false,
    line: bool = false,
    char: bool = false,
    sentence: bool = false,
    paragraph: bool = false,
    byte: bool = false,
};

const Counter = struct {
    word_count: usize = 0,
    line_count: usize = 0,
    char_count: usize = 0,
    sentence_count: usize = 0,
    paragraph_count: usize = 0,
    byte_count: usize = 0,
};

pub export fn count(
    content_ptr: [*]const u8,
    content_len: usize,
    extension: FileExtension,
    mask: CountMask,
) callconv(.c) void {
    const content = content_ptr[0..content_len];
    _ = content;
    _ = mask;

    if (content_len <= 0) {
        print("Empty content provided\n", .{});
        return;
    }

    switch (extension) {
        .md => {
            test_parse() catch |err| {
                print("test_parse failed: {s}\n", .{@errorName(err)});
            };
        },
        else => {
            print("Currently not supported\n", .{});
            return;
        },
    }
}

fn test_parse() !void {
    const path = "samples/1.md";
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, @intCast(file_size));
    defer allocator.free(buffer);
    const bytes_read = try file.readAll(buffer);
    const content = buffer[0..bytes_read];

    counter = 0;

    var parser = std.mem.zeroes(c.MD_PARSER);
    parser.abi_version = 0;
    parser.flags = 0;
    parser.text = test_callback;

    const rc = c.md_parse(
        @ptrCast(content.ptr),
        @intCast(content.len),
        &parser,
        null,
    );

    print("md_parse rc={d}\n", .{rc});
    print("total text callbacks={d}\n", .{counter});
}

var counter: u32 = 0;
fn test_callback(
    text_type: c.MD_TEXTTYPE,
    text_ptr: [*c]const c.MD_CHAR,
    size: c.MD_SIZE,
    userdata: ?*anyopaque,
) callconv(.c) c_int {
    _ = text_type;
    _ = text_ptr;
    _ = size;
    _ = userdata;

    counter += 1;
    print("Callback invoked {d} times\n", .{counter});
    return 0;
}

test "count function works" {
    const text = "Sample Markdown\n";
    count(text.ptr, text.len, .md, .{ .word = true });
    count(text.ptr, text.len, .mdx, .{ .word = true });
    count(text.ptr, text.len, .qmd, .{ .word = true });
    count(text.ptr, text.len, .rmd, .{ .word = true });
}
