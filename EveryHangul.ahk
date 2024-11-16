/*
MIT License, Copyright (C) 2022 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * Every Hangul v2.2
 *
 * Author: 프날(Pnal) - https://pnal.dev (contact@pnal.dev)
 * Project URL: - https://github.com/devPnal/every-hangul-v2
 * Description: A library for handling with the Korean alphabet, 'Hangul'.
 * License: MIT License (see LICENSE file)
 *
 * If there are any awkward English sentences here, please contribute or contact me.
 * My native language is Korean so English is limited.
 * #############################################################
 */

#Requires AutoHotkey v2.0

class EveryHangul
{
	dev := {}

	__New()
	{
			this.dev := EveryHangul.Development()
			this.dev.RegisterCombineMethod(this.Combine.Bind(this))
	}

	/* =========================
	 * Split(_inputString, _isHard := 0)
	 * Split the Hangul string. (Example: 안녕 > ㅇㅏㄴㄴㅕㅇ)
	 *
	 * @Parameter
	 * _inputString: The string to split.
	 * _isHard:	0(Default) - Don't split the double final consonants. (ㄳ > ㄳ)
	 *			1 - Split the double final consonants. (ㄳ > ㄱㅅ)
	 *
	 * @Return value
	 * result: Splited string
	 * ==========================
	 */
	Split(_inputString, _isHard := 0)
	{
		result := ""
		Loop Parse, _inputString
		{
			if (Ord(A_LoopField) < Ord("가") || Ord(A_LoopField) > Ord("힣"))
			{
				result .= _isHard = 1 ? this.dev.SplitIfDoubleFinal(A_LoopField) : A_LoopField
				continue
			}
			charNum := this.dev.GetCharNum(A_LoopField)
			final := ""
			if (charNum.finalChar != 0)
				final := this.dev.finalArr[charNum.finalChar]
			if (_isHard = 1)
				final := this.dev.SplitIfDoubleFinal(final)
			result .= this.dev.firstArr[charNum.firstChar] this.dev.middleArr[charNum.middleChar] final
		}
		return result
	}

	/* =========================
	 * EngKey(_inputString)
	 * Convert a string from Korean to English keys (Example: 안녕 > dkssud)
	 *
	 * @Parameter
	 * _inputString: A string that converts from a Korean to English keys.
	 *
	 * @Return value
	 * result: Converted string
	 * ==========================
	 */
	EngKey(_inputString)
	{
		result := ""
		Loop Parse, _inputString
		{
			if (firstConsonantIndex := this.dev.IsFirstConsonant(A_LoopField))
				result .= this.dev.engFirstArr[firstConsonantIndex]
			else if (finalConsonantIndex := this.dev.IsFinalConsonant(A_LoopField))
				result .= this.dev.engFinalArr[finalConsonantIndex]
			else if (vowelIndex := this.dev.IsVowel(A_LoopField))
				result .= this.dev.engMiddleArr[vowelIndex]
			else if (isCompletedHangul := (Ord(A_LoopField) < Ord("가") || Ord(A_LoopField) > Ord("힣")))
				result .= A_LoopField

			if (firstConsonantIndex || finalConsonantIndex || vowelIndex || isCompletedHangul)
				continue

			charNum := this.dev.GetCharNum(A_LoopField)
			final := ""
			if (charNum.finalChar != 0)
				final := this.dev.engFinalArr[charNum.finalChar]
			result .= this.dev.engFirstArr[charNum.firstChar] this.dev.engMiddleArr[charNum.middleChar] final
		}
		return result
	}

