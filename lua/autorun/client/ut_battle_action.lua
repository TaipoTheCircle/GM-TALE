-- ФАЙЛ: ut_battle_action.lua
if CLIENT then
    print("[UNDERTALE] Загрузка системы действий...")
    
    UT_BATTLE_ACTION = UT_BATTLE_ACTION or {}
    
    -- Переменные для MERCY (пощады)
    UT_BATTLE_ACTION.mercy_level = 0
    UT_BATTLE_ACTION.mercy_max = 100
    UT_BATTLE_ACTION.can_spare = false
    
    -- FIGHT: Начало атаки (как в Undertale)
    function UT_BATTLE_ACTION.StartFight()
        if not UT_BATTLE_CORE or not UT_BATTLE_CORE.currentTargets then 
            return 
        end
        
        local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
        if not target or target.hp <= 0 then
            chat.AddText(Color(255, 50, 50), "[FIGHT] ", Color(255, 255, 255), 
                "Нет цели для атаки.")
            return
        end
        
        -- Запускаем анимацию атаки (полоска) через UT_BATTLE_INPUT
        if UT_BATTLE_INPUT and UT_BATTLE_INPUT.StartAttack then
            UT_BATTLE_INPUT.StartAttack()
        else
            print("[UNDERTALE] UT_BATTLE_INPUT.StartAttack не найден!")
        end
    end
    
    -- Нанесение урона (с расчетом как в Undertale)
    function UT_BATTLE_ACTION.DealDamage(target, damage, is_critical)
        if not target or target.hp <= 0 then return end
        
        -- Расчет урона с учетом защиты врага
        local enemy_data = UT_ENEMY_DATA.Get(target.class)
        local defense = enemy_data and enemy_data.defense or 2
        
        -- Формула урона
        local final_damage = math.max(1, damage - defense)
        if is_critical then
            final_damage = final_damage * 2
        end
        
        target.hp = math.max(0, target.hp - final_damage)
        
        -- ===== ПОЛУЧАЕМ ПОЗИЦИЮ ВРАГА =====
        -- Используем функцию из UT_BATTLE_HUD для получения позиции
        local enemyX, enemyY, enemyWidth, enemyHeight
        
        if UT_BATTLE_HUD and UT_BATTLE_HUD.GetEnemyPosition then
            enemyX, enemyY, enemyWidth, enemyHeight = UT_BATTLE_HUD.GetEnemyPosition(target)
        else
            -- Запасной вариант: центр экрана
            enemyWidth = 220
            enemyHeight = 270
            enemyX = ScrW()/2 - enemyWidth/2
            enemyY = ScrH() * 0.2
        end
        
        -- Запускаем эффект удара
        if UT_DAMAGE_EFFECT then
            UT_DAMAGE_EFFECT.AddFlashEffect(enemyX, enemyY, enemyWidth, enemyHeight, is_critical)
            if is_critical then
                UT_DAMAGE_EFFECT.AddHitEffect(enemyX, enemyY, enemyWidth, enemyHeight, is_critical)
            end
        end
        
        -- Тряска экрана при попадании
        if UT_BATTLE_HUD and UT_BATTLE_HUD.ScreenShake then
            UT_BATTLE_HUD.ScreenShake(is_critical and 8 or 4, 0.2)
        end
        
        -- Показываем урон
        if UT_BATTLE_HUD and UT_BATTLE_HUD.ShowDamageNumber then
            UT_BATTLE_HUD.ShowDamageNumber(final_damage, is_critical)
        end
        
        -- Звуки
        if is_critical then
            surface.PlaySound("undertale-critical.mp3")
        else
            surface.PlaySound("undertale-attack-slash-green-screen.mp3")
        end
        
        chat.AddText(Color(255, 255, 0), "[УРОН] ", Color(255, 255, 255), 
            final_damage .. " урона по " .. target.name .. "!")
        
        -- Проверка на победу
        if target.hp <= 0 then
            UT_BATTLE_ACTION.OnEnemyDefeated(target)
        else
            -- Враг контратакует (фаза сердца)
            timer.Simple(1.5, function()
                UT_BATTLE_ACTION.StartEnemyTurn(target)
            end)
        end
    end
    
    -- Враг контратакует
    -- Враг контратакует
    function UT_BATTLE_ACTION.StartEnemyTurn(enemy)
        chat.AddText(Color(255, 100, 100), "[АТАКА ВРАГА] ", Color(255, 255, 255), 
            "* " .. (enemy.name or "Враг") .. " атакует!")
        
        -- Получаем цвет сердца для врага
        local enemy_data = UT_ENEMY_DATA.Get(enemy.class)
        local heartColor = enemy_data and enemy_data.heart_color or "RED"
        
        -- Запускаем фазу сердца с нужным цветом
        if UT_HEART_SYSTEM and UT_HEART_SYSTEM.StartHeartPhase then
            -- Определяем границы для сердца (в зависимости от текущего боя)
            local bounds
            if UT_BATTLE_CORE.dialogPanel and IsValid(UT_BATTLE_CORE.dialogPanel) then
                local panel = UT_BATTLE_CORE.dialogPanel
                local x, y = panel:GetPos()
                local w, h = panel:GetSize()
                bounds = {
                    left = x + 30,
                    right = x + w - 30,
                    top = y + 30,
                    bottom = y + h - 30
                }
            else
                bounds = {
                    left = ScrW()/2 - 400,
                    right = ScrW()/2 + 400,
                    top = ScrH()/2 - 100,
                    bottom = ScrH()/2 + 100
                }
            end
            
            UT_HEART_SYSTEM.StartHeartPhase(heartColor, bounds, 
                function(damage)
                    -- Получение урона
                    UT_BATTLE_CORE.playerHp = math.max(0, UT_BATTLE_CORE.playerHp - (damage or 2))
                    if UT_BATTLE_CORE.playerHp <= 0 then
                        UT_BATTLE_ACTION.GameOver()
                    end
                end,
                function()
                    -- Завершение фазы сердца
                    UT_BATTLE_CORE.battleMode = "MENU"
                    if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                        UT_BATTLE_HUD.UpdateDialogPanel()
                    end
                end
            )
        else
            -- Fallback на старую систему
            if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Start then
                UT_HEART_SIMPLE.Start(enemy_data)
            elseif UT_HEART_CORE and UT_HEART_CORE.StartHeartPhase then
                UT_HEART_CORE.StartHeartPhase(enemy_data)
            else
                print("[UNDERTALE] Нет системы сердца!")
                UT_BATTLE_CORE.battleMode = "MENU"
                if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                    UT_BATTLE_HUD.UpdateDialogPanel()
                end
            end
        end
    end
    
    -- ACT: Действие (как в Undertale) - С ВЫБОРОМ ЦЕЛИ
    function UT_BATTLE_ACTION.PerformAct(act_index)
        if not UT_BATTLE_CORE or not UT_BATTLE_CORE.currentTargets then 
            return 
        end
        
        -- Если режим MENU, сначала переключаемся в режим выбора цели для ACT
        if UT_BATTLE_CORE.battleMode == "MENU" then
            UT_BATTLE_CORE.battleMode = "ACT_TARGET"
            UT_BATTLE_CORE.selectedTarget = 1
            if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                UT_BATTLE_HUD.UpdateDialogPanel()
            end
            chat.AddText(Color(200, 200, 255), "[ACT] ", Color(255, 255, 255), 
                "Выберите цель (↑ ↓), затем ENTER")
            return
        end
        
        -- Режим выбора цели для ACT
        if UT_BATTLE_CORE.battleMode == "ACT_TARGET" then
            local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
            if not target or target.hp <= 0 then
                chat.AddText(Color(255, 50, 50), "[ACT] ", Color(255, 255, 255), 
                    "Нет цели для действия.")
                return
            end
            
            -- Сохраняем выбранную цель для действия
            UT_BATTLE_CORE.actTarget = UT_BATTLE_CORE.selectedTarget
            
            -- Переключаемся в режим выбора действия
            UT_BATTLE_CORE.battleMode = "ACT"
            UT_BATTLE_CORE.selectedAct = 1
            
            if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                UT_BATTLE_HUD.UpdateDialogPanel()
            end
            
            chat.AddText(Color(200, 200, 255), "[ACT] ", Color(255, 255, 255), 
                "Выберите действие для " .. target.name .. " (↑ ↓), затем ENTER")
            return
        end
        
        -- Выполнение ACT действия над выбранной целью
        if UT_BATTLE_CORE.battleMode == "ACT" then
            local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.actTarget or UT_BATTLE_CORE.selectedTarget]
            if not target or target.hp <= 0 then
                chat.AddText(Color(255, 50, 50), "[ACT] ", Color(255, 255, 255), 
                    "Нет цели для действия.")
                UT_BATTLE_CORE.battleMode = "MENU"
                if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                    UT_BATTLE_HUD.UpdateDialogPanel()
                end
                return
            end
            
            -- Получаем данные о действии
            local enemy_data = UT_ENEMY_DATA.Get(target.class)
            local act = enemy_data and enemy_data.acts and enemy_data.acts[act_index]
            
            -- Проверяем, является ли действие "ПРОВЕРИТЬ" (check)
            local isCheckAction = (act and act.name == "ПРОВЕРИТЬ") or (act and act.info == true)
            
            -- Выполняем ACT действие 
            if UT_ENEMY_DATA and UT_ENEMY_DATA.PerformAct then
                UT_ENEMY_DATA.PerformAct(target.class, act_index, nil, function()
                    if isCheckAction then
                        -- Для ПРОВЕРИТЬ: просто возвращаемся в меню, без атаки врага
                        UT_BATTLE_CORE.battleMode = "MENU"
                        if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                    else
                        -- Для остальных действий: возвращаемся в меню и враг атакует
                        if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                            UT_BATTLE_CORE.battleMode = "MENU"
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                        
                        -- Враг контратакует после ACT
                        timer.Simple(0.5, function()
                            if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                                UT_BATTLE_ACTION.StartEnemyTurn(target)
                            end
                        end)
                    end
                end)
            else
                chat.AddText(Color(255, 255, 0), "[ACT] ", Color(255, 255, 255), "Ничего не произошло.")
                
                if not isCheckAction then
                    timer.Simple(2, function()
                        if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                            UT_BATTLE_ACTION.StartEnemyTurn(target)
                        end
                    end)
                else
                    UT_BATTLE_CORE.battleMode = "MENU"
                    if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                        UT_BATTLE_HUD.UpdateDialogPanel()
                    end
                end
            end
        end
    end
    
    -- MERCY: Пощада
    function UT_BATTLE_ACTION.Spare()
        if not UT_BATTLE_CORE or not UT_BATTLE_CORE.currentTargets then 
            return 
        end
        
        local target = UT_BATTLE_CORE.currentTargets[UT_BATTLE_CORE.selectedTarget]
        if not target or target.hp <= 0 then
            chat.AddText(Color(255, 50, 50), "[MERCY] ", Color(255, 255, 255), 
                "Нет цели для пощады.")
            return
        end
        
        chat.AddText(Color(255, 255, 0), "[MERCY] ", Color(255, 255, 255), 
            "* Вы пощадили " .. target.name .. "!")
        
        -- Удаляем врага
        for i, e in ipairs(UT_BATTLE_CORE.currentTargets) do
            if e == target then
                table.remove(UT_BATTLE_CORE.currentTargets, i)
                break
            end
        end
        
        -- Проверяем, остались ли враги
        if #UT_BATTLE_CORE.currentTargets == 0 then
            timer.Simple(1.5, function()
                if UT_BATTLE_CORE then
                    chat.AddText(Color(0, 255, 0), "[ПОБЕДА] ", Color(255, 255, 255), "Вы победили!")
                    UT_BATTLE_CORE.StopAllSystems()
                end
            end)
        else
            UT_BATTLE_CORE.selectedTarget = 1
            UT_BATTLE_CORE.battleMode = "MENU"
            if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                UT_BATTLE_HUD.UpdateDialogPanel()
            end
        end
    end
    
    -- Враг побежден
    function UT_BATTLE_ACTION.OnEnemyDefeated(enemy, spared)
        local enemy_data = UT_ENEMY_DATA.Get(enemy.class)
        
        -- Анимация смерти/исчезновения
        if UT_BATTLE_HUD and UT_BATTLE_HUD.AnimateEnemyDeath then
            UT_BATTLE_HUD.AnimateEnemyDeath(enemy)
        end
        
        -- Даем опыт и золото если убит (не пощажен)
        if not spared and enemy_data then
            local exp_gained = enemy_data.exp or 0
            local gold_gained = enemy_data.gold or 0
            
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.player_exp = (UT_BATTLE_CORE.player_exp or 0) + exp_gained
                UT_BATTLE_CORE.player_gold = (UT_BATTLE_CORE.player_gold or 0) + gold_gained
            end
            
            -- Показываем сообщение с эффектом печатания
            local victoryMessage = string.format("* Вы победили! +%d XP, +%d золота!", exp_gained, gold_gained)
            if UT_TYPING and UT_TYPING.ShowTypingMessage then
                UT_TYPING.ShowTypingMessage(victoryMessage, 3)
            else
                chat.AddText(Color(0, 255, 0), "[ПОБЕДА] ", Color(255, 255, 255), victoryMessage)
            end
        end
        
        -- Удаляем врага из списка
        for i, e in ipairs(UT_BATTLE_CORE.currentTargets) do
            if e == enemy then
                table.remove(UT_BATTLE_CORE.currentTargets, i)
                break
            end
        end
        
        -- Проверяем, остались ли враги
        if #UT_BATTLE_CORE.currentTargets == 0 then
            UT_BATTLE_ACTION.EndBattle(true)
        else
            -- Выбираем следующего живого врага
            for i, e in ipairs(UT_BATTLE_CORE.currentTargets) do
                if e.hp > 0 then
                    UT_BATTLE_CORE.selectedTarget = i
                    break
                end
            end
            
            UT_BATTLE_CORE.battleMode = "MENU"
            if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                UT_BATTLE_HUD.UpdateDialogPanel()
            end
        end
    end
    
    -- Завершение боя (все враги побеждены)
    function UT_BATTLE_ACTION.EndBattle(victory)
        if victory then
            local total_exp = UT_BATTLE_CORE.player_exp or 0
            local total_gold = UT_BATTLE_CORE.player_gold or 0
            
            local finalMessage = string.format("* ПОБЕДА!\n* Получено всего: %d XP, %d золота", total_exp, total_gold)
            
            if UT_TYPING and UT_TYPING.ShowTypingMessage then
                UT_TYPING.ShowTypingMessage(finalMessage, 4, function()
                    -- После показа сообщения закрываем бой
                    timer.Simple(0.5, function()
                        if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
                            UT_BATTLE_CORE.StopAllSystems()
                        end
                    end)
                end)
            else
                chat.AddText(Color(0, 255, 0), "[ПОБЕДА] ", Color(255, 255, 255), finalMessage)
                timer.Simple(2, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
                        UT_BATTLE_CORE.StopAllSystems()
                    end
                end)
            end
        else
            if UT_TYPING and UT_TYPING.ShowTypingMessage then
                UT_TYPING.ShowTypingMessage("* Поражение...\n* Попробуйте снова!", 3, function()
                    timer.Simple(0.5, function()
                        if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
                            UT_BATTLE_CORE.StopAllSystems()
                        end
                    end)
                end)
            else
                chat.AddText(Color(255, 0, 0), "[ПОРАЖЕНИЕ] ", Color(255, 255, 255), "Вы проиграли...")
                timer.Simple(2, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
                        UT_BATTLE_CORE.StopAllSystems()
                    end
                end)
            end
        end
        
        -- Сброс шкалы пощады
        UT_BATTLE_ACTION.mercy_level = 0
        UT_BATTLE_ACTION.can_spare = false
    end
    
    -- Game Over
    function UT_BATTLE_ACTION.GameOver()
        chat.AddText(Color(255, 0, 0), "[GAME OVER] ", Color(255, 255, 255), "Game Over...")
        
        timer.Simple(3, function()
            if UT_BATTLE_CORE then
                UT_BATTLE_CORE.StopAllSystems()
            end
        end)
    end
    
    print("[UNDERTALE] Система действий загружена")
end