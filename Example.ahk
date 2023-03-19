#Include EveryHangul.ahk

hangul := EveryHangul()
MsgBox(hangul.Split("잃어버린 것에 대하여", 0))
MsgBox(hangul.Split("잃어버린 것에 대하여", 1))
MsgBox(hangul.EngKey("끓다 / 붇다 / 의자 / 안녕 / ㄳ"))
