-- ФАЙЛ: ut_sounds.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка звуковой системы...")
    
    UT_SOUNDS = UT_SOUNDS or {}
    
    -- Пути к звукам (как в Undertale)
    UT_SOUNDS.PATHS = {
        DAMAGE_TAKEN = "damage_taken.mp3",  -- Звук получения урона
        SELECT = "undertale-select-sound.mp3",
        SLASH = "undertale-slash.mp3",
        ATTACK = "undertale-attack-slash-green-screen.mp3",
        CRITICAL = "undertale-critical.mp3",
        MISS = "undertale-miss.mp3",
        FALLBACK = "buttons/button14.wav"
    }
    
    -- Функция воспроизведения звука урона
    function UT_SOUNDS.PlayDamageTaken()
        local soundPath = UT_SOUNDS.PATHS.DAMAGE_TAKEN
        
        if file.Exists("sound/" .. soundPath, "GAME") then
            surface.PlaySound(soundPath)
            print("[UNDERTALE] Воспроизведен звук урона: " .. soundPath)
            return true
        else
            -- Запасной вариант
            surface.PlaySound("buttons/button15.wav")
            print("[UNDERTALE] Звук урона не найден, использован запасной: " .. soundPath)
            return false
        end
    end
    
    -- Общая функция для воспроизведения звуков
    function UT_SOUNDS.Play(soundName)
        local soundPath = UT_SOUNDS.PATHS[soundName]
        if not soundPath then
            print("[UNDERTALE] Неизвестный звук: " .. tostring(soundName))
            return false
        end
        
        if file.Exists("sound/" .. soundPath, "GAME") then
            surface.PlaySound(soundPath)
            return true
        else
            surface.PlaySound(UT_SOUNDS.PATHS.FALLBACK)
            return false
        end
    end
    
    print("[UNDERTALE] Звуковая система загружена")
end