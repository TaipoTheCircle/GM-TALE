-- ФАЙЛ: loader.lua (ОБНОВЛЕННЫЙ С УТИЛИТОЙ)
print("[UNDERTALE] ========================================")
print("[UNDERTALE] Начало загрузки улучшенной боевой системы...")
print("[UNDERTALE] Версия: 2.0 (Сетка врагов + Утилита спавн-меню)")
print("[UNDERTALE] ========================================")

-- 1. Конфигурация (самый первый)
AddCSLuaFile("path_config.lua")
include("path_config.lua")

AddCSLuaFile("config.lua")
include("config.lua")

AddCSLuaFile("ut_battle_attacks.lua")
include("ut_battle_attacks.lua")

-- 2. Базовые переменные
AddCSLuaFile("ut_init_fix.lua")
include("ut_init_fix.lua")

-- 3. Ядро системы (обновленное)
AddCSLuaFile("ut_battle_core.lua")
include("ut_battle_core.lua")

-- 4. Простая система сердца
AddCSLuaFile("ut_heart_simple.lua")
include("ut_heart_simple.lua")

-- 5. Интерфейс с сеткой (обновленный)
AddCSLuaFile("ut_battle_hud.lua")
include("ut_battle_hud.lua")

-- 6. Модуль ввода с навигацией (обновленный)
AddCSLuaFile("ut_battle_input.lua")
include("ut_battle_input.lua")

-- 7. Музыка
AddCSLuaFile("ut_battle_music.lua")
include("ut_battle_music.lua")

-- 8. Триггер боя (обновленный)
AddCSLuaFile("ut_battle_trigger.lua")
include("ut_battle_trigger.lua")

-- 9. УТИЛИТА СПАВН-МЕНЮ (НОВЫЙ ФАЙЛ)
AddCSLuaFile("ut_spawnmenu.lua")
include("ut_spawnmenu.lua")

-- 10. Основной файл
AddCSLuaFile("ut_battle_main.lua")
include("ut_battle_main.lua")

-- 11. Исправления
AddCSLuaFile("ut_fixes.lua")
include("ut_fixes.lua")



-- Автосообщение
timer.Simple(10, function()
    chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
        "Улучшенная боевая система загружена!")
    chat.AddText(Color(255, 255, 0), "[УПРАВЛЕНИЕ] ", Color(255, 255, 255), 
        "Панель управления: Меню -> Utilities -> Undertale")
    chat.AddText(Color(200, 200, 255), "[F8] ", Color(255, 255, 255), 
        "Нажмите F8 для быстрого включения/отключения аддона")
end)