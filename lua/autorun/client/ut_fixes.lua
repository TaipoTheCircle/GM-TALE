-- ФАЙЛ: ut_fixes.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Применение критических исправлений...")
    
    -- ФИКС 1: Инициализация глобальных переменных
    timer.Simple(1, function()
        if not UT_BATTLE_CORE then
            UT_BATTLE_CORE = {
                battleActive = false,
                battleFrame = nil,
                selectedButton = 1,
                selectedTarget = 1,
                battleMode = "MENU",
                playerHp = 20,
                playerMaxHp = 20,
                buttons = {
                    { name = "FIGHT", normal = "undertale/attack.png", selected = "undertale/attack_use.png" },
                    { name = "ACT", normal = "undertale/act.png", selected = "undertale/act_use.png" },
                    { name = "ITEM", normal = "undertale/item.png", selected = "undertale/item_use.png" },
                    { name = "MERCY", normal = "undertale/mercy.png", selected = "undertale/mercy_use.png" }
                },
                currentTargets = {}
            }
            print("[UNDERTALE] Исправление: UT_BATTLE_CORE инициализирован")
        end
        
        if not UT_BATTLE_HUD then
            UT_BATTLE_HUD = {}
            print("[UNDERTALE] Исправление: UT_BATTLE_HUD создан")
        end
        
        if not UT_HEART_CORE then
            UT_HEART_CORE = {}
            print("[UNDERTALE] Исправление: UT_HEART_CORE создан")
        end
    end)
    
    -- ФИКС 2: Защищенная функция PlaySoundSafe
    timer.Simple(2, function()
        if UT_BATTLE_CORE and not UT_BATTLE_CORE.PlaySoundSafe then
            UT_BATTLE_CORE.PlaySoundSafe = function(soundName)
                if file.Exists("sound/"..soundName, "GAME") then
                    surface.PlaySound(soundName)
                    return true
                else
                    surface.PlaySound("buttons/button14.wav")
                    return false
                end
            end
            print("[UNDERTALE] Исправление: PlaySoundSafe добавлена")
        end
        
        if UT_BATTLE_CORE and not UT_BATTLE_CORE.UpdateButtonImages then
            UT_BATTLE_CORE.UpdateButtonImages = function()
                if not UT_BATTLE_CORE.btnImages then return end
                for i, btnData in pairs(UT_BATTLE_CORE.btnImages) do
                    if IsValid(btnData.image) then
                        local useSelected = (UT_BATTLE_CORE.battleMode == "MENU" and UT_BATTLE_CORE.selectedButton == i)
                        local imagePath = useSelected and btnData.data.selected or btnData.data.normal
                        
                        if file.Exists("materials/"..imagePath, "GAME") then
                            btnData.image:SetImage(imagePath)
                        end
                    end
                end
            end
            print("[UNDERTALE] Исправление: UpdateButtonImages добавлена")
        end
    end)
    
    -- ФИКС 3: Безопасная функция StopAllSystems
    timer.Simple(3, function()
        if UT_BATTLE_CORE and not UT_BATTLE_CORE.StopAllSystems then
            UT_BATTLE_CORE.StopAllSystems = function()
                print("[UNDERTALE] Остановка всех систем боя")
                
                if IsValid(UT_BATTLE_CORE.battleFrame) then
                    UT_BATTLE_CORE.battleFrame:Remove()
                end
                
                UT_BATTLE_CORE.battleActive = false
                UT_BATTLE_CORE.battleMode = "MENU"
                
                if UT_BATTLE_CORE.PlaySoundSafe then
                    UT_BATTLE_CORE.PlaySoundSafe("undertale-select-sound.mp3")
                end
                
                chat.AddText(Color(255, 0, 0), "[UNDERTALE] ", Color(255, 255, 255), "Бой окончен!")
            end
            print("[UNDERTALE] Исправление: StopAllSystems добавлена")
        end
        
        if UT_HEART_CORE and not UT_HEART_CORE.StopHeartPhase then
            UT_HEART_CORE.StopHeartPhase = function()
                print("[UNDERTALE] Остановка фазы сердца")
                UT_HEART_CORE.is_active = false
                timer.Remove("UT_HeartBulletTimer")
                hook.Remove("Think", "UT_HeartPhaseThink")
                hook.Remove("HUDPaint", "UT_HeartPhaseDraw")
            end
            print("[UNDERTALE] Исправление: StopHeartPhase добавлена")
        end
    end)
    
    print("[UNDERTALE] Критические исправления загружены")
end