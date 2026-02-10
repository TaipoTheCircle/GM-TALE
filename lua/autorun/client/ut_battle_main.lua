-- ФАЙЛ: ut_battle_main.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка основной системы боя...")
    
    -- Ждем полной загрузки игры
    timer.Simple(2, function()
        print("[UNDERTALE] Инициализация боевой системы...")
        
        -- Проверяем что мы на клиенте
        if not LocalPlayer then
            print("[UNDERTALE] ОШИБКА: LocalPlayer не доступен!")
            return
        end
        
        -- БЕЗОПАСНЫЕ КОМАНДЫ (с проверкой загрузки)
        concommand.Add("ut_menu", function()
            print("[UNDERTALE] Запуск меню...")
            
            -- Ждем пока загрузится ядро
            if not UT_BATTLE_CORE then
                print("[UNDERTALE] ОШИБКА: Ядро не загружено! Подождите...")
                chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                    "Система еще загружается. Подождите 5 секунд.")
                return
            end
            
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            else
                print("[UNDERTALE] ОШИБКА: Модуль интерфейса не загружен!")
                chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                    "Модуль интерфейса не загружен!")
            end
        end)
        
        concommand.Add("ut_heart", function()
            print("[UNDERTALE] Принудительный запуск режима сердца")
            
            if not UT_BATTLE_CORE then
                chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), 
                    "Система еще не загружена!")
                return
            end
            
            -- Создаем тестовое меню
            if not UT_BATTLE_CORE.battleActive then
                if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                    UT_BATTLE_HUD.CreateBattleMenu()
                end
            end
            
            -- Через 1 секунду переходим в режим сердца
            timer.Simple(1, function()
                if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                    UT_BATTLE_CORE.battleMode = "HEART_PHASE"
                    UT_BATTLE_CORE.playerHp = 20
                    
                    -- Обновляем панель
                    if IsValid(UT_BATTLE_CORE.dialogPanel) then
                        UT_BATTLE_CORE.dialogPanel.Paint = function(self, w, h)
                            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 180))
                            surface.SetDrawColor(255, 255, 255, 100)
                            surface.DrawOutlinedRect(0, 0, w, h, 2)
                            
                            draw.SimpleText("ТЕСТ РЕЖИМА СЕРДЦА", "UT_Attack", w/2, 30, 
                                Color(255, 255, 255), TEXT_ALIGN_CENTER)
                            
                            draw.SimpleText("ВАШЕ HP: "..UT_BATTLE_CORE.playerHp.."/20", "UT_Menu", 
                                w/2, h - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                        end
                    end
                    
                    -- Запускаем систему сердца
                    if UT_HEART_CORE and UT_HEART_CORE.StartHeartPhase then
                        local test_enemy = {
                            name = "ТЕСТ",
                            dialog = {
                                "* Тестовый режим сердца!",
                                "* Уклоняйтесь от снарядов!",
                                "* Используйте стрелки!"
                            }
                        }
                        
                        UT_HEART_CORE.StartHeartPhase(test_enemy)
                        chat.AddText(Color(0, 255, 0), "[ТЕСТ СЕРДЦА] ", Color(255, 255, 255), 
                            "Режим сердца активирован! Уклоняйтесь от снарядов!")
                    end
                end
            end)
        end)
        
        concommand.Add("ut_close", function()
            if UT_BATTLE_CORE then
                if UT_BATTLE_CORE.StopAllSystems then
                    UT_BATTLE_CORE.StopAllSystems()  -- Эта функция теперь останавливает музыку
                else
                    if IsValid(UT_BATTLE_CORE.battleFrame) then
                        UT_BATTLE_CORE.battleFrame:Remove()
                    end
                    UT_BATTLE_CORE.battleActive = false
                    
                    -- ✅ ОСТАНАВЛИВАЕМ МУЗЫКУ ДАЖЕ ЕСЛИ StopAllSystems НЕТ
                    if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
                        UT_BATTLE_MUSIC.Stop()
                    end
                end
                print("[UNDERTALE] Меню закрыто")
                chat.AddText(Color(255, 0, 0), "[UNDERTALE] ", Color(255, 255, 255), "Меню закрыто!")
            else
                chat.AddText(Color(255, 0, 0), "[ОШИБКА] ", Color(255, 255, 255), "Система не загружена!")
            end
        end)
        
        -- Команда для отладки
        concommand.Add("ut_debug", function()
            print("=== UNDERTALE UI DEBUG ===")
            print("battleActive:", UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive or "N/A")
            print("battleMode:", UT_BATTLE_CORE and UT_BATTLE_CORE.battleMode or "N/A")
            print("attackActive:", UT_BATTLE_CORE and UT_BATTLE_CORE.attackActive or "N/A")
            print("attackInProgress:", UT_BATTLE_CORE and UT_BATTLE_CORE.attackInProgress or "N/A")
            print("selectedButton:", UT_BATTLE_CORE and UT_BATTLE_CORE.selectedButton or "N/A")
            print("selectedTarget:", UT_BATTLE_CORE and UT_BATTLE_CORE.selectedTarget or "N/A")
            print("playerHp:", UT_BATTLE_CORE and UT_BATTLE_CORE.playerHp or "N/A")
            print("heartSystem:", UT_HEART_CORE ~= nil)
            
            if UT_BATTLE_CORE then
                if IsValid(UT_BATTLE_CORE.battleFrame) then
                    print("battleFrame: VALID")
                else
                    print("battleFrame: INVALID")
                end
                
                if IsValid(UT_BATTLE_CORE.dialogPanel) then
                    print("dialogPanel: VALID")
                else
                    print("dialogPanel: INVALID")
                end
                
                if UT_BATTLE_CORE.currentTargets then
                    print("currentTargets count:", #UT_BATTLE_CORE.currentTargets)
                    for i, target in ipairs(UT_BATTLE_CORE.currentTargets) do
                        print("Target "..i..": "..target.name.. " HP: "..target.hp.."/"..target.maxhp)
                    end
                end
            end
            print("=========================")
        end)
        
        -- Команда теста сердца в панели
        concommand.Add("ut_test_panel_heart", function()
            print("[UNDERTALE] Тест фазы сердца")
            
            -- Сначала создаем меню
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            end
            
            -- Через секунду запускаем сердце
            timer.Simple(1, function()
                if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Start then
                    local test_enemy = {
                        name = "ТЕСТ",
                        dialog = {
                            "* Атака начинается!",
                            "* Попробуй увернуться!",
                            "* Смотри внимательно!"
                        }
                    }
                    
                    UT_HEART_SIMPLE.Start(test_enemy)
                    chat.AddText(Color(0, 255, 0), "[ТЕСТ] ", Color(255, 255, 255), 
                        "Фаза сердца запущена! Используйте стрелки!")
                end
            end)
        end)
        
        -- АВТОСООБЩЕНИЕ
        timer.Simple(5, function()
            print("========================================")
            print("UNDERTALE BATTLE UI ЗАГРУЖЕН!")
            print("Команды: ut_menu, ut_heart, ut_close, ut_debug, ut_test_panel_heart")
            print("========================================")
            
            chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
                "Боевая система загружена. Введите ut_menu")
            chat.AddText(Color(255, 255, 0), "[ТЕСТ] ", Color(255, 255, 255), 
                "Для теста сердца введите ut_test_panel_heart")
        end)
        
        print("[UNDERTALE] Основная система инициализирована!")
    end)
else
    print("[UNDERTALE] Серверный код игнорирован")
end