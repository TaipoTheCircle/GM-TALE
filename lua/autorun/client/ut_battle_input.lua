-- ФАЙЛ: ut_battle_input.lua (UNDERTALE СТИЛЬ - БЕЗ ЛИШНИХ НАДПИСЕЙ)
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка модуля ввода с системой атаки как в Undertale...")
    
    if not UT_BATTLE_CORE then
        print("[UNDERTALE] ОШИБКА: Ядро боевой системы не загружено!")
        return
    end
    
    UT_BATTLE_INPUT = UT_BATTLE_INPUT or {}
    
    -- НАСТРОЙКИ АТАКИ
    UT_BATTLE_INPUT.attackSettings = {
        barSpeed = 400,
        barWidth = 40,
        zoneWidth = 100,
        panelWidth = 900,
        maxDamage = 15,
        minDamage = 1,
    }
    
    -- ФЛАГИ ДЛЯ АТАКИ
    UT_BATTLE_INPUT.waitingForAttackInput = false
    UT_BATTLE_INPUT.attackProcessed = false
    UT_BATTLE_INPUT.lastSpacePress = false
    
    -- ОБРАБОТКА НАВИГАЦИИ
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
                return true
            elseif key == KEY_RIGHT then
                UT_BATTLE_CORE.selectedButton = UT_BATTLE_CORE.selectedButton + 1
                if UT_BATTLE_CORE.selectedButton > #UT_BATTLE_CORE.buttons then 
                    UT_BATTLE_CORE.selectedButton = 1 
                end
                return true
            end
            
        elseif UT_BATTLE_CORE.battleMode == "FIGHT" and not UT_BATTLE_CORE.attackInProgress then
            if key == KEY_UP then
                local newTarget = UT_BATTLE_CORE.selectedTarget - 1
                if newTarget < 1 then newTarget = #UT_BATTLE_CORE.currentTargets end
                
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
                local newTarget = UT_BATTLE_CORE.selectedTarget + 1
                if newTarget > #UT_BATTLE_CORE.currentTargets then newTarget = 1 end
                
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
    
    -- РАСЧЕТ УРОНА
    UT_BATTLE_INPUT.CalculateDamage = function(distanceFromCenter)
        local settings = UT_BATTLE_INPUT.attackSettings
        local accuracy = 1 - (distanceFromCenter ^ 1.5)
        accuracy = math.Clamp(accuracy, 0, 1)
        
        local damage = settings.minDamage + (settings.maxDamage - settings.minDamage) * accuracy
        damage = math.floor(damage)
        
        if distanceFromCenter < 0.05 then
            return settings.maxDamage, "perfect"
        end
        
        return damage, "hit"
    end
    
    -- НАЧАЛО АТАКИ
    UT_BATTLE_INPUT.StartAttack = function()
        if UT_BATTLE_CORE.attackInProgress then return end
        
        print("[UNDERTALE] Начало атаки")
        
        local settings = UT_BATTLE_INPUT.attackSettings
        
        UT_BATTLE_INPUT.waitingForAttackInput = true
        UT_BATTLE_INPUT.attackProcessed = false
        UT_BATTLE_INPUT.lastSpacePress = false
        
        UT_BATTLE_CORE.attackActive = true
        UT_BATTLE_CORE.attackInProgress = true
        UT_BATTLE_CORE.attackTimer = CurTime()
        UT_BATTLE_CORE.attackBarPos = 0
        UT_BATTLE_CORE.attackBarSpeed = settings.barSpeed
        UT_BATTLE_CORE.attackResult = nil
        
        -- Зона попадания (невидимая, используется только для расчета)
        local zoneStart = (settings.panelWidth - settings.zoneWidth) / 2
        local zoneFinish = zoneStart + settings.zoneWidth
        
        UT_BATTLE_CORE.attackHitZone = {
            start = zoneStart,
            finish = zoneFinish,
            center = (zoneStart + zoneFinish) / 2,
            width = settings.zoneWidth
        }
        
        UT_BATTLE_CORE.battleMode = "ATTACK"
        
        UT_BATTLE_INPUT.UpdateAttackPanelPaint()
        
        -- Только одно короткое сообщение в чат
        chat.AddText(Color(255, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
            "Нажмите ПРОБЕЛ!")
    end
    
    -- ОТРИСОВКА ПАНЕЛИ АТАКИ (чистый Undertale стиль)
    UT_BATTLE_INPUT.UpdateAttackPanelPaint = function()
        if not IsValid(UT_BATTLE_CORE.dialogPanel) then return end
        
        local settings = UT_BATTLE_INPUT.attackSettings
        local sniperMaterial = Material("undertale/attack_sniper.png")
        local hasSniperTexture = sniperMaterial and not sniperMaterial:IsError()
        
        UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
            -- ФОН с текстурой
            if hasSniperTexture then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(sniperMaterial)
                surface.DrawTexturedRect(0, 0, w, h)
            else
                -- Черный фон если текстуры нет
                surface.SetDrawColor(0, 0, 0, 230)
                surface.DrawRect(0, 0, w, h)
            end
            
            -- ТОЛЬКО ДВИЖУЩАЯСЯ ПОЛОСКА (никаких зон, никаких надписей)
            if UT_BATTLE_CORE.attackActive then
                -- Белая полоска
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawRect(
                    UT_BATTLE_CORE.attackBarPos, 
                    h/2 - 12, 
                    settings.barWidth, 
                    24
                )
                
                -- Красная линия посередине полоски
                surface.SetDrawColor(255, 0, 0, 255)
                surface.DrawLine(
                    UT_BATTLE_CORE.attackBarPos + settings.barWidth/2, 
                    h/2 - 20,
                    UT_BATTLE_CORE.attackBarPos + settings.barWidth/2, 
                    h/2 + 20
                )
            end
            
            -- РЕЗУЛЬТАТ АТАКИ (только текст результата, без лишних подсказок)
            if UT_BATTLE_CORE.attackResult then
                local resultText = ""
                local resultColor = Color(255, 255, 255)
                local resultY = h/2
                
                if UT_BATTLE_CORE.attackResult == "perfect" then
                    resultText = "PERFECT!"
                    resultColor = Color(255, 255, 0)
                    resultY = h/2 - 40
                elseif UT_BATTLE_CORE.attackResult == "hit" then
                    resultText = tostring(UT_BATTLE_CORE.attackDamage) .. "!"
                    resultColor = Color(255, 255, 255)
                    resultY = h/2 - 40
                elseif UT_BATTLE_CORE.attackResult == "miss" then
                    resultText = "MISS!"
                    resultColor = Color(255, 50, 50)
                    resultY = h/2 - 40
                end
                
                draw.SimpleText(resultText, "UT_Attack", w/2, resultY, 
                    resultColor, TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- ВЫПОЛНЕНИЕ АТАКИ
    UT_BATTLE_INPUT.ExecuteAttack = function()
        if not UT_BATTLE_INPUT.waitingForAttackInput then return false end
        if UT_BATTLE_INPUT.attackProcessed then return false end
        
        local settings = UT_BATTLE_INPUT.attackSettings
        
        UT_BATTLE_INPUT.attackProcessed = true
        UT_BATTLE_INPUT.waitingForAttackInput = false
        UT_BATTLE_CORE.attackActive = false
        UT_BATTLE_CORE.attackInProgress = false
        UT_BATTLE_CORE.attackBlinkTimer = CurTime()
        
        local barCenter = UT_BATTLE_CORE.attackBarPos + (settings.barWidth / 2)
        local zone = UT_BATTLE_CORE.attackHitZone
        
        local damage = settings.minDamage
        local resultType = "hit"
        
        -- Проверяем попадание в зону (невидимую)
        if barCenter >= zone.start and barCenter <= zone.finish then
            local distanceFromCenter = math.abs(barCenter - zone.center) / (zone.width / 2)
            distanceFromCenter = math.Clamp(distanceFromCenter, 0, 1)
            damage, resultType = UT_BATTLE_INPUT.CalculateDamage(distanceFromCenter)
        else
            damage = settings.minDamage
            resultType = "hit"
        end
        
        UT_BATTLE_CORE.attackDamage = damage
        UT_BATTLE_CORE.attackResult = resultType
        
        -- Звуки
        if resultType == "perfect" then
            UT_BATTLE_CORE.PlaySoundSafe("undertale-critical.mp3")
            chat.AddText(Color(255, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
                "PERFECT! " .. damage .. " урона!")
        else
            UT_BATTLE_CORE.PlaySoundSafe("undertale-attack-slash-green-screen.mp3")
            chat.AddText(Color(0, 255, 0), "[АТАКА] ", Color(255, 255, 255), 
                "Попадание! " .. damage .. " урона!")
        end
        
        -- Нанесение урона
        if UT_BATTLE_CORE.currentTargets and UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget] then
            local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            target.hp = math.max(0, target.hp - damage)
            
            if target.hp <= 0 then
                target.hp = 0
                chat.AddText(Color(255, 255, 0), "[БОЙ] ", Color(255, 255, 255), 
                    target.name .. " побежден!")
                
                timer.Simple(0.3, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.currentTargets then
                        for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                            if enemy.hp > 0 then
                                UT_BATTLE_CORE.selectedTarget = i
                                break
                            end
                        end
                    end
                end)
            end
        end
        
        timer.Simple(1.5, function()
            UT_BATTLE_INPUT.StartHeartModeAfterAttack()
        end)
        
        return true
    end
    
    -- ПРОПУСК АТАКИ
    UT_BATTLE_INPUT.MissAttack = function()
        if not UT_BATTLE_INPUT.waitingForAttackInput then return false end
        if UT_BATTLE_INPUT.attackProcessed then return false end
        
        UT_BATTLE_INPUT.attackProcessed = true
        UT_BATTLE_INPUT.waitingForAttackInput = false
        UT_BATTLE_CORE.attackActive = false
        UT_BATTLE_CORE.attackInProgress = false
        
        UT_BATTLE_CORE.attackResult = "miss"
        UT_BATTLE_CORE.attackDamage = 0
        
        UT_BATTLE_CORE.PlaySoundSafe("undertale-slash.mp3")
        chat.AddText(Color(255, 50, 50), "[АТАКА] ", Color(255, 255, 255), 
            "Промах!")
        
        timer.Simple(1.5, function()
            UT_BATTLE_INPUT.StartHeartModeAfterAttack()
        end)
        
        return true
    end
    
    -- ДВИЖЕНИЕ ПОЛОСКИ
    UT_BATTLE_INPUT.UpdateAttackBar = function()
        if not UT_BATTLE_INPUT.waitingForAttackInput then return end
        
        local settings = UT_BATTLE_INPUT.attackSettings
        local dt = FrameTime()
        
        UT_BATTLE_CORE.attackBarPos = UT_BATTLE_CORE.attackBarPos + (UT_BATTLE_CORE.attackBarSpeed * dt)
        
        if UT_BATTLE_CORE.attackBarPos + settings.barWidth > settings.panelWidth then
            UT_BATTLE_CORE.attackBarPos = settings.panelWidth - settings.barWidth
            UT_BATTLE_CORE.attackBarSpeed = -settings.barSpeed
        elseif UT_BATTLE_CORE.attackBarPos < 0 then
            UT_BATTLE_CORE.attackBarPos = 0
            UT_BATTLE_CORE.attackBarSpeed = settings.barSpeed
        end
    end
    
    -- ПРОВЕРКА НАЖАТИЙ
    UT_BATTLE_INPUT.CheckKeyPresses = function()
        if not UT_BATTLE_INPUT.waitingForAttackInput then return end
        if UT_BATTLE_INPUT.attackProcessed then return end
        
        if input.IsKeyDown(KEY_SPACE) then
            if not UT_BATTLE_INPUT.lastSpacePress then
                UT_BATTLE_INPUT.lastSpacePress = true
                UT_BATTLE_INPUT.ExecuteAttack()
            end
        else
            UT_BATTLE_INPUT.lastSpacePress = false
        end
    end
    
    -- ПРОВЕРКА ТАЙМАУТА
    UT_BATTLE_INPUT.CheckAttackTimeout = function()
        if not UT_BATTLE_INPUT.waitingForAttackInput then return end
        if UT_BATTLE_INPUT.attackProcessed then return end
        
        if CurTime() - UT_BATTLE_CORE.attackTimer > 5 then
            UT_BATTLE_INPUT.MissAttack()
        end
    end
    
    -- ЗАПУСК ФАЗЫ СЕРДЦА
    UT_BATTLE_INPUT.StartHeartModeAfterAttack = function()
        print("[UNDERTALE] Запуск фазы сердца после атаки")
        
        local enemy_data = nil
        if UT_BATTLE_CORE.currentEnemy and UT_BATTLE_CORE.currentEnemy.data then
            enemy_data = UT_BATTLE_CORE.currentEnemy.data
        end
        
        UT_BATTLE_CORE.battleMode = "HEART_PHASE"
        
        if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Start then
            UT_HEART_SIMPLE.Start(enemy_data)
            chat.AddText(Color(255, 0, 255), "[ФАЗА СЕРДЦА] ", Color(255, 255, 255), 
                "Уклоняйтесь! (←↑↓→)")
        elseif UT_HEART_CORE and UT_HEART_CORE.StartHeartPhase then
            UT_HEART_CORE.StartHeartPhase(enemy_data)
            chat.AddText(Color(255, 0, 255), "[ФАЗА СЕРДЦА] ", Color(255, 255, 255), 
                "Уклоняйтесь! (←↑↓→)")
        else
            print("[UNDERTALE] ОШИБКА: Нет доступных систем сердца!")
        end
    end
    
    -- ОБРАБОТКА НАЖАТИЙ КЛАВИШ МЕНЮ
    UT_BATTLE_INPUT.HandleKeyPress = function(key)
        if UT_BATTLE_INPUT.waitingForAttackInput then return false end
        
        if key == KEY_ESCAPE then
            if UT_BATTLE_CORE.battleMode == "MENU" then
                UT_BATTLE_CORE.StopAllSystems()
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                return true
            elseif UT_BATTLE_CORE.battleMode == "HEART_PHASE" then
                UT_BATTLE_CORE.battleMode = "MENU"
                if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then
                    UT_HEART_CORE.StopHeartPhase()
                end
                if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Stop then
                    UT_HEART_SIMPLE.Stop()
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
        
        if UT_BATTLE_INPUT.HandleMenuNavigation(key) then
            if UT_BATTLE_CORE.battleMode == "MENU" then
                if UT_BATTLE_CORE.UpdateButtonImages then
                    UT_BATTLE_CORE.UpdateButtonImages()
                end
            end
            UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
            return true
        end
        
        if key == KEY_ENTER then
            if UT_BATTLE_CORE.battleMode == "MENU" then
                local action = UT_BATTLE_CORE.buttons[UT_BATTLE_CORE.selectedButton].name
                
                if action == "FIGHT" then
                    UT_BATTLE_CORE.battleMode = "FIGHT"
                    UT_BATTLE_CORE.selectedTarget = 1
                    
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
                    
                    if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                        UT_BATTLE_HUD.UpdateDialogPanel()
                    end
                    
                    chat.AddText(Color(255, 200, 0), "[БОЙ] ", Color(255, 255, 255), 
                        "Выберите цель (↑ ↓)")
                    
                elseif action == "ACT" then
                    UT_BATTLE_CORE.battleMode = "ACT"
                    UT_BATTLE_CORE.selectedTarget = 1
                    if UT_BATTLE_CORE.UpdateButtonImages then
                        UT_BATTLE_CORE.UpdateButtonImages()
                    end
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    
                elseif action == "ITEM" then
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    chat.AddText(Color(255, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Нет предметов!")
                    
                elseif action == "MERCY" then
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    chat.AddText(Color(255, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), "Пощада!")
                    
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
                        UT_BATTLE_INPUT.StartAttack()
                        UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                    else
                        for i, enemy in ipairs(UT_BATTLE_CORE.currentTargets) do
                            if enemy.hp > 0 then
                                UT_BATTLE_CORE.selectedTarget = i
                                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                                chat.AddText(Color(255, 50, 50), "[БОЙ] ", Color(255, 255, 255), 
                                    "Цель мертва! Выбрана следующая.")
                                break
                            end
                        end
                    end
                end
                return true
                
            elseif UT_BATTLE_CORE.battleMode == "ACT" then
                UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                chat.AddText(Color(255, 255, 0), "[ДЕЙСТВИЕ] ", Color(255, 255, 255), 
                    "Ничего не произошло")
                return true
            end
        end
        
        return false
    end
    
    -- ОСНОВНОЙ ХУК
    UT_BATTLE_INPUT.SetupInputHook = function()
        hook.Add("Think", "UT_AttackThink", function()
            if not UT_BATTLE_CORE.battleActive or not IsValid(UT_BATTLE_CORE.battleFrame) then
                hook.Remove("Think", "UT_AttackThink")
                UT_BATTLE_INPUT.waitingForAttackInput = false
                return
            end
            
            if UT_BATTLE_INPUT.waitingForAttackInput then
                UT_BATTLE_INPUT.UpdateAttackBar()
                UT_BATTLE_INPUT.CheckKeyPresses()
                UT_BATTLE_INPUT.CheckAttackTimeout()
            end
        end)
        
        if IsValid(UT_BATTLE_CORE.battleFrame) then
            UT_BATTLE_CORE.battleFrame.OnKeyCodePressed = function(self, key)
                UT_BATTLE_INPUT.HandleKeyPress(key)
            end
        end
    end
    
    print("[UNDERTALE] Модуль ввода загружен (Undertale стиль)")
end