	/* =========================
	 * KorKey(_inputString)
	 * Convert a string from English to Korean keys (Example: dkssud > 안녕)
	 *
	 * @Parameter
	 * _inputString: A string that converts from a English to Korean keys.
	 *
	 * @Return value
	 * result: Converted string
	 * ==========================
	 */
	KorKey(_inputString)
	{
		tempArr := []
		wordArr := []
		prevChar := prevPrevChar := result := ""
		Loop this.dev.doubleMiddleArr.Length
			_inputString := StrReplace(_inputString, this.dev.engDoubleMiddleArr[A_Index], this.dev.doubleMiddleArr[A_Index])
		Loop this.dev.middleArr.Length
			_inputString := StrReplace(_inputString, this.dev.engMiddleArr[A_Index], this.dev.middleArr[A_Index], True)
		Loop this.dev.middleArr.Length
			_inputString := StrReplace(_inputString, this.dev.engMiddleArr[A_Index], this.dev.middleArr[A_Index])
		Loop this.dev.doubleFinalArr.Length
			_inputString := RegExReplace(_inputString, this.dev.engDoubleFinalArr[A_Index] "([^ㅏ-ㅣ])", this.dev.doubleFinalArr[A_Index] "$1")
		Loop this.dev.finalArr.Length
			_inputString := RegExReplace(_inputString, this.dev.engFinalArr[A_Index] "([^ㅏ-ㅣ])", this.dev.FinalArr[A_Index] "$1")
		Loop this.dev.firstArr.Length
			_inputString := StrReplace(_inputString, this.dev.engFirstArr[A_Index], this.dev.firstArr[A_Index], True)
		Loop this.dev.firstArr.Length
			_inputString := StrReplace(_inputString, this.dev.engFirstArr[A_Index], this.dev.firstArr[A_Index])
		Loop Parse, _inputString
		{
			if ((this.dev.IsVowel(A_LoopField) && this.dev.IsVowel(prevChar)) || (this.dev.IsConsonant(A_LoopField) && this.dev.IsConsonant(prevChar)))
			{
				wordArr.Push(tempArr)
				tempArr := []
			}
			if (this.dev.IsVowel(prevPrevChar) && this.dev.IsFirstConsonant(prevChar) && this.dev.IsVowel(A_LoopField))
			{
				tempArr.Pop()
				wordArr.Push(tempArr)
				tempArr := [prevChar]
			}
			tempArr.Push(A_LoopField)
			if (A_LoopField ~= "[^ㄱ-ㅎㅏ-ㅣ]")
			{
				tempArr.Pop()
				wordArr.Push(tempArr)
				wordArr.Push([A_LoopField])
				tempArr := []
			}
			prevPrevChar := prevChar
			prevChar := A_LoopField
		}
		wordArr.Push(tempArr)
		Loop wordArr.Length
		{
			if (wordArr[A_Index].Length = 1)
				result .= wordArr[A_Index][1]
			else if (wordArr[A_Index].Length = 2 && this.dev.IsFirstConsonant(wordArr[A_Index][1]) && this.dev.IsVowel(wordArr[A_Index][2]))
				result .= this.Combine(wordArr[A_Index][1], wordArr[A_Index][2])
			else if (wordArr[A_Index].Length = 3 && this.dev.IsFirstConsonant(wordArr[A_Index][1]) && this.dev.IsVowel(wordArr[A_Index][2]) && this.dev.IsFinalConsonant(wordArr[A_Index][3]))
				result .= this.Combine(wordArr[A_Index][1], wordArr[A_Index][2], wordArr[A_Index][3])
			else
			{
				i := A_Index
				Loop wordArr[A_Index].Length
					result .= wordArr[i][A_Index]
			}
		}
		return result
	}

	/* =========================
	 * FixParticle(_inputString)
	 * Fix Korean prepositional particles automatically (Example: 교육를 > 교육을)
	 *
	 * @Parameter
	 * _inputString: The string that has wrong particles. The particle must be at the end of the input.
	 *
	 * @Return value
	 * result: Fixed string
	 *
	 * Note: If it given a string with no prepositional particle, it may be unwantedly overmodified. (Example: 인사고과 > 인사고와)
	 * ==========================
	 */
	FixParticle(_inputString)
	{
		trimedLength := 1
		if (SubStr(_inputString, -2) = "이여" || SubStr(_inputString, -2) = "으로" || SubStr(_inputString, -2) = "라고")
			trimedLength := 2
		if (SubStr(_inputString, -3) = "이라고")
			trimedLength := 3
		final := this.dev.GetCharNum(SubStr(_inputString, -trimedLength - 1, -1)).finalChar
		Switch SubStr(_inputString, -1)
		{
			Case "은", "는":
				particle := final = 0 ? "는" : "은"
			Case "을", "를":
				particle := final = 0 ? "를" : "을"
			Case "이", "가":
				particle := final = 0 ? "가" : "이"
			Case "과", "와":
				particle := final = 0 ? "와" : "과"
			Case "아", "야":
				particle := final = 0 ? "야" : "아"
			Case "여":
		   		particle := final = 0 ? "여" : "이여"
			Case "로":
				particle := final = 0 || final = 8 ? "로" : "으로"
			Case "고":
		   		particle := final = 0 ? "라고" : "이라고"
			Default:
				return _inputString
		}
		return SubStr(_inputString, 1, -trimedLength) particle
	}

