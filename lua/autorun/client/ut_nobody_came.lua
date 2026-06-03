-- ФАЙЛ: ut_nobody_came.lua
-- ЭФФЕКТ "НО НИКТО НЕ ПРИШЁЛ"
if CLIENT then
    print("[UNDERTALE] Загрузка эффекта 'Но никто не пришёл'...")
    
    UT_NOBODY_CAME = UT_NOBODY_CAME or {}
    
    function UT_NOBODY_CAME.Start()
        print("[UNDERTALE] Запуск эффекта 'Но никто не пришёл'")
        
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_CORE не найден!")
            return
        end
        
        -- Останавливаем текущий бой если есть
        if UT_BATTLE_CORE.battleActive then
            UT_BATTLE_CORE.StopAllSystems()
            timer.Simple(0.2, function()
                UT_NOBODY_CAME.Start()
            end)
            return
        end
        
        -- ОЧИЩАЕМ ВСЕХ ВРАГОВ!
        UT_BATTLE_CORE.currentTargets = {}
        UT_BATTLE_CORE.currentEnemy = nil
        
        -- Устанавливаем флаг, что это пустой бой
        UT_BATTLE_CORE.nobodyCame = true
        
        -- СОЗДАЁМ БОЕВОЕ МЕНЮ (но без врагов)
        if not UT_BATTLE_HUD then
            print("[UNDERTALE] ОШИБКА: UT_BATTLE_HUD не найден!")
            return
        end
        
        -- Временно подменяем функцию отрисовки врагов
        local oldDrawEnemies = UT_BATTLE_HUD.DrawEnemiesOnGrid
        UT_BATTLE_HUD.DrawEnemiesOnGrid = function() 
            -- Ничего не рисуем (нет врагов)
        end
        
        -- Создаём меню
        UT_BATTLE_HUD.CreateBattleMenu()
        
        -- Восстанавливаем функцию
        UT_BATTLE_HUD.DrawEnemiesOnGrid = oldDrawEnemies
        
        -- Модифицируем диалоговую панель
        timer.Simple(0.1, function()
            if IsValid(UT_BATTLE_CORE.dialogPanel) then
                local panel = UT_BATTLE_CORE.dialogPanel
                
                -- Показываем текст с эффектом печатания
                if UT_BATTLE_HUD and UT_BATTLE_HUD.ShowTypingDialogText then
                    UT_BATTLE_HUD.ShowTypingDialogText("* Но никто не пришёл.", panel, function()
                        timer.Simple(1.5, function()
                            if UT_BATTLE_CORE then
                                UT_BATTLE_CORE.StopAllSystems()
                                chat.AddText(Color(200, 200, 200), "[UNDERTALE] ", Color(255, 255, 255), "Но никто не пришёл.")
                            end
                        end)
                    end)
                else
                    panel.Paint = function(self, w, h)
                        draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
                        surface.SetDrawColor(255, 255, 255, 150)
                        surface.DrawOutlinedRect(0, 0, w, h, 2)
                        draw.SimpleText("* Но никто не пришёл.", "UT_Pixel", w/2, h/2, 
                            Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    timer.Simple(3, function()
                        if UT_BATTLE_CORE then
                            UT_BATTLE_CORE.StopAllSystems()
                        end
                    end)
                end
            end
        end)
    end
    
    -- Команда для запуска
    concommand.Add("ut_nobody", function()
        UT_NOBODY_CAME.Start()
    end)
    
    print("[UNDERTALE] Эффект 'Но никто не пришёл' загружен. Команда: ut_nobody")
end