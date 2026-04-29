-- ФАЙЛ: ut_spawnmenu.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка утилиты спавн-меню...")
    
    -- Глобальные переменные
    UT_ADDON_ENABLED = true
    local trigger_enabled = true
    
    -- Функция для отключения систем без сообщений
    local function UT_DisableAddonSystems()
        if UT_BATTLE_CORE and UT_BATTLE_CORE.StopAllSystems then
            UT_BATTLE_CORE.StopAllSystems()
        end
        
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Stop then
            UT_BATTLE_MUSIC.Stop()
        end
        
        if UT_HEART_SIMPLE and UT_HEART_SIMPLE.Stop then
            UT_HEART_SIMPLE.Stop()
        end
        
        if UT_HEART_CORE and UT_HEART_CORE.StopHeartPhase then
            UT_HEART_CORE.StopHeartPhase()
        end
        
        hook.Remove("Think", "UT_BattleTrigger")
        hook.Remove("Think", "UT_AttackThink")
        hook.Remove("Think", "UT_HeartPhaseThink")
        hook.Remove("Think", "UT_SimpleHeart_Think")
        hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
        hook.Remove("Think", "UT_UpdateEnemiesGrid")
        
        timer.Remove("UT_BattleTrigger")
        timer.Remove("UT_CheckDeadEnemies")
        timer.Remove("UT_HeartBulletTimer")
        timer.Remove("UT_SimpleHeart_Bullets")
        timer.Remove("UT_MusicTimer")
        timer.Remove("UT_MusicRestartTimer")
    end
    
    -- Загружаем сохраненные настройки
    local function UT_LoadSettings()
        local saved = cookie.GetString("ut_addon_enabled", "true")
        UT_ADDON_ENABLED = (saved == "true")
        
        local trigger_saved = cookie.GetString("ut_trigger_enabled", "true")
        trigger_enabled = (trigger_saved == "true")
        
        print("[UNDERTALE] Загружены настройки: аддон=" .. tostring(UT_ADDON_ENABLED) .. ", триггер=" .. tostring(trigger_enabled))
        
        if not UT_ADDON_ENABLED then
            UT_DisableAddonSystems()
        end
        
        if not trigger_enabled then
            hook.Remove("Think", "UT_BattleTrigger")
            timer.Remove("UT_BattleTrigger")
        elseif UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.Initialize then
            UT_BATTLE_TRIGGER.Initialize()
        end
    end
    
    -- Создаем вкладку в спавн-меню
    hook.Add("PopulateToolMenu", "UT_PopulateSpawnMenu", function()
        spawnmenu.AddToolMenuOption("Utilities", "Undertale", "UT_ControlPanel", 
            "Управление Undertale", "", "", function(panel)
            
            panel:AddControl("Label", {
                Text = "══════════════════════════════════════",
                Description = "Панель управления боевой системой Undertale"
            })
            
            panel:AddControl("Label", {
                Text = "УПРАВЛЕНИЕ АДДОНОМ",
                Description = "Включение/отключение системы"
            })
            
            panel:AddControl("Button", {
                Label = "🔴 ПОЛНОСТЬЮ ОТКЛЮЧИТЬ АДДОН",
                Command = "ut_disable_all",
                Description = "Отключает всю систему Undertale (настройки сохранятся)"
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
            
            panel:AddControl("Label", {
                Text = "ИНФОРМАЦИЯ",
                Description = "Текущее состояние системы"
            })
            
            panel:AddControl("Label", {
                Text = "Версия: 2.1 (Сохранение настроек)",
                Description = ""
            })
            
            panel:AddControl("Button", {
                Label = "🔄 ОБНОВИТЬ СТАТУС",
                Command = "ut_update_status",
                Description = "Обновить информацию о состоянии"
            })
        end)
    end)
    
    -- Команда полного отключения аддона (С СОХРАНЕНИЕМ)
    concommand.Add("ut_disable_all", function()
        print("[UNDERTALE] ===== ПОЛНОЕ ОТКЛЮЧЕНИЕ АДДОНА =====")
        
        UT_ADDON_ENABLED = false
        cookie.Set("ut_addon_enabled", "false")
        
        UT_DisableAddonSystems()
        
        chat.AddText(Color(255, 0, 0), "[UNDERTALE] ", Color(255, 255, 255), 
            "Аддон ПОЛНОСТЬЮ ОТКЛЮЧЕН! Настройки сохранены.")
        chat.AddText(Color(255, 200, 0), "[ПОДСКАЗКА] ", Color(255, 255, 255), 
            "Для включения используйте 'ut_enable_all' или F8")
        
        print("[UNDERTALE] Аддон полностью отключен (сохранено)")
    end)
    
    -- Команда включения аддона (С СОХРАНЕНИЕМ)
    concommand.Add("ut_enable_all", function()
        print("[UNDERTALE] ===== ВКЛЮЧЕНИЕ АДДОНА =====")
        
        UT_ADDON_ENABLED = true
        cookie.Set("ut_addon_enabled", "true")
        
        if UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.Initialize then
            UT_BATTLE_TRIGGER.Initialize()
        end
        
        chat.AddText(Color(0, 255, 0), "[UNDERTALE] ", Color(255, 255, 255), 
            "Аддон ВКЛЮЧЕН! Настройки сохранены.")
        
        print("[UNDERTALE] Аддон включен (сохранено)")
    end)
    
    -- Команда переключения триггера (С СОХРАНЕНИЕМ)
    concommand.Add("ut_toggle_trigger", function(ply, cmd, args)
        if args and #args > 0 then
            trigger_enabled = tobool(args[1])
        else
            trigger_enabled = not trigger_enabled
        end
        
        cookie.Set("ut_trigger_enabled", tostring(trigger_enabled))
        
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
    local originalFindEnemies = UT_BATTLE_TRIGGER and UT_BATTLE_TRIGGER.FindEnemies
    
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
    
    -- Клавиша быстрого отключения (F8)
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
    
    -- Загружаем настройки при старте
    timer.Simple(1, function()
        UT_LoadSettings()
    end)
    
    print("[UNDERTALE] Утилита спавн-меню загружена! Используйте F8 для быстрого отключения.")
    print("[UNDERTALE] Панель управления доступна: Меню -> Utilities -> Undertale")
    print("[UNDERTALE] НАСТРОЙКИ СОХРАНЯЮТСЯ! При перезапуске аддон запомнит состояние.")
end