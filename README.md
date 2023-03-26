[한국어](/README/ko.md) | [English](/README/en.md)

# Every Hangul v2
📚 AutoHotkey library for processing the Korean alphabet, "Hangul".

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)<br>
⭐ → ❤️

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
* Split() : Split phonemes in Hangul (안녕 > ㅇㅏㄴㄴㅕㅇ)
* EngKey() : Convert Korean to English keys (안녕 > dkssud)
* KorKey() : Convert English to Korean keys (dkssud > 안녕)
* FixParticle() : Fix Korean particles (청춘를 > 청춘을)
* FixParticleAll() : Fix all Korean particles in sentence (철수은 영희을 좋아한다. > 철수는 영희를 좋아한다.)
* Combine() : Combine the korean consonants and vowels (ㅎ,ㅣ,ㅎ > 힣)
* GetFirstConsonant() : Get the first consonants (안녕 > ㅇㄴ)
* GetRandom() : Pick random Korean consonants or vowels
* IsKoreanStatus() : Check if current IME mode is Korean

## Support and contributions
* If you have any problems during use, please register a GitHub issue or email to contact@pnal.dev
* GitHub contributions are always welcome. Please feel free to contribute features you would like to see added and enhanced.
