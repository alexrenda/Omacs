open Assertions
open OBuffer
open File

TEST_UNIT =
    let file = File.file_of_string "test_buffer.ml" in
    let buf = OBuffer.make_from_file file 9 25 in

    (* Test string setting/getting *)
    ignore(OBuffer.set_text buf "");
    OBuffer.get_string buf === "";

    ignore(OBuffer.set_text buf "abcdefghi\n123456789");
    OBuffer.get_string buf  === "abcdefghi\n123456789";

    (* Test cursor ops/getters *)
    ignore(OBuffer.move_cursor_to_end buf);
    OBuffer.get_char_at_cursor buf === None;

    ignore(OBuffer.move_cursor_to_beginning buf);
    OBuffer.get_char_at_cursor buf === Some 'a';

    ignore(OBuffer.move_cursor_right buf);
    OBuffer.get_char_at_cursor buf === Some 'b';

    ignore(OBuffer.move_cursor_left buf);
    OBuffer.get_char_at_cursor buf === Some 'a';

    ignore(OBuffer.move_cursor_left buf);
    OBuffer.get_char_at_cursor buf === Some 'a';

    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    OBuffer.get_char_at_cursor buf === Some 'd';

    OBuffer.get_col buf === 4;
    OBuffer.get_row buf === 1;

    ignore(OBuffer.move_cursor_down buf);
    OBuffer.get_char_at_cursor buf === Some '4';

    ignore(OBuffer.move_cursor_right buf);
    OBuffer.get_char_at_cursor buf === Some '5';

    OBuffer.get_col buf === 5;
    OBuffer.get_row buf === 2;

    OBuffer.get_width buf === 25;
    OBuffer.get_height buf === 9;

    OBuffer.get_mark buf === None;

    (* Test text edits/setters *)
    ignore(OBuffer.set_col buf 1);
    ignore(OBuffer.set_row buf 1);
    OBuffer.get_char_at_cursor buf === Some 'a';

    ignore(OBuffer.set_width buf 10);
    ignore(OBuffer.set_height buf 15);
    OBuffer.get_width buf === 10;
    OBuffer.get_height buf === 15;

    ignore(OBuffer.insert_char_at_cursor buf 'z');
    OBuffer.get_char_at_cursor buf === Some 'a';
    ignore(OBuffer.move_cursor_left buf);
    OBuffer.get_char_at_cursor buf === Some 'z';

    ignore(OBuffer.delete_char_at_cursor buf);
    OBuffer.get_char_at_cursor buf === Some 'a';
    OBuffer.get_col buf === 1;
    OBuffer.get_row buf === 1;

    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.delete_char_before_cursor buf);
    OBuffer.get_col buf === 1;
    OBuffer.get_row buf === 1;

    ignore(OBuffer.insert_text_at_cursor buf "Hello!");
    ignore(OBuffer.move_cursor_to_beginning buf);
    OBuffer.get_char_at_cursor buf === Some 'H';

    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    ignore(OBuffer.move_cursor_right buf);
    OBuffer.get_char_at_cursor buf === Some '!';

    ()
