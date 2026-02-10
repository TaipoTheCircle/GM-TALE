-- ФАЙЛ: ut_init_fix.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/
-- ПРИНУДИТЕЛЬНАЯ ИНИЦИАЛИЗАЦИЯ ВАЖНЫХ ПЕРЕМЕННЫХ

if CLIENT then
    print("[UNDERTALE] Принудительная инициализация переменных...")
    
    -- ИНИЦИАЛИЗАЦИЯ ВСЕХ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ
    UT_BATTLE_CORE = UT_BATTLE_CORE or {
        battleActive = false,
        battleFrame = nil,
        selectedButton = 1,
        selectedTarget = 1,
        battleMode = "MENU",
        keyCooldown = 0,
        lastKeyPress = 0,
        keyRepeatDelay = 0.4,
        attackActive = false,
        attackInProgress = false,
        attackTimer = 0,
        attackBarPos = 0,
        attackBarSpeed = 400,
        attackBarWidth = 30,
        attackDamage = 0,
        attackHitZone = {start = 0, finish = 0},
        attackMaxDamage = 15,
        attackResult = nil,
        attackBlinkTimer = 0,
        attackSpacePressed = false,
        playerHp = 20,
        playerMaxHp = 20,
        buttons = {
            { name = "FIGHT", normal = "undertale/attack.png", selected = "undertale/attack_use.png" },
            { name = "ACT", normal = "undertale/act.png", selected = "undertale/act_use.png" },
            { name = "ITEM", normal = "undertale/item.png", selected = "undertale/item_use.png" },
            { name = "MERCY", normal = "undertale/mercy.png", selected = "undertale/mercy_use.png" }
        },
        currentTargets = {},
        btnImages = {},
        dialogPanel = nil,
        btnPanel = nil,
        infoPanel = nil,
        currentEnemy = nil
    }
    
    UT_HEART_SYSTEM = UT_HEART_SYSTEM or {}
    UT_HEART_CORE = UT_HEART_CORE or {}
    UT_BATTLE_HUD = UT_BATTLE_HUD or {}
    UT_BATTLE_INPUT = UT_BATTLE_INPUT or {}
    UT_BATTLE_TRIGGER = UT_BATTLE_TRIGGER or {}
    UT_BATTLE_MUSIC = UT_BATTLE_MUSIC or {}
    
    -- БАЗОВЫЕ ФУНКЦИИ
    UT_BATTLE_CORE.PlaySoundSafe = UT_BATTLE_CORE.PlaySoundSafe or function(soundName)
        if file.Exists("sound/"..soundName, "GAME") then
            surface.PlaySound(soundName)
            return true
        else
            surface.PlaySound("buttons/button14.wav")
            return false
        end
    end
    
    UT_BATTLE_CORE.StopAllSystems = UT_BATTLE_CORE.StopAllSystems or function()
        if IsValid(UT_BATTLE_CORE.battleFrame) then
            UT_BATTLE_CORE.battleFrame:Remove()
        end
        UT_BATTLE_CORE.battleActive = false
        print("[UNDERTALE] Все системы остановлены")
    end
    
    print("[UNDERTALE] Переменные инициализированы")
end