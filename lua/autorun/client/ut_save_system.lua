-- ФАЙЛ: ut_save_system.lua
if CLIENT then
    print("[UNDERTALE] Загрузка системы сохранения...")
    
    UT_SAVE = UT_SAVE or {}
    
    -- Данные для сохранения
    UT_SAVE.data = {
        LV = 1,
        HP = 20,
        GOLD = 0,
        EXP = 0,
        kills = 0,
        genocide = false,
        items = {},
        equipment = {
            weapon = "STICK",
            armor = "BANDAGE"
        }
    }
    
    -- Загрузка сохранения
    function UT_SAVE.Load()
        local saved = cookie.GetString("undertale_save", "")
        if saved ~= "" then
            UT_SAVE.data = util.JSONToTable(saved) or UT_SAVE.data
        end
    end
    
    -- Сохранение
    function UT_SAVE.Save()
        cookie.Set("undertale_save", util.TableToJSON(UT_SAVE.data))
    end
    
    -- Увеличить LV (как в Undertale)
    function UT_SAVE.LevelUp()
        UT_SAVE.data.LV = UT_SAVE.data.LV + 1
        UT_SAVE.data.HP = 20 + (UT_SAVE.data.LV - 1) * 4
        UT_SAVE.Save()
        
        -- Эффект уровня в Undertale
        if UT_BATTLE_HUD and UT_BATTLE_HUD.ScreenShake then
            UT_BATTLE_HUD.ScreenShake(10, 1)
        end
    end
    
    -- Проверка на геноцид (как в Undertale)
    function UT_SAVE.CheckGenocide()
        if UT_SAVE.data.kills >= 20 then
            UT_SAVE.data.genocide = true
            chat.AddText(Color(255, 0, 0), "[ГЕНОЦИД] ", Color(255, 255, 255), 
                "Вы встали на путь геноцида...")
        end
    end
    
    UT_SAVE.Load()
    print("[UNDERTALE] Система сохранения загружена")
end