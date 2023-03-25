use std::{collections::HashMap};

const FIRST_CHARS: [&str; 19] = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];
const MIDDLE_CHARS: [&str; 21] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
const FINAL_CHARS: [&str; 28] = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];

//const eng_first_chars : &'static [&str] = &["r", "R", "s", "e", "E", "f", "a", "q", "Q", "t", "T", "d", "w", "W", "c", "z", "x", "v", "g"];
//onst eng_middle_chars : &'static [&str] = &["k", "o", "i", "O", "j", "p", "u", "P", "h", "hk", "ho", "hl", "y", "n", "nj", "np", "nl", "b", "m", "ml", "l"];
//const eng_final_chars : &'static [&str] = &["r", "R", "rt", "s", "sw", "sg", "e", "f", "fr", "fa", "fq", "ft", "fx", "fv", "fg", "a", "q", "qt", "t", "T", "d", "w", "c", "z", "x", "v", "g"];

#[allow(non_snake_case)]
#[no_mangle]
pub extern fn Split(input_string:&str, break_all:bool) -> String {
    let mut result = String::new();
    let mut char_num;
    let mut final_char;
    for c in input_string.chars() {
        if !IsInHangul(c) {
            result.push_str(&c.to_string());
            continue;
        }
        char_num = GetCharNum(c);
        final_char = String::new();
        if let Some(i) = char_num.get("first_char") { result.push_str(FIRST_CHARS[*i as usize]); }
        if let Some(i) = char_num.get("middle_char") { result.push_str(MIDDLE_CHARS[*i as usize]); }
        if let Some(i) = char_num.get("final_char") { final_char = FINAL_CHARS[*i as usize].to_string(); }
        if break_all == true { final_char = SplitIfDoubleFinal(final_char); }
        result.push_str(final_char.as_str());
    }
    return result;
}

#[allow(non_snake_case)]
fn IsInHangul(input_char:char) -> bool {
    return input_char >= '가' && input_char <= '힣'
}

#[allow(non_snake_case)]
fn GetCharNum(input_char:char) -> HashMap<String, u8> {
    let mut result : HashMap<String, u8>  = HashMap::new();
    let char_num = input_char as u16 - 0xAC00;

    let first_char_tmp = (char_num / (21 * 28)) as f64;
    result.insert(String::from("first_char"), first_char_tmp as u8);

    let middle_char_tmp = char_num as f64 / 28.0 % 21.0;
    result.insert(String::from("middle_char"), middle_char_tmp as u8);

    let final_char_tmp = char_num % 28;
    result.insert(String::from("final_char"), final_char_tmp as u8);

    return result;
}

#[allow(non_snake_case)]
fn SplitIfDoubleFinal(input_char:String) -> String {
    let result;
    match input_char.as_str() {
        "ㄳ" => result = String::from("ㄱㅅ"),
        "ㄵ" => result = String::from("ㄴㅈ"),
        "ㄶ" => result = String::from("ㄴㅎ"),
        "ㄺ" => result = String::from("ㄹㄱ"),
        "ㄻ" => result = String::from("ㄹㅁ"),
        "ㄼ" => result = String::from("ㄹㅂ"),
        "ㄽ" => result = String::from("ㄹㅅ"),
        "ㄾ" => result = String::from("ㄹㅌ"),
        "ㄿ" => result = String::from("ㄹㅍ"),
        "ㅀ" => result = String::from("ㄹㅎ"),
        "ㅄ" => result = String::from("ㅂㅅ"),
        _ => result = input_char,
    };
    return result;
}
