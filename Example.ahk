#Include EveryHangul.ahk

hangul := EveryHangul()
MsgBox(hangul.Split("잃어버린 것에 대하여", 0))
MsgBox(hangul.Split("잃어버린 것에 대하여", 1))
MsgBox(hangul.EngKey("끓다 / 붇다 / 의자 / 안녕 / ㄳ"))
MsgBox(hangul.FixParticle("평생교육를"))
MsgBox(hangul.FixParticleAll("철수은 영희이 서울에 있\는 경우 밥를 같이 먹기로 했다."))
