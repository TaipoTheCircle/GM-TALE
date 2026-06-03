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

AddCSLuaFile("ut_sounds.lua")
include("ut_sounds.lua")

-- 3. Ядро системы (обновленное)
AddCSLuaFile("ut_battle_core.lua")
include("ut_battle_core.lua")

-- 4. Простая система сердца
AddCSLuaFile("ut_heart_simple.lua")
include("ut_heart_simple.lua")

-- 4.5. Система разных цветов души (НОВЫЙ)
AddCSLuaFile("ut_heart_system.lua")
include("ut_heart_system.lua")

-- 5. Интерфейс с сеткой (обновленный)
AddCSLuaFile("ut_battle_hud.lua")
include("ut_battle_hud.lua")

-- 6. Модуль ввода с навигацией (обновленный)
AddCSLuaFile("ut_battle_input.lua")
include("ut_battle_input.lua")

-- 6.5. Хотфикс (ВРЕМЕННЫЙ)
AddCSLuaFile("ut_hotfix.lua")
include("ut_hotfix.lua")

-- 6.6. Атаки врагов (НОВЫЙ)
--AddCSLuaFile("ut_enemy_attacks.lua")
--include("ut_enemy_attacks.lua")

-- 6.7. Система печатания текста (НОВЫЙ)
AddCSLuaFile("ut_typing.lua")
include("ut_typing.lua")

-- 6.8. Система частей врагов (НОВЫЙ)
AddCSLuaFile("ut_enemy_parts.lua")
include("ut_enemy_parts.lua")

-- 6.9. Система эффектов урона (НОВЫЙ)
AddCSLuaFile("ut_damage_effect.lua")
include("ut_damage_effect.lua")

-- 6.10. Битва с Сансом (НОВЫЙ)
AddCSLuaFile("ut_sans_battle.lua")
include("ut_sans_battle.lua")

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
 
-- 11. Данные врагов (НОВЫЙ)
AddCSLuaFile("ut_enemy_data.lua")
include("ut_enemy_data.lua")

-- 12. Система действий (НОВЫЙ)
AddCSLuaFile("ut_battle_action.lua")
include("ut_battle_action.lua")

-- 13. Исправления
AddCSLuaFile("ut_fixes.lua")
include("ut_fixes.lua")

-- 14. Загрузка новых систем
AddCSLuaFile("ut_bullet_hell.lua")
include("ut_bullet_hell.lua")

-- 15. Система сохранения (как в Undertale)
AddCSLuaFile("ut_save_system.lua")
include("ut_save_system.lua")

-- 16. Интерфейс игрока
AddCSLuaFile("ut_theme.lua")
include("ut_theme.lua")

-- 17. Кастомные Атаки
AddCSLuaFile("ut_custom_attacks.lua")
include("ut_custom_attacks.lua")

-- 18. Менеджер Атаки
AddCSLuaFile("ut_attack_manager.lua")
include("ut_attack_manager.lua")

-- 19. Нихилант
AddCSLuaFile("ut_nihilanth_battle.lua")
include("ut_nihilanth_battle.lua")

-- Автосообщение
timer.Simple(10, function()
    chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
        "Улучшенная боевая система загружена!")
    chat.AddText(Color(255, 255, 0), "[УПРАВЛЕНИЕ] ", Color(255, 255, 255), 
        "Панель управления: Меню -> Utilities -> Undertale")
    chat.AddText(Color(200, 200, 255), "[F8] ", Color(255, 255, 255), 
        "Нажмите F8 для быстрого включения/отключения аддона")
end)