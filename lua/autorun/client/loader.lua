-- ФАЙЛ: loader.lua (ОБНОВЛЕННЫЙ)
print("[UNDERTALE] ========================================")
print("[UNDERTALE] Начало загрузки улучшенной боевой системы...")
print("[UNDERTALE] Версия: 2.0 (Сетка врагов)")
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

-- 9. Основной файл
AddCSLuaFile("ut_battle_main.lua")
include("ut_battle_main.lua")

-- 10. Исправления
AddCSLuaFile("ut_fixes.lua")
include("ut_fixes.lua")

print("[UNDERTALE] ========================================")
print("[UNDERTALE] Все модули улучшенной системы загружены!")
print("[UNDERTALE] Команды:")
print("[UNDERTALE]   ut_menu - Открыть меню боя")
print("[UNDERTALE]   ut_heart - Тест фазы сердца")
print("[UNDERTALE]   ut_close - Закрыть меню")
print("[UNDERTALE]   ut_debug - Отладка")
print("[UNDERTALE]   ut_test_panel_heart - Тест сердца в панели")
print("[UNDERTALE]   ut_reset_triggers - Сбросить триггеры")
print("[UNDERTALE]   ut_test_music - Тест музыки")
print("[UNDERTALE]   ut_stop_music - Остановить музыку")
print("[UNDERTALE] ========================================")

-- Автосообщение
timer.Simple(10, function()
    chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
        "Улучшенная боевая система загружена! Введите ut_menu")
    chat.AddText(Color(255, 255, 0), "[СИСТЕМА] ", Color(255, 255, 255), 
        "Подойдите к NPC для автоматического боя или используйте ut_menu")
    chat.AddText(Color(200, 255, 200), "[НОВОЕ] ", Color(255, 255, 255), 
        "Сетка врагов, навигация стрелками, автоматическое управление!")
end)