-- ФАЙЛ: path_config.lua (ПРОСТОЙ БЕЗ ОШИБОК)
if CLIENT then
    print("[UNDERTALE] Загрузка конфигурации путей...")
    
    -- Папка где лежат папки врагов
    UT_ENEMY_SPRITES_FOLDER = "enemies/"
    
    -- Имя файла спрайта внутри папки врага
    UT_ENEMY_SPRITE_NAME = "enemy.png"
    
    print("[UNDERTALE] Путь к спрайтам: " .. UT_ENEMY_SPRITES_FOLDER .. "npc_class/" .. UT_ENEMY_SPRITE_NAME)
end