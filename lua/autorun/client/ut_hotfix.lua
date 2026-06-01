-- ФАЙЛ: ut_hotfix.lua (ВРЕМЕННЫЙ ХОТФИКС)
if CLIENT then
    print("[UNDERTALE] Применение хотфикса для FIGHT...")
    
    -- Переопределяем HandleKeyPress для FIGHT
    local oldHandleKeyPress = UT_BATTLE_INPUT.HandleKeyPress
    
    UT_BATTLE_INPUT.HandleKeyPress = function(key)
        if key == KEY_ENTER and UT_BATTLE_CORE.battleMode == "MENU" then
            local action = UT_BATTLE_CORE.buttons[UT_BATTLE_CORE.selectedButton].name
            if action == "FIGHT" then
                print("[UNDERTALE] Хотфикс: FIGHT нажат!")
                
                -- Прямой запуск атаки
                if UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets > 0 then
                    UT_BATTLE_CORE.battleMode = "FIGHT"
                    UT_BATTLE_CORE.selectedTarget = 1
                    
                    if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                        UT_BATTLE_HUD.UpdateDialogPanel()
                    end
                    
                    chat.AddText(Color(255, 200, 0), "[FIGHT] ", Color(255, 255, 255), 
                        "Выберите цель (↑ ↓), затем ENTER")
                end
                return true
            end
        end
        
        -- Для режима FIGHT (выбор цели)
        if key == KEY_ENTER and UT_BATTLE_CORE.battleMode == "FIGHT" then
            local target = UT_BATTLE_CORE.currentTargets and UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            if target and target.hp > 0 then
                print("[UNDERTALE] Хотфикс: Атака по цели " .. target.name)
                -- Запускаем атаку напрямую
                if UT_BATTLE_INPUT and UT_BATTLE_INPUT.StartAttack then
                    UT_BATTLE_INPUT.StartAttack()
                end
                return true
            end
        end
        
        -- Вызов оригинальной функции для остальных клавиш
        if oldHandleKeyPress then
            return oldHandleKeyPress(key)
        end
        return false
    end
    
    print("[UNDERTALE] Хотфикс применен! FIGHT должен работать.")
end