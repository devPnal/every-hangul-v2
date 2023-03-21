/*
MIT License, Copyright (C) 2022 프날(Pnal, contact@pnal.dev)
You should have received a copy of the MIT License along with this library.
*/

/* #############################################################
 * Every Hangul v2.0.0
 *
 * Author: 프날(Pnal) - https://pnal.dev (blog: https://blog.pnal.dev)
 * Contact: Contact@pnal.dev
 * Description: A library for handling with the Korean alphabet, 'Hangul'.
 * License: MIT License (see LICENSE file)
 *
 * If there are any awkward English sentences here, please contribute or contact me.
 * My native language is Korean so English is limited.
 * #############################################################
 */

#Include EveryHangul.ahk

hangul := EveryHangul() ;Create Instance

;Split() splits all consonants and vowels.
MsgBox(hangul.Split("헌법 제31조"))

;EngKey() converts Korean to English keyboard layout. (두벌식 > QWERTY)
MsgBox(hangul.EngKey("① 모든 국민은 능력에 따라 균등하게 교육을 받을 권리를 가진다. "))

;KorKey() converts English to Korean keyboard layout. (QWERTY > 두벌식)
MsgBox(hangul.KorKey("② ahems rnralsdms rm qhghgksms wksudprp wjrdjeh chemdrydbrrhk qjqfbfdl wjdgksms rydbrdmf qkerp gkf dmlanfmf wlsek."))

;FixParticle() fixes a particles in a last word. (은>는, 로>으로)
MsgBox(hangul.FixParticle("③ 의무교육는") hangul.FixParticle(" 무상로") " 한다.")

;FixParticleAll() fixes all particles in a sentense. (는>은, 가>이)
MsgBox(hangul.FixParticleAll("④ 교육의 자주성ㆍ전문성ㆍ정치적 중립성 및 대학의 자율성는 법률가 정하는 바에 의하여 보장된다."))

;Combine() makes perfect Korean character. (ㅍ+ㅕ+ㅇ = 평, ㅅ+ㅐ+ㅇ = 생, ㄱ+ㅛ = 교, ㅇ+ㅠ+ㄱ = 육)
Msgbox("⑤ 국가는 " hangul.Combine("ㅍ", "ㅕ", "ㅇ") hangul.Combine("ㅅ", "ㅐ", "ㅇ") hangul.Combine("ㄱ", "ㅛ") hangul.Combine("ㅇ", "ㅠ", "ㄱ") "을 진흥하여야 한다.")

;GetRandom() gives a random character.
first := hangul.GetRandom(1)
middle := hangul.GetRandom(2)
final := hangul.GetRandom(3)
Msgbox(first ", " middle ", " final "`nCombined: " hangul.Combine(first, middle, final))

;IsKoreanStatus() returns true when you can type Korean now.
if (hangul.IsKoreanStatus())
	MsgBox("You can write Korean now")
else
	MsgBox("You can't write Korean now. The IME is English or something else")

;IsKoreanStatus() can get any window's IME status.
;NOTE: In default settings, the values are same between windows. (All are 0 or 1)
allWindowID := WinGetList()
result := "Window ID`tstatus`n"
Loop allWindowID.Length
	result .= "Win # " allWindowID[A_Index] "`t" hangul.IsKoreanStatus(allWindowID[A_Index]) "`n"
Msgbox(result)

;More details can be found in the library file (EveryHangul.ahk). There are detailed descriptions of the functions.
