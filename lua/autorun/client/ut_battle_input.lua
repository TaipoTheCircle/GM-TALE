-- ФАЙЛ: ut_battle_input.lua (ПОЛНЫЙ С ИСПРАВЛЕННОЙ НАВИГАЦИЕЙ)
if CLIENT then
    print("[UNDERTALE] Загрузка модуля ввода с навигацией по списку...")
    
    if not UT_BATTLE_CORE then
        print("[UNDERTALE] ОШИБКА: Ядро боевой системы не загружено!")
        return
    end
    
    UT_BATTLE_INPUT = UT_BATTLE_INPUT or {}
    
    -- ОБРАБОТКА НАВИГАЦИИ ПО СЕТКЕ ВРАГОВ (СТАРАЯ ВЕРСИЯ - НЕ ИСПОЛЬЗУЕМ)
    UT_BATTLE_INPUT.HandleGridNavigation = function(key)
        return false -- Отключаем старую навигацию по сетке
    end
    
    -- ОБРАБОТКА НАВИГАЦИИ МЕНЮ (ОБНОВЛЕННАЯ)
    UT_BATTLE_INPUT.HandleMenuNavigation = function(key)
        local currentTime = CurTime()
        if UT_BATTLE_CORE.keyCooldown > currentTime then return false end
        UT_BATTLE_CORE.keyCooldown = currentTime + 0.15
        
        if UT_BATTLE_CORE.battleMode == "MENU" then
            if key == KEY_LEFT then
                UT_BATTLE_CORE.selectedButton = UT_BATTLE_CORE.selectedButton - 1
                if UT_BATTLE_CORE.selectedButton < 1 then 
                    UT_BATTLE_CORE.selectedButton = #UT_BATTLE_CORE.buttons 
                end
                print("[UNDERTALE] Кнопка влево: " .. UT_BATTLE_CORE.selectedButton)
                return true
            elseif key == KEY_RIGHT then
                UT_BATTLE_CORE.selectedButton = UT_BATTLE_CORE.selectedButton + 1
                if UT_BATTLE_CORE.selectedButton > #UT_BATTLE_CORE.buttons then 
                    UT_BATTLE_CORE.selectedButton = 1 
                end
                print("[UNDERTALE] Кнопка вправо: " .. UT_BATTLE_CORE.selectedButton)
                return true
            end
            
        elseif UT_BATTLE_CORE.battleMode == "FIGHT" and not UT_BATTLE_CORE.attackInProgress then
            -- ТОЛЬКО ВЕРТИКАЛЬНАЯ НАВИГАЦИЯ (как в Undertale)
            if key == KEY_UP then
                -- Ищем предыдущего живого врага
                local newTarget = UT_BATTLE_CORE.selectedTarget - 1
                if newTarget < 1 then newTarget = #UT_BATTLE_CORE.currentTargets end
                
                -- Пропускаем мертвых врагов
                for i = 1, #UT_BATTLE_CORE.currentTargets do
                    local enemy = UT_BATTLE_CORE.currentTargets[newTarget]
                    if enemy and enemy.hp > 0 then
                        UT_BATTLE_CORE.selectedTarget = newTarget
                        return true
                    end
                    newTarget = newTarget - 1
                    if newTarget < 1 then newTarget = #UT_BATTLE_CORE.currentTargets end
                end
                
            elseif key == KEY_DOWN then
                -- Ищем следующего живого врага
                local newTarget = UT_BATTLE_CORE.selectedTarget + 1
                if newTarget > #UT_BATTLE_CORE.currentTargets then newTarget = 1 end
                
                -- Пропускаем мертвых врагов
                for i = 1, #UT_BATTLE_CORE.currentTargets do
                    local enemy = UT_BATTLE_CORE.currentTargets[newTarget]
                    if enemy and enemy.hp > 0 then
                        UT_BATTLE_CORE.selectedTarget = newTarget
                        return true
                    end
                    newTarget = newTarget + 1
                    if newTarget > #UT_BATTLE_CORE.currentTargets then newTarget = 1 end
                end
            end
        end
        
        return false
    end
    
    -- ОБРАБОТКА НАЖАТИЙ КЛАВИШ
    UT_BATTLE_INPUT.HandleKeyPress = function(key)
        print("[UNDERTALE] Обработка клавиши: " .. key)
        
        -- ESC - выход/отмена
        if key == KEY_ESCAPE then
            if UT_BATTLE_CORE.battleMode == "MENU" then
                UT_BATTLE_CORE.StopAllSystems()
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                return true
            elseif UT_BATTLE_CORE.battleMode == "ATTACK" then
                UT_BATTLE_CORE.PlaySoundSafe("undertale-miss.mp3")
                return true
            elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
                UT_BATTLE_CORE.battleMode = "MENU"
                if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then
                    UT_HEART_CORE.StopHeartPhase()
                end
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                return true
            else
                UT_BATTLE_CORE.battleMode = "MENU"
                if UT_BATTLE_CORE.UpdateButtonImages then
                    UT_BATTLE_CORE.UpdateButtonImages()
                end
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                return true
            end
        end
        
        -- Навигация
        if UT_BATTLE_INPUT.HandleMenuNavigation(key) then
            if UT_BATTLE_CORE.battleMode == "MENU" then
                if UT_BATTLE_CORE.UpdateButtonImages then
                    UT_BATTLE_CORE.UpdateButtonImages()
                end
            end
            UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
            return true
        end
        
        -- ENTER или SPACE - действие
        if key == KEY_ENTER or key == KEY_SPACE then
            print("[UNDERTALE] Действие в режиме: " .. UT_BATTLE_CORE.battleMode)
            
            if UT_BATTLE_CORE.battleMode == "MENU" then
                local action = UT_BATTLE_CORE.buttons[UT_BATTLE_CORE.selectedButton].name
                print("[UNDERTALE] Выбрано действие: "..action)
                
                if action == "FIGHT" then
                    UT_BATTLE_CORE.battleMode = "FIGHT"
                    UT_BATTLE_CORE.selectedTarget = 1
                    
                    -- Находим первого живого врага
                    for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                        if enemy.hp > 0 then
                            UT_BATTLE_CORE.selectedTarget = i
                            break
                        end
                    end
                    
                    if UT_BATTLE_CORE.UpdateButtonImages then
                        UT_BATTLE_CORE.UpdateButtonImages()
                    end
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    
                    chat.AddText(Color(255, 200, 0), "[БОЙ] ", Color(255, 255, 255), 
                        "Выберите цель из списка! (↑ ↓)")
                    
                elseif action == "ACT" then
                    UT_BATTLE_CORE.battleMode = "ACT"
                    UT_BATTLE_CORE.selectedTarget = 1
                    if UT_BATTLE_CORE.UpdateButtonImages then
                        UT_BATTLE_CORE.UpdateButtonImages()
                    end
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    
                elseif action == "ITEM" then
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    chat.AddText(Color(255, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "У вас нет предметов!")
                    
                elseif action == "MERCY" then
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    chat.AddText(Color(255, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Вы предложили пощаду!")
                    
                    timer.Simple(2, function()
                        if IsValid(UT_BATTLE_CORE.battleFrame) then
                            chat.AddText(Color(0, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Бой окончен!")
                            UT_BATTLE_CORE.StopAllSystems()
                        end
                    end)
                end
                return true
                
            elseif UT_BATTLE_CORE.battleMode == "FIGHT" then
                if UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget] then
                    local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
                    
                    if target.hp > 0 then
                        print("[UNDERTALE] Начинаем атаку на цель: "..target.name)
                        
                        -- Сообщение о выбранной цели
                        chat.AddText(Color(255, 200, 0), "[АТАКА] ", Color(255, 255, 255), 
                            "Вы атакуете: "..target.name.." (HP: "..target.hp.."/"..target.maxhp..")")
                        
                        UT_BATTLE_INPUT.StartAttack()
                        UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    else
                        -- Если цель мертва, выбираем следующую живую
                        for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                            if enemy.hp > 0 then
                                UT_BATTLE_CORE.selectedTarget = i
                                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                                chat.AddText(Color(255, 50, 50), "[БОЙ] ", Color(255, 255, 255), 
                                    "Эта цель уже мертва! Выбрана следующая.")
                                break
                            end
                        end
                    end
                end
                return true
                
            elseif UT_BATTLE_CORE.battleMode == "ACT" then
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                chat.AddText(Color(255, 255, 0), "[ДЕЙСТВИЕ] ", Color(255, 255, 255), 
                    "Вы попытались взаимодействовать")
                return true
                
            elseif UT_BATTLE_CORE.battleMode == "ATTACK" then
                return true
                
            elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
                return true
            end
        end
        
        return false
    end
    
    -- НАЧАЛО АТАКИ
    UT_BATTLE_INPUT.StartAttack = function()
        if UT_BATTLE_CORE.attackInProgress then return end
        
        print("[UNDERTALE] Начало атаки")
        
        UT_BATTLE_CORE.attackActive = true
        UT_BATTLE_CORE.attackInProgress = true
        UT_BATTLE_CORE.attackTimer = CurTime()
        UT_BATTLE_CORE.attackBarPos = 0
        UT_BATTLE_CORE.attackSpacePressed = false
        UT_BATTLE_CORE.attackResult = nil
        
        local dialogW = 900
        local zoneWidth = 80
        local zoneStart = (dialogW - zoneWidth) / 2
        local zoneFinish = zoneStart + zoneWidth
        
        UT_BATTLE_CORE.attackHitZone = {
            start = zoneStart,
            finish = zoneFinish,
            center = (zoneStart + zoneFinish) / 2
        }
        
        UT_BATTLE_CORE.battleMode = "ATTACK"
        
        chat.AddText(Color(255, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
            "Нажмите ПРОБЕЛ когда полоска будет в центре!")
    end
    
    -- ЗАПУСК ФАЗЫ СЕРДЦА ПОСЛЕ АТАКИ
    UT_BATTLE_INPUT.StartHeartModeAfterAttack = function()
        print("[UNDERTALE] Запуск фазы сердца после атаки")
        
        -- ПЕРЕДАЕМ ДАННЫЕ ВРАГА
        local enemy_data = nil
        if UT_BATTLE_CORE.currentEnemy and UT_BATTLE_CORE.currentEnemy.data then
            enemy_data = UT_BATTLE_CORE.currentEnemy.data
        end
        
        UT_BATTLE_CORE.battleMode = "HEART_PHASE"
        
        -- ПРИОРИТЕТ: сначала пробуем ПРОСТУЮ систему (которая работает)
        if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Start then
            print("[UNDERTALE] Используем простую систему сердца (UT_HEART_SIMPLE)")
            UT_HEART_SIMPLE.Start(enemy_data)
            
            chat.AddText(Color(255, 0, 255), "[ФАЗА СЕРДЦА] ", Color(255, 255, 255), 
                "Враг контратакует! Используйте стрелки для уклонения!")
                
        elseif UT_HEART_CORE and UT_HEART_CORE.StartHeartPhase then
            print("[UNDERTALE] Используем сложную систему сердца (UT_HEART_CORE)")
            UT_HEART_CORE.StartHeartPhase(enemy_data)
            
            chat.AddText(Color(255, 0, 255), "[ФАЗА СЕРДЦА] ", Color(255, 255, 255), 
                "Враг контратакует! Используйте стрелки для уклонения!")
        else
            print("[UNDERTALE] ОШИБКА: Нет доступных систем сердца!")
            chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                "Не удалось запустить фазу сердца!")
        end
    end
    
    -- ОБРАБОТКА АТАКИ
    UT_BATTLE_INPUT.ProcessAttack = function()
        if not UT_BATTLE_CORE.attackActive or not UT_BATTLE_CORE.attackInProgress then 
            return 
        end
        
        local currentTime = CurTime()
        
        UT_BATTLE_CORE.attackBarPos = UT_BATTLE_CORE.attackBarPos + (UT_BATTLE_CORE.attackBarSpeed * FrameTime())
        
        if UT_BATTLE_CORE.attackBarPos > 900 then
            UT_BATTLE_CORE.attackResult = "miss"
            UT_BATTLE_CORE.attackActive = false
            UT_BATTLE_CORE.attackInProgress = false
            
            UT_BATTLE_CORE.PlaySoundSafe("undertale-slash.mp3")
            chat.AddText(Color(255, 50, 50), "[АТАКА] ", Color(255, 255, 255), 
                "Промах! Вы не успели нажать!")
            
            timer.Simple(1.5, function()
                UT_BATTLE_INPUT.StartHeartModeAfterAttack()
            end)
            
            return
        end
        
        if input.IsKeyDown(KEY_SPACE) then
            if not UT_BATTLE_CORE.attackSpacePressed then
                UT_BATTLE_CORE.attackSpacePressed = true
                
                UT_BATTLE_CORE.attackActive = false
                UT_BATTLE_CORE.attackInProgress = false
                UT_BATTLE_CORE.attackBlinkTimer = CurTime()
                
                local barCenter = UT_BATTLE_CORE.attackBarPos + (UT_BATTLE_CORE.attackBarWidth / 2)
                
                if barCenter >= UT_BATTLE_CORE.attackHitZone.start and barCenter <= UT_BATTLE_CORE.attackHitZone.finish then
                    local distanceFromCenter = math.abs(barCenter - UT_BATTLE_CORE.attackHitZone.center)
                    local zoneWidth = UT_BATTLE_CORE.attackHitZone.finish - UT_BATTLE_CORE.attackHitZone.start
                    local accuracy = 1 - (distanceFromCenter / (zoneWidth / 2))
                    accuracy = math.Clamp(accuracy, 0, 1)
                    
                    if accuracy > 0.9 then
                        UT_BATTLE_CORE.attackResult = "critical"
                        UT_BATTLE_CORE.attackDamage = UT_BATTLE_CORE.attackMaxDamage
                        UT_BATTLE_CORE.PlaySoundSafe("undertale-critical.mp3")
                        chat.AddText(Color(255, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
                            "КРИТИЧЕСКИЙ УРОН! "..UT_BATTLE_CORE.attackDamage.." урона!")
                    else
                        UT_BATTLE_CORE.attackResult = "hit"
                        UT_BATTLE_CORE.attackDamage = math.floor(UT_BATTLE_CORE.attackMaxDamage * accuracy)
                        if UT_BATTLE_CORE.attackDamage < 1 then UT_BATTLE_CORE.attackDamage = 1 end
                        UT_BATTLE_CORE.PlaySoundSafe("undertale-attack-slash-green-screen.mp3")
                        chat.AddText(Color(0, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
                            "Попадание! "..UT_BATTLE_CORE.attackDamage.." урона!")
                    end
                    
                    if UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget] then
                        local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
                        target.hp = math.max(0, target.hp - UT_BATTLE_CORE.attackDamage)
                        
                        if target.hp <= 0 then
                            target.hp = 0
                            target.deathTimer = 0
                            
                            chat.AddText(Color(255, 255, 0), "[БОЙ] ", Color(255, 255, 255), 
                                target.name.." побежден!")
                            
                            -- Запускаем проверку мертвых врагов
                            timer.Create("UT_CheckDeadEnemies", 0.5, 0, function()
                                if UT_BATTLE_CORE and UT_BATTLE_CORE.RemoveDeadEnemies then
                                    UT_BATTLE_CORE.RemoveDeadEnemies()
                                else
                                    timer.Remove("UT_CheckDeadEnemies")
                                end
                            end)
                            
                            -- Автоматически выбираем следующего живого врага
                            timer.Simple(0.5, function()
                                if UT_BATTLE_CORE and UT_BATTLE_CORE.currentTargets then
                                    for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                                        if enemy.hp > 0 then
                                            UT_BATTLE_CORE.selectedTarget = i
                                            print("[UNDERTALE] Автовыбор живого врага: " .. enemy.name)
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                        
                        if target.hp <= 0 then
                            timer.Simple(2, function()
                                if IsValid(UT_BATTLE_CORE.battleFrame) then
                                    UT_BATTLE_CORE.battleMode = "MENU"
                                    UT_BATTLE_CORE.attackResult = nil
                                end
                            end)
                        else
                            timer.Simple(2, function()
                                UT_BATTLE_INPUT.StartHeartModeAfterAttack()
                            end)
                        end
                    end
                else
                    UT_BATTLE_CORE.attackResult = "miss"
                    UT_BATTLE_CORE.attackDamage = 0
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-slash.mp3")
                    chat.AddText(Color(255, 50, 50), "[АТАКА] ", Color(255, 255, 255), 
                        "Промах! Слишком рано или поздно!")
                    
                    timer.Simple(2, function()
                        UT_BATTLE_INPUT.StartHeartModeAfterAttack()
                    end)
                end
            end
        else
            UT_BATTLE_CORE.attackSpacePressed = false
        end
    end
    
    -- ХУК ВВОДА
    UT_BATTLE_INPUT.SetupInputHook = function()
        hook.Add("Think", "UT_AttackThink", function()
            if not UT_BATTLE_CORE.battleActive or not IsValid(UT_BATTLE_CORE.battleFrame) then
                hook.Remove("Think", "UT_AttackThink")
                return
            end
            
            if UT_BATTLE_CORE.attackActive or UT_BATTLE_CORE.battleMode == "ATTACK" then
                UT_BATTLE_INPUT.ProcessAttack()
            elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
                return
            else
                local currentTime = CurTime()
                
                if currentTime - UT_BATTLE_CORE.lastKeyPress > UT_BATTLE_CORE.keyRepeatDelay then
                    local keysToCheck = {
                        {key = KEY_LEFT, pressed = input.IsKeyDown(KEY_LEFT)},
                        {key = KEY_RIGHT, pressed = input.IsKeyDown(KEY_RIGHT)},
                        {key = KEY_UP, pressed = input.IsKeyDown(KEY_UP)},
                        {key = KEY_DOWN, pressed = input.IsKeyDown(KEY_DOWN)}
                    }
                    
                    for _, keyInfo in ipairs(keysToCheck) do
                        if keyInfo.pressed then
                            if UT_BATTLE_INPUT.HandleMenuNavigation(keyInfo.key) then
                                if UT_BATTLE_CORE.battleMode == "MENU" then
                                    if UT_BATTLE_CORE.UpdateButtonImages then
                                        UT_BATTLE_CORE.UpdateButtonImages()
                                    end
                                end
                                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                                UT_BATTLE_CORE.lastKeyPress = currentTime
                                UT_BATTLE_CORE.keyRepeatDelay = 0.1
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
    
    print("[UNDERTALE] Модуль ввода с навигацией по списку загружен")
end