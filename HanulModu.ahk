/*
MIT License, Copyright (C) 2022 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * HanulModu v2.0.0
 *
 * Author: 프날(Pnal) - https://pnal.dev (contact@pnal.dev)
 * Project URL: - https://github.com/devPnal/HanulModu
 * Description: A library for handling with the Korean alphabet, 'Hangul'.
 * License: MIT License (see LICENSE file)
 *
 * If there are any awkward English sentences here, please contribute or contact me.
 * My native language is Korean so English is limited.
 * #############################################################
 */

#Requires AutoHotkey v2.0

class HanulModu
{
	dev := HanulModu.Development()

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
	 * [For development]
	 * Functions below this are used for other functions in this library and may be meaningless in actual use.
	 * For example, if you use the GetCharNum() function to get the index of Hangul character, this does not return the actual index of Unicode.
	 * Instead, GetCharNum() returns the index number only used in this library.
	 */
	class Development
	{
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
	}
}
