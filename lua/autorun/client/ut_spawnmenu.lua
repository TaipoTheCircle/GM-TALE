-- ФАЙЛ: ut_spawnmenu.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка утилиты спавн-меню...")
    
    -- Создаем вкладку в спавн-меню
    hook.Add("PopulateToolMenu", "UT_PopulateSpawnMenu", function()
        -- Создаем панель в настройках (Settings -> Undertale)
        spawnmenu.AddToolMenuOption("Utilities", "Undertale", "UT_ControlPanel", 
            "Управление Undertale", "", "", function(panel)
            
            -- Заголовок
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = "Панель управления боевой системой Undertale"
            })
            
            panel:AddControl("Label", {
                Text = "УПРАВЛЕНИЕ АДДОНОМ",
                Description = "Включение/отключение системы"
            })
            
            -- Кнопка включения/отключения
            panel:AddControl("Button", {
                Label = "🔴 ПОЛНОСТЬЮ ОТКЛЮЧИТЬ АДДОН",
                Command = "ut_disable_all",
                Description = "Отключает всю систему Undertale (авто-бой, триггеры, меню)"
            })
            
            panel:AddControl("Button", {
                Label = "🟢 ВКЛЮЧИТЬ АДДОН",
                Command = "ut_enable_all",
                Description = "Включает систему Undertale обратно"
            })
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = ""
            })
            
            -- Раздел ручного управления
            panel:AddControl("Label", {
                Text = "РУЧНОЕ УПРАВЛЕНИЕ",
                Description = "Запуск/остановка компонентов вручную"
            })
            
            panel:AddControl("Button", {
                Label = "📋 ОТКРЫТЬ МЕНЮ БОЯ",
                Command = "ut_menu",
                Description = "Ручной запуск боевого меню"
            })
            
            panel:AddControl("Button", {
                Label = "❤️ ТЕСТ ФАЗЫ СЕРДЦА",
                Command = "ut_test_panel_heart",
                Description = "Запустить тестовую фазу сердца"
            })
            
            panel:AddControl("Button", {
                Label = "❌ ЗАКРЫТЬ МЕНЮ БОЯ",
                Command = "ut_close",
                Description = "Принудительное закрытие боевого меню"
            })
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = ""
            })
            
            -- Музыка
            panel:AddControl("Label", {
                Text = "МУЗЫКА",
                Description = "Управление музыкой"
            })
            
            panel:AddControl("Button", {
                Label = "🎵 ТЕСТ МУЗЫКИ",
                Command = "ut_test_music",
                Description = "Запустить тестовую музыку"
            })
            
            panel:AddControl("Button", {
                Label = "🔇 ОСТАНОВИТЬ МУЗЫКУ",
                Command = "ut_stop_music",
                Description = "Остановить музыку"
            })
            
            panel:AddControl("Slider", {
                Label = "Громкость музыки",
                Command = "ut_music_volume",
                Type = "Float",
                Min = 0,
                Max = 1,
                Default = 0.5,
                Description = "Регулировка громкости музыки"
            })
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = ""
            })
            
            -- Триггеры
            panel:AddControl("Label", {
                Text = "ТРИГГЕРЫ БОЯ",
                Description = "Управление авто-боем"
            })
            
            panel:AddControl("CheckBox", {
                Label = "✅ Включить авто-бой при подходе к NPC",
                Command = "ut_toggle_trigger",
                Description = "Автоматически начинать бой при подходе к врагу"
            })
            
            panel:AddControl("Button", {
                Label = "🔄 СБРОСИТЬ ТРИГГЕРЫ",
                Command = "ut_reset_triggers",
                Description = "Сбросить все триггеры врагов (если бой не начинается)"
            })
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = ""
            })
            
            -- Отладка
            panel:AddControl("Label", {
                Text = "ОТЛАДКА",
                Description = "Инструменты для разработчиков"
            })
            
            panel:AddControl("Button", {
                Label = "🔍 ПОКАЗАТЬ СТАТУС",
                Command = "ut_debug",
                Description = "Показать текущее состояние системы"
            })
            
            panel:AddControl("Button", {
                Label = "📁 ПРОВЕРИТЬ ФАЙЛЫ",
                Command = "ut_check_sounds",
                Description = "Проверить наличие звуковых файлов"
            })
            
            panel:AddControl("Button", {
                Label = "🎵 СТАТУС МУЗЫКИ",
                Command = "ut_music_status",
                Description = "Показать статус музыки"
            })
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = ""
            })
            
            -- Информация
            panel:AddControl("Label", {
                Text = "ИНФОРМАЦИЯ",
                Description = "Текущее состояние системы"
            })
            
            panel:AddControl("Label", {
                Text = "Версия: 2.0 (Упрощенная сетка)",
                Description = ""
            })
            
            -- Кнопка обновления статуса
            panel:AddControl("Button", {
                Label = "🔄 ОБНОВИТЬ СТАТУС",
                Command = "ut_update_status",
                Description = "Обновить информацию о состоянии"
            })
            
            -- Добавляем текстовое поле для статуса
            panel:AddControl("Label", {
                Text = "Статус: Загружается...",
                Description = "",
                Command = "ut_status_text"
            })
        end)
    end)
    
    -- Переменные для отслеживания состояния
    UT_ADDON_ENABLED = true
    
    -- Команда полного отключения аддона
    concommand.Add("ut_disable_all", function()
        print("[UNDERTALE] ===== ПОЛНОЕ ОТКЛЮЧЕНИЕ АДДОНА =====")
        
        -- Останавливаем все системы
        if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
            UT_BATTLE_CORE.StopAllSystems()
        end
        
        -- Останавливаем музыку
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
        end
        
        -- Останавливаем сердце
        if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Stop then
            UT_HEART_SIMPLE.Stop()
        end
        if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then
            UT_HEART_CORE.StopHeartPhase()
        end
        
        -- Удаляем все хуки
        hook.Remove("Think", "UT_BattleTrigger")
        hook.Remove("Think", "UT_AttackThink")
        hook.Remove("Think", "UT_HeartPhaseThink")
        hook.Remove("Think", "UT_SimpleHeart_Think")
        hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
        hook.Remove("Think", "UT_UpdateEnemiesGrid")
        
        -- Удаляем все таймеры
        timer.Remove("UT_BattleTrigger")
        timer.Remove("UT_CheckDeadEnemies")
        timer.Remove("UT_HeartBulletTimer")
        timer.Remove("UT_SimpleHeart_Bullets")
        timer.Remove("UT_MusicTimer")
        timer.Remove("UT_MusicRestartTimer")
        
        -- Отключаем триггер
        UT_ADDON_ENABLED = false
        
        chat.AddText(Color(255, 0, 0), "[UNDERTALE] ", Color(255, 255, 255), 
            "Аддон ПОЛНОСТЬЮ ОТКЛЮЧЕН! Авто-бой не будет работать.")
        chat.AddText(Color(255, 200, 0), "[ПОДСКАЗКА] ", Color(255, 255, 255), 
            "Для включения используйте 'ut_enable_all'")
        
        print("[UNDERTALE] Аддон полностью отключен")
    end)
    
    -- Команда включения аддона
    concommand.Add("ut_enable_all", function()
        print("[UNDERTALE] ===== ВКЛЮЧЕНИЕ АДДОНА =====")
        
        UT_ADDON_ENABLED = true
        
        -- Перезапускаем триггер если он существует
        if UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.Initialize then
            UT_BATTLE_TRIGGER.Initialize()
        end
        
        chat.AddText(Color(0, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), 
            "Аддон ВКЛЮЧЕН! Система работает в обычном режиме.")
        
        print("[UNDERTALE] Аддон включен")
    end)
    
    -- Команда переключения триггера
    local trigger_enabled = true
    concommand.Add("ut_toggle_trigger", function(ply, cmd, args)
        if args and #args > 0 then
            trigger_enabled = tobool(args[1])
        else
            trigger_enabled = not trigger_enabled
        end
        
        if trigger_enabled then
            if UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.Initialize then
                UT_BATTLE_TRIGGER.Initialize()
            end
            chat.AddText(Color(0, 255, 0), "[ТРИГГЕР] ", Color(255, 255, 255), 
                "Авто-бой ВКЛЮЧЕН")
        else
            hook.Remove("Think", "UT_BattleTrigger")
            timer.Remove("UT_BattleTrigger")
            chat.AddText(Color(255, 0, 0), "[ТРИГГЕР] ", Color(255, 255, 255), 
                "Авто-бой ОТКЛЮЧЕН")
        end
    end)
    
    -- Команда обновления статуса
    concommand.Add("ut_update_status", function()
        local status_text = "Статус: "
        
        if not UT_ADDON_ENABLED then
            status_text = status_text .. "🔴 ОТКЛЮЧЕН"
        elseif UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
            status_text = status_text .. "🟢 БОЙ АКТИВЕН (" .. (UT_BATTLE_CORE.battleMode or "MENU") .. ")"
        else
            status_text = status_text .. "🟡 ОЖИДАНИЕ"
        end
        
        status_text = status_text .. " | Врагов: " .. (UT_BATTLE_CORE and UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets or 0)
        status_text = status_text .. " | HP: " .. (UT_BATTLE_CORE and UT_BATTLE_CORE.playerHp or 20) .. "/20"
        
        chat.AddText(Color(0, 255, 255), "[СТАТУС] ", Color(255, 255, 255), status_text)
        
        -- Выводим в консоль детальную информацию
        print("=== UNDERTALE STATUS ===")
        print("Аддон включен:", UT_ADDON_ENABLED)
        print("Бой активен:", UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive)
        print("Режим:", UT_BATTLE_CORE and UT_BATTLE_CORE.battleMode)
        print("Врагов:", UT_BATTLE_CORE and UT_BATTLE_CORE.currentTargets and #UT_BATTLE_CORE.currentTargets)
        print("HP игрока:", UT_BATTLE_CORE and UT_BATTLE_CORE.playerHp)
        print("Музыка играет:", UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.isPlaying)
        print("=========================")
    end)
    
    -- Модифицируем триггер чтобы он учитывал состояние аддона
    -- Сохраняем оригинальную функцию
    local originalFindEnemies = UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.FindEnemies
    
    -- Переопределяем функцию поиска врагов с проверкой
    if UT_BATTLE_TRIGGER then
        UT_BATTLE_TRIGGER.FindEnemies = function()
            if not UT_ADDON_ENABLED then 
                return 
            end
            
            if originalFindEnemies then
                return originalFindEnemies()
            end
        end
    end
    
    -- Добавляем клавишу быстрого отключения (F8)
    hook.Add("PlayerButtonDown", "UT_ToggleKey", function(ply, key)
        if key == KEY_F8 then
            if UT_ADDON_ENABLED then
                RunConsoleCommand("ut_disable_all")
            else
                RunConsoleCommand("ut_enable_all")
            end
            return true
        end
    end)
    
    print("[UNDERTALE] Утилита спавн-меню загружена! Используйте F8 для быстрого отключения.")
    print("[UNDERTALE] Панель управления доступна: Меню -> Utilities -> Undertale")
end