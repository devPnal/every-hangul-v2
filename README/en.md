[한국어](/README/ko.md) | [English](/README/en.md)

# Every Hangul v2
📚 AutoHotkey library for processing the Korean alphabet, "Hangul".

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## How to use
Include the library file in your script like below .
```
#include EveryHangul.ahk
```

After that, create a new instance.

```
instance := EveryHangul()
```

Now, you can freely use the functions in the library in the form of `instance.FunctionName`.

Please refer to the example file.

## Supported functions
* Split phonemes in Hangul (안녕 > ㅇㅏㄴㄴㅕㅇ)
* Convert Korean to English keys (안녕 > dkssud)
* Fix Korean particles (청춘를 > 청춘을)
* Fix all Korean particles in sentence (철수은 영희을 좋아한다. > 철수는 영희를 좋아한다.)

## Support and contributions
* If you have any problems during use, please register a GitHub issue or email to contact@pnal.dev
* GitHub contributions are always welcome. Please feel free to contribute features you would like to see added and enhanced.