	/* =========================
	 * FixParticleAll(_inputString)
	 * Fix All Korean prepositional particles in the given string (Example: 누구나 접근할 수 있은 웹로 > 누구나 접근할 수 있는 웹으로)
	 *
	 * @Parameter
	 * _inputString: The string that has wrong particles.
	 *
	 * @Return value
	 * result: Fixed string
	 *
	 * Note: Some cases, it may be unwantedly overmodified.
	 * If you want fix partially, you need to add '\' in front of where you don't want to fix it.
	 * You can use literal '\' if you use '\\'
	 * Example: 있는 것 > 있은 것 (x) => In this case, '는' is not particles. It's a kind of tubular endings. So we don't need to fix it.
	 *			있\는 것 > 있는 것 (o)
	 * ==========================
	 */
	FixParticleAll(_inputString)
	{
		Loop Parse, _inputString, A_Space
		{
			if (InStr(A_LoopField, "\") && !InStr(A_LoopField, "\\") )
			{
				result .= StrReplace(A_LoopField, "\") " "
				continue
			}
			result .= this.FixParticle(A_LoopField) " "
		}
		return StrReplace(result, "\\", "\")
	}

	/* =========================
	 * Combine(_first, _middle, _final)
	 * Combine consonants and a vowel to make a character. (Example: ㅎ + ㅢ + ㄴ = 흰)
	 *
	 * @Parameter
	 * _first: The first consonants what you want to combine.
	 * _middle: The vowel what you want to combine.
	 * _final: The final consonants what you want to combine. It can be omit. (Example: ㅅ+ㅓ+(omitted) = 서)
	 *
	 * @Return value
	 * result: Combinned string (just one combinned character)
	 * ==========================
	 */
	Combine(_first, _middle, _final := "")
	{
		firstIndex := middleIndex := 1
		finalIndex := 0

		Loop this.dev.firstArr.Length
			if (_first = this.dev.firstArr[A_Index])
				firstIndex := A_index
		Loop this.dev.middleArr.Length
			if (_middle = this.dev.middleArr[A_Index])
				middleIndex := A_index
		if (_final != "")
			Loop this.dev.finalArr.Length
				if (_final = this.dev.finalArr[A_Index])
					finalIndex := A_index

		result := Chr(0xAC00 + (((firstIndex - 1) * 21 + (middleIndex-1)) * 28 + finalIndex))
		result := Ord(result) >= Ord("가") && Ord(result) <= Ord("힣") ? result : _first _middle _final
		return result
	}

	/* =========================
	 * GetFirstConsonant(_inputString)
	 * Get the first consonants of the given string. (Example: 안녕하세요 > ㅇㄴㅎㅅㅇ)
	 *
	 * @Parameter
	 * _inputString: The string that you want to get first consonants.
	 *
	 * @Return value
	 * The first consonants of the given string.
	 * ==========================
	 */
	GetFirstConsonant(_inputString)
	{
		Loop Parse, _inputString
		{
			if (Ord(A_LoopField) < Ord("가") || Ord(A_LoopField) > Ord("힣"))
			{
				result .= A_LoopField
				continue
			}
			result .= this.dev.firstArr[this.dev.GetCharNum(A_LoopField).firstChar]
		}
		return result
	}

	/* =========================
	 * GetRandom(_sector)
	 * Get random korean consonants or vowels.
	 *
	 * @Parameter
	 * _sector: 1 - pick in first consonant list. (ㄱ, ㄲ, ㄴ...)
	 * 			2 - pick in vowel list. (ㅏ, ㅐ, ㅑ...)
	 *			3 - pick in final consonant list. (ㄱ, ㄲ, ㄳ...)
	 *
	 * @Return value
	 * result: picked character
	 *
	 * Note: You can write "First", "Middle", "Final" instead of 1, 2, 3. It helps code readable.
	 * ==========================
	 */
	GetRandom(_sector)
	{
		switch _sector
		{
			case 1, "First": return this.dev.firstArr[Random(1, 19)]
			case 2, "Middle": return this.dev.middleArr[Random(1, 21)]
			case 3, "Final": return this.dev.finalArr[Random(1, 27)]
			default: return ""
		}
	}

	/* =========================
	 * IsKoreanStatus(_windowID := "A")
	 * Check if the window's IME status is Korean.
	 *
	 * @Parameter
	 * _windowID: The hwnd of window that you want to get IME status. If omitted, the active window is selected.
	 *
	 * @Return value
	 * result: 	true(1) - The IME status is Korean.
	 *			false(0) - The IME status is not Korean.
	 *
	 * Note: Although you set IME as Korean, you MUST press right-alt key to change Korean input mode.
	 * If not, the function return only false.
	 * ==========================
	 */
	IsKoreanStatus(_windowID := "A")
	{
		detectMode := DetectHiddenWindows(true)
		result := SendMessage(0x283, 0x5, 0,,"ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinExist("A")))
		DetectHiddenWindows(detectMode)
		return result
	}

	/* =========================
	 * Pronounce(_inputString)
	 * Return standard pronounce of Korean sentence
	 *
	 * @Parameter
	 * _inputString: Writed text
	 *
	 * @Return value
	 * result: String that changed to standard pronounce
	 *
	 * Korean has many irregular conjugations and exceptions, so it's not perfect!
	 * Part-of-speech dependent pronunciations cannot be implemented.
	 * ==========================
	 */
	Pronounce(_inputString)
	{
		result := ""

		inputString := _inputString

		;연음 처리
		inputString := this.dev.linking(inputString)

		;제4장 12항 1, 붙임1, 붙임2
		inputString := this.dev.AlliterateHieut(inputString)

		;받침에 올 수 있는 ㄱㄴㄷㄹㅁㅂㅇ로 바꾸기
		inputString := this.dev.ChangeFinalChar(inputString)


		;제2장 5항 다만 1
		; 용언의 활용형이 아닌 져, 쪄, 쳐의 쓰임을 찾을 수 없었기 때문에, 모든 져, 쪄, 쳐를 일괄 변환
		inputString := RegExReplace(inputString, "져", "저")
		inputString := RegExReplace(inputString, "쪄", "쩌")
		inputString := RegExReplace(inputString, "쳐", "처")

		;제2장 5항 다만3
		uiArr := ["긔", "끠", "늬", "듸", "띄", "릐", "믜", "븨", "쁴", "싀", "씌", "즤", "쯰", "츼", "킈", "틔", "픠", "희"]
		iArr := ["기", "끼", "니", "디", "띠", "리", "미", "비", "삐", "시", "씨", "지", "찌", "치", "키", "티", "피", "히"]
		Loop uiArr.Length
			inputString := RegExReplace(inputString, "(([^가-힣])|^)(" uiArr[A_Index] ")", "$1" iArr[A_Index])

		;제5장 제17항 및 붙임
		inputString := this.dev.AssimilateFirstConsonant(_inputString, inputString)

		;제5장 제18항, 19항, 20항
		inputString := this.dev.AssimilateAll(inputString)

		;제6장
		inputString := this.dev.Tensionalization(inputString)

		result := inputString

		if (_inputString != result)
			result := this.Pronounce(result)
		return result
	}

	/* =========================
	 * Romanize(_inputString)
	 * Return standard romanization of Korean sentence
	 *
	 * @Parameter
	 * _inputString: Writed text
	 *
	 * @Return value
	 * result: String that changed to standard romanization
	 *
	 * Korean has many irregular conjugations and exceptions, so it's not perfect!
	 * Part-of-speech dependent pronunciations cannot be implemented.
	 * ==========================
	 */
	Romanize(_inputString)
	{
		inputString := this.Pronounce(_inputString)

		result := ""
		Loop Parse, inputString
		{
			if (Ord(A_LoopField) < Ord("가") || Ord(A_LoopField) > Ord("힣"))
			{
				if (index := this.dev.IsConsonant(A_LoopField))
				{
					result .= this.dev.romFirstArr[index]
					continue
				}
				else if (index := this.dev.IsVowel(A_LoopField))
				{
					result .= this.dev.romMiddleArr[index]
					continue
				}
				result .= A_LoopField
				continue
			}
			charNum := this.dev.GetCharNum(A_LoopField)
			first := this.dev.romFirstArr[charNum.firstChar]
			middle := this.dev.romMiddleArr[charNum.middleChar]
			final := ""
			if (charNum.finalChar != 0)
				final := this.dev.romFinalArr[charNum.finalChar]
			result .= first middle final
		}
		result := StrReplace(result, "lr", "ll")
		return StrUpper(SubStr(result, 1, 1)) SubStr(result, 2)
	}

	/* =========================
	 * [For development]
	 * Functions below this are used for other functions in this library and may be meaningless in actual use.
	 * For example, if you use the GetCharNum() function to get the index of Hangul character, this does not return the actual index of Unicode.
	 * Instead, GetCharNum() returns the index number only used in this library.
	 */
	class Development
	{
		static __combineMethod := {}

		RegisterCombineMethod(method)
		{
			this.__combineMethod := method
		}

		firstArr := ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
		middleArr := ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
		finalArr := ["ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
		doubleMiddleArr := ["ㅘ", "ㅙ", "ㅚ", "ㅝ", "ㅞ", "ㅟ", "ㅢ"]
		doubleFinalArr := ["ㄳ", "ㄵ", "ㄶ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅄ"]

		engFirstArr := ["r", "R", "s", "e", "E", "f", "a", "q", "Q", "t", "T", "d", "w", "W", "c", "z", "x", "v", "g"]
		engMiddleArr := ["k", "o", "i", "O", "j", "p", "u", "P", "h", "hk", "ho", "hl", "y", "n", "nj", "np", "nl", "b", "m", "ml", "l"]
		engFinalArr := ["r", "R", "rt", "s", "sw", "sg", "e", "f", "fr", "fa", "fq", "ft", "fx", "fv", "fg", "a", "q", "qt", "t", "T", "d", "w", "c", "z", "x", "v", "g"]
		engDoubleMiddleArr := ["hk", "ho", "hl", "nj", "np", "nl", "ml"]
		engDoubleFinalArr := ["rt", "sw", "sg", "fr", "fa", "fq", "ft", "fx", "fv", "fg", "qt"]

		pronounceFinalArr := ["ㄱ", "ㄱ", "ㄱ", "ㄴ", "ㄴ", "ㄴ", "ㄷ", "ㄹ", "ㄱ", "ㅁ", "ㄹ", "ㄹ", "ㄹ", "ㅍ", "ㄹ", "ㅁ", "ㅂ", "ㅂ", "ㄷ", "ㄷ", "ㅇ", "ㄷ", "ㄷ", "ㄱ", "ㄷ", "ㅂ", "ㄷ"]

		romFirstArr := ["g", "gg", "n", "d", "dd", "r", "m", "b", "bb", "s", "ss", "", "j", "jj", "ch", "k", "t", "p", "h"]
		romMiddleArr := ["a", "ae", "ya", "yae", "eo", "e", "yeo", "ye", "o", "wa", "wae", "oe", "yo", "u", "wo", "we", "wi", "yu", "eu", "ui", "i"]
		romFinalArr := ["k", "ㄲ", "ㄳ", "n", "ㄵ", "ㄶ", "t", "l", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "m", "p", "ㅄ", "ㅅ", "ㅆ", "ng", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
		;Final consonants are pronounce only ㄱㄴㄷㄹㅁㅂㅇ(k n t l m p ng)

		/* =========================
		 * SplitIfDoubleFinal(_input)
		 * Split the string if a double final consonant. (Example: ㄳ > ㄱㅅ)
		 *
		 * @Parameter
		 * _inputString: The string to split. This can be double final consonant or not.
		 *
		 * @Return value
		 * result: Splited string
		 * ==========================
		 */
		SplitIfDoubleFinal(_inputString)
		{
			result := _inputString
			Switch _inputString
			{
				case "ㄳ":
					result := "ㄱㅅ"
				case "ㄵ":
					result := "ㄴㅈ"
				case "ㄶ":
					result := "ㄴㅎ"
				case "ㄺ":
					result := "ㄹㄱ"
				case "ㄻ":
					result := "ㄹㅁ"
				case "ㄼ":
					result := "ㄹㅂ"
				case "ㄽ":
					result := "ㄹㅅ"
				case "ㄾ":
					result := "ㄹㅌ"
				case "ㄿ":
					result := "ㄹㅍ"
				case "ㅀ":
					result := "ㄹㅎ"
				case "ㅄ":
					result := "ㅂㅅ"
			}
			return result
		}

		/* =========================
		 * GetCharNum(_input)
		 * Get the Hangul character index.
		 *
		 * @Parameter
		 * _inputString: The string to get the index. This is must be completed Hangul.
		 *
		 * @Return value
		 * result: index dictionary. The result.finalChar is 0 when there isn't a final character.
		 * ==========================
		 */
		GetCharNum(_inputString)
		{
			result := {firstChar: "", middleChar: "", finalChar: ""}
			charNum := Ord(_inputString) - 44032
			result.finalChar := Mod(charNum, 28)
			result.middleChar := Mod(Floor((charNum - result.finalChar) / 28), 21) + 1
			result.firstChar := Floor(charNum / (21 * 28)) + 1
			if (result.finalChar < 1 || result.finalChar > 27)
				result.finalChar := 0
			return result
		}

		/* =========================
		 * IsConsonant(_inputString)
		 * Check if given string is in Korean consonants.
		 *
		 * @Parameter
		 * _inputString: A single string to check if it's in consonants.
		 *
		 * @Return value
		 * false(0) - if given string is not a consonant.
		 * true(1) - if given string is a consonant
		 * ==========================
		 */
		IsConsonant(_inputString)
		{
			return this.IsFirstConsonant(_inputString) || this.IsFinalConsonant(_inputString)
		}

		/* =========================
		 * IsVowel(_inputString)
		 * Check if given string is in Korean vowels.
		 *
		 * @Parameter
		 * _inputString: A single string to check if it's in vowels.
		 *
		 * @Return value
		 * false(0) - if given string is not a vowel
		 * true(index) - if given string is a vowel.
		 *
		 * Note: The 'index' means the index of middleArr[].
		 * ==========================
		 */
		IsVowel(_inputString)
		{
			Loop this.middleArr.Length
				if (this.middleArr[A_index] = _inputString)
					return A_index
			return false
		}

		/* =========================
		 * IsFirstConsonant(_inputString)
		 * Check if given string can be a first consonant(초성).
		 *
		 * @Parameter
		 * _inputString: A single string to check if it can be a first consonant
		 *
		 * @Return value
		 * false(0) - if given string can't be a first consonant
		 * true(index) - if given string can be a first consonant
		 *
		 * Note: The 'index' means the index of firstArr[].
		 * ==========================
		 */
		IsFirstConsonant(_inputString)
		{
			Loop this.firstArr.Length
				if (this.firstArr[A_index] = _inputString)
					return A_index
			return false
		}

		/* =========================
		 * IsFinalConsonant(_inputString)
		 * Check if given string can be a final consonant(종성).
		 *
		 * @Parameter
		 * _inputString: A single string to check if it can be a final consonant
		 *
		 * @Return value
		 * false(0) - if given string can't be a final consonant
		 * true(index) - if given string can be a final consonant
		 *
		 * Note: The 'index' means the index of finalArr[].
		 * ==========================
		 */
		IsFinalConsonant(_inputString)
		{
			Loop this.finalArr.Length
				if (this.finalArr[A_index] = _inputString)
					return A_index
			return false
		}

		/* =========================
		 * linking(_inputString)
		 * linking for 'ㅇ'
		 *
		 * @Parameter
		 * _inputString: String to Alliterate 'ㅇ' (ex: 연음 => 여늠)
		 *
		 * @Return value
		 * result: Alliterated string
		 * ==========================
		 */
		linking(_inputString)
		{
			stringArr := StrSplit(_inputString)
			trailedChar := ""
			result := ""
			for index, char in stringArr
			{
				if (Ord(char) < Ord("가") || Ord(char) > Ord("힣"))
				{
					result .= char
					continue
				}
				charNum := this.GetCharNum(char)
				first := this.firstArr[charNum.firstChar]
				middle := this.middleArr[charNum.middleChar]
				final := ""
				if (charNum.finalChar != 0)
					final := this.finalArr[charNum.finalChar]

				if (A_Index != stringArr.Length && this.GetCharNum(stringArr[A_Index + 1]).firstChar = 12 && final != "" && (final != "ㅇ" && final != "ㅎ") && trailedChar = "") ;다음 글의 자모가 ㅇ이면서 종성이 있을 경우
				{
					result .= this.Combine(first, middle)
					prevCharNum := charNum
					trailedChar := final
					continue
				}
				if (trailedChar) ;이전 글에서 연음이 일어났을 경우
				{
					if (trailedChar = this.SplitIfDoubleFinal(trailedChar)) ;홑모음이면
						result .= this.Combine(trailedChar, middle, final)
					else if (trailedChar != "ㄶ" && trailedChar != "ㅀ")
						result := SubStr(result, 1, -1) this.Combine(this.FirstArr[prevCharNum.firstChar], this.MiddleArr[prevCharNum.middleChar], SubStr(this.SplitIfDoubleFinal(trailedChar), 1, 1))  this.Combine(SubStr(this.SplitIfDoubleFinal(trailedChar), 2, 1), middle, final)
					else
						result := SubStr(result, 1, -1) this.Combine(this.FirstArr[prevCharNum.firstChar], this.MiddleArr[prevCharNum.middleChar], SubStr(this.SplitIfDoubleFinal(trailedChar), 1, 1))  this.Combine("ㅇ", middle, final)
					trailedChar := ""
					continue
				}
				result .= char
			}
			if (_inputString != result)
				result := this.linking(result)
			return result
		}

		/* =========================
		 * AlliterationHieut(_inputString)
		 * Alliteration for 'ㅎ'
		 *
		 * @Parameter
		 * _inputString: String to Alliterate final 'ㅎ' (ex: 닿다 => 다타, 닿길 => 다킬, 닫힘 => 다팀)
		 *
		 * @Return value
		 * result: Alliterated string
		 * ==========================
		 */
		AlliterateHieut(_inputString)
		{
			stringArr := StrSplit(_inputString)
			prevChar := ""
			result := ""
			trailedChar := ""
			for index, char in stringArr
			{
				if (Ord(char) < Ord("가") || Ord(char) > Ord("힣"))
				{
					result .= char
					continue
				}
				charNum := this.GetCharNum(char)
				first := this.firstArr[charNum.firstChar]
				middle := this.middleArr[charNum.middleChar]
				final := ""

				prevCharNum := this.GetCharNum(prevChar)
				if (charNum.finalChar != 0)
					final := this.finalArr[charNum.finalChar]

				if (A_Index != 1) ;'닿다'와 같이 이전 글자의 종성이 ㅎ인 경우
				{
					switch this.GetCharNum(stringArr[A_Index - 1]).finalChar
					{
						case 27: ;ㅎ
							result := first = "ㄱ" || first = "ㄷ" || first = "ㅈ" || first = "ㅅ" || first = "ㄴ" ? AlliterateCombine(result, "") : AlliterateCombine(result, final)
							continue
						case 6: ;ㄶ
							result := AlliterateCombine(result, "ㄴ")
							continue
						case 15: ;ㅀ
							result := AlliterateCombine(result, "ㄹ")
							continue
					}
				}

				; '닫힘'과 같이 다음 글자의 초성이 ㅎ인 경우
				if (A_Index != stringArr.Length && this.GetCharNum(stringArr[A_Index + 1]).firstChar = 19 && final != "" && trailedChar = "") ;다음 글의 자모가 ㅎ이면서 종성이 있을 경우
				{
					switch final
					{
						case "ㄺ", "ㄼ":
							result .= this.Combine(first, middle, "ㄹ")
						case "ㄵ":
							result .= this.Combine(first, middle, "ㄴ")
						case "ㄱ", "ㄺ", "ㄷ", "ㅅ", "ㅈ", "ㅊ", "ㅌ", "ㅂ", "ㄼ", "ㄵ":
							result .= this.Combine(first, middle)
						default:
							result .= this.Combine(first, middle, final)
					}
					trailedChar := final
					continue
				}
				if (trailedChar) ;이전 글에서 연음이 일어났을 경우
				{
					trail := ""
					switch trailedChar
					{
						case "ㄱ", "ㄺ":
							trail := "ㅋ"
						case "ㄷ", "ㅅ", "ㅈ", "ㅊ", "ㅌ":
							trail := "ㅌ"
						case "ㅂ", "ㄼ":
							trail := "ㅍ"
						case "ㅈ", "ㄵ":
							trail := "ㅊ"
						default:
							result .= this.Combine(first, middle, final)
							trailedChar := ""
							continue
					}
					result .= this.Combine(trail, middle, final)
					trailedChar := ""
					continue
				}

				result .= char
				prevChar := char
			}
			if (_inputString != result)
				result := this.AlliterateHieut(result)
			return result

			AlliterateCombine(_string, _changedChar)
			{
				result := SubStr(_string, 1, -1) this.Combine(this.firstArr[prevCharNum.firstChar], this.middleArr[prevCharNum.middleChar], _changedChar)
				if (first = "ㄴ")
				{
					result := SubStr(_string, 1, -1) this.Combine(this.firstArr[prevCharNum.firstChar], this.middleArr[prevCharNum.middleChar], "ㄴ")
					if (this.finalArr[prevCharNum.finalChar] = "ㅀ")
						result := SubStr(_string, 1, -1) this.Combine(this.firstArr[prevCharNum.firstChar], this.middleArr[prevCharNum.middleChar], "ㄹ")
				}
				switch first
				{
					case "ㄱ":
						result .= this.Combine("ㅋ", middle, final)
					case "ㄷ":
						result .= this.Combine("ㅌ", middle, final)
					case "ㅈ":
						result .= this.Combine("ㅊ", middle, final)
					case "ㅅ":
						result .= this.Combine("ㅆ", middle, final)
					default:
						result .= this.Combine(first, middle, final)
				}
				return result
			}
		}

		/* =========================
		 * ChangeFinalChar(_inputString)
		 * Change final char to ㄱㄴㄷㄹㅁㅂㅇ
		 *
		 * @Parameter
		 * _inputString: String to change final consonant (ex: 티읕 => 티읃)
		 *
		 * @Return value
		 * result: Chnaged string
		 * ==========================
		 */
		ChangeFinalChar(_inputString)
		{
			stringArr := StrSplit(_inputString)
			trailedChar := ""
			result := ""
			for index, char in stringArr
			{
				if (Ord(char) < Ord("가") || Ord(char) > Ord("힣"))
				{
					result .= char
					continue
				}
				charNum := this.GetCharNum(char)
				first := this.firstArr[charNum.firstChar]
				middle := this.middleArr[charNum.middleChar]
				final := ""
				if (charNum.finalChar != 0)
					final := this.pronounceFinalArr[charNum.finalChar]

				result .= this.Combine(first, middle, final)
			}
			return result
		}

		/* =========================
		 * AssimilateFirstConsonant(_original, _changed)
		 * Assimilate consonant (자음동화)
		 *
		 * @Parameter
		 * _original: Original string
		 * _changed: String to assimilate all ㄷ, ㅌ (ex: 미다디 => 미다지)
		 *
		 * @Return value
		 * result: Chnaged string
		 * ==========================
		 */
		AssimilateFirstConsonant(_original, _changed)
		{
			originalChars := StrSplit(_original)
			changedChars := StrSplit(_changed)
			result := ""
			Loop changedChars.Length
			{
				if (originalChars[A_Index] = "이" && changedChars[A_Index] = "디")
				{
					result .= "지"
					continue
				}
				else if ((originalChars[A_Index] = "이" && changedChars[A_Index] = "티") || (originalChars[A_Index] = "히" && changedChars[A_Index] = "티"))
				{
					result .= "치"
					continue
				}
				result .= changedChars[A_Index]
			}
			return result
		}

		/* =========================
		 * AssimilateAll(_inputString)
		 * Assimilate all consonants
		 *
		 * @Parameter
		 * _inputString: String to assimilate all consonants (ex: 밥먹음 => 밤먹음, 협력 => 혐녁, 신라 => 실라)
		 *
		 * @Return value
		 * result: Chnaged string
		 * ==========================
		 */
		AssimilateAll(_inputString)
		{
			ExceptWords := ["의견란", "임진란", "생산량", "결단력", "공권력", "동원령", "상견례", "횡단로", "이원론", "입원료", "구근류"]
			ExceptWordsAnswer := ["의견난", "임진난", "생산냥", "결딴녁", "공꿘녁", "동원녕", "상견녜", "횡단노", "이원논", "이붠뇨", "구근뉴"]

			for index, element in ExceptWords
			{
				_inputString := StrReplace(_inputString, element, ExceptWordsAnswer[index])
			}

			stringArr := StrSplit(_inputString)
			result := ""
			bieumization := false
			prevFinal := ""
			for index, char in stringArr
			{
				if (Ord(char) < Ord("가") || Ord(char) > Ord("힣"))
				{
					result .= char
					continue
				}
				charNum := this.GetCharNum(char)
				first := this.firstArr[charNum.firstChar]
				middle := this.middleArr[charNum.middleChar]
				final := ""
				if (charNum.finalChar != 0)
					final := this.finalArr[charNum.finalChar]

				;다음 글의 초성이 ㄴ, ㅁ이면서 종성이 있을 경우 (5-18)
				if (A_Index != stringArr.Length
				&& (this.GetCharNum(stringArr[A_Index + 1]).firstChar = 3 || this.GetCharNum(stringArr[A_Index + 1]).firstChar = 7)
				&& (final = "ㄱ" || final = "ㄷ" || final = "ㅂ"))
				{
					Switch final
					{
						case "ㄱ":
							result .= this.Combine(first, middle, "ㅇ")
						case "ㄷ":
							result .= this.Combine(first, middle, "ㄴ")
						case "ㅂ":
							result .= this.Combine(first, middle, "ㅁ")
					}
					continue
				}
				if (bieumization) ;비음화
				{
					result .= this.Combine("ㄴ", middle, final)
					bieumization := false
					continue
				}
				else if (A_Index != stringArr.Length && this.GetCharNum(stringArr[A_Index + 1]).firstChar = 6 && (final = "ㄱ" || final = "ㅂ" || final = "ㅁ" || final = "ㅇ")) ;다음 글자의 초성이 ㄹ이면서 받침이 ㄱ, ㅂ, ㅁ, ㅇ이 경우 (5-19)
					bieumization := true

				;받침 ㄴ, 다음 글자 초성 ㄹ일 경우 ㄴ을 ㄹ로 발음 (5-20)
				if (A_Index != stringArr.Length && this.GetCharNum(stringArr[A_Index + 1]).firstChar = 6 && (final = "ㄴ"))
				{
					result .= this.Combine(first, middle, "ㄹ")
					continue
				}
				;현재 글자 초성 ㄴ, 이전 받침 ㄹ일 경우 ㄴ을 ㄹ로 발음 (5-20)
				else if (A_Index != 1 && prevFinal = "ㄹ" && first = "ㄴ")
				{
					result .= this.Combine("ㄹ", middle, final)
					continue
				}
				result .= char
				prevFinal := final
			}
			if (_inputString != result)
				result := this.linking(result)
			return result
		}

		/* =========================
		 * Tensionalization(_inputString)
		 * Tensioning all consonants (된소리되기)
		 *
		 * @Parameter
		 * _inputString: String to tension all consonants (ex: 꼳밭 => 꼳빧)
		 *
		 * @Return value
		 * result: Chnaged string
		 * ==========================
		 */
		Tensionalization(_inputString)
		{
			stringArr := StrSplit(_inputString)
			prevFinal := ""
			result := ""
			trailedChar := ""
			for index, char in stringArr
			{
				if (Ord(char) < Ord("가") || Ord(char) > Ord("힣"))
				{
					result .= char
					prevFinal := ""
					continue
				}
				charNum := this.GetCharNum(char)
				first := this.firstArr[charNum.firstChar]
				middle := this.middleArr[charNum.middleChar]
				final := ""

				if (charNum.finalChar != 0)
					final := this.finalArr[charNum.finalChar]

				if (A_Index != 1 && (prevFinal = "ㄱ" || prevFinal = "ㄷ" || prevFinal = "ㅂ")) ;'꼳밭'과 같이 이전 글자의 종성이 ㄱ, ㄷ, ㅂ인 경우
				{
					switch first
					{
						case "ㄱ":
							result .= this.Combine("ㄲ", middle, final)
							continue
						case "ㄷ":
							result .= this.Combine("ㄸ", middle, final)
							continue
						case "ㅂ":
							result .= this.Combine("ㅃ", middle, final)
							continue
						case "ㅈ":
							result .= this.Combine("ㅉ", middle, final)
							continue
						case "ㅅ":
							result .= this.Combine("ㅆ", middle, final)
							continue
					}
				}
				result .= char
				prevFinal := final
			}
			if (_inputString != result)
				result := this.Tensionalization(result)
			return result
		}

		/*=========================
		 * Combine(_first, _middle, _final)
		 * Combine consonants and a vowel to make a character. (Example: ㅎ + ㅢ + ㄴ = 흰)
		 *
		 * @Parameter
		 * _first: The first consonants what you want to combine.
		 * _middle: The vowel what you want to combine.
		 * _final: The final consonants what you want to combine. It can be omit. (Example: ㅅ+ㅓ+(omitted) = 서)
		 *
		 * @Return value
		 * result: Combinned string (just one combinned character)
		 * ==========================
		 */
		Combine(_first, _middle, _final := "")
		{
			firstIndex := middleIndex := 1
			finalIndex := 0

			Loop this.firstArr.Length
				if (_first = this.firstArr[A_Index])
					firstIndex := A_index
			Loop this.middleArr.Length
				if (_middle = this.middleArr[A_Index])
					middleIndex := A_index
			if (_final != "")
				Loop this.finalArr.Length
					if (_final = this.finalArr[A_Index])
						finalIndex := A_index

			result := Chr(0xAC00 + (((firstIndex - 1) * 21 + (middleIndex-1)) * 28 + finalIndex))
			result := Ord(result) >= Ord("가") && Ord(result) <= Ord("힣") ? result : _first _middle _final
			return result
		}
	}
}
