#Requires AutoHotkey v2.0
#SingleInstance Force
; Переключение между RU и EN по Alt+Shift (в любом порядке нажатия)
~*LAlt::TrySwitch()
~*RAlt::TrySwitch()
~*LShift::TrySwitch()
~*RShift::TrySwitch()
TrySwitch() {
    static lastTick := 0
    if !(GetKeyState("Alt", "P") && GetKeyState("Shift", "P"))
        return
    ; Защита от двойного срабатывания при одновременных событиях клавиш
    now := A_TickCount
    if (now - lastTick < 150)
        return
    lastTick := now
    ToggleRuEn()
}
ToggleRuEn() {
    static RU := 0x0419
    static EN := 0x0409
    
    ; Получаем элемент, который реально держит фокус (поле ввода в диалоге сохранения и т.д.)
    focusHwnd := ControlGetFocus("A")
    targetHwnd := focusHwnd ? focusHwnd : WinActive("A")
    
    if !targetHwnd
        return

    threadId := DllCall("GetWindowThreadProcessId", "Ptr", targetHwnd, "UInt*", 0, "UInt")
    hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "UPtr")
    langId := hkl & 0xFFFF
    
    target := (langId = RU) ? EN : RU
    targetHKL := (target << 16) | target
    
    ; Отправляем запрос на смену раскладки конкретному элементу в фокусе
    DllCall("PostMessage", "Ptr", targetHwnd, "UInt", 0x50, "Ptr", 1, "Ptr", targetHKL)
}