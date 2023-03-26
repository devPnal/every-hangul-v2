[한국어](/README/ko.md) | [English](/README/en.md)

# 모두의 한글 v2
📚 한글 처리를 위한 오토핫키 라이브러리.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
⭐ → ❤️

## 사용 방법
아래와 같이 라이브러리 파일을 스크립트에 포함시킵니다.
```
#include EveryHangul.ahk
```

그 뒤, 새 인스턴스를 만듭니다.

```
instance := EveryHangul()
```

그 후 `instance.FunctionName` 형태로 라이브러리 내 함수를 자유롭게 이용할 수 있습니다.

예제 파일을 참고해 주세요. 

## 지원 기능
* Split() : 한글의 음소 분리 (안녕 > ㅇㅏㄴㄴㅕㅇ)
* EngKey() : 한글을 영타로 변환 (안녕 > dkssud)
* KorKey() : 영타를 한글로 변환 (dkssud > 안녕)
* FixParticle() : 조사 수정 (청춘를 > 청춘을)
* FixParticleAll() : 문장 내 조사 모두 수정 (철수은 영희을 좋아한다. > 철수는 영희를 좋아한다.)
* Combine() : 한글 자모 조합 (ㅎ,ㅣ,ㅎ > 힣)
* GetFirstConsonant() : 한글 초성 추출 (안녕 > ㅇㄴ)
* GetRandom() : 임의의 한글 자모 뽑기
* IsKoreanStatus() : 현재 IME 입력 모드가 한글인지 확인

## 지원 및 기여
* 사용 중 문제가 있을 경우 GitHub 이슈 등록을 하거나, 이메일 contact@pnal.dev로 연락 주세요.
* GitHub 기여는 언제든지 환영입니다. 추가 및 보완하고 싶은 기능을 자유롭게 기여해주세요.
