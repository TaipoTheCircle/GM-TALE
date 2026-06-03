-- ФАЙЛ: ut_bullet_hell.lua
if CLIENT then
    print("[UNDERTALE] Загрузка системы bullet hell...")
    
    UT_BULLET_HELL = UT_BULLET_HELL or {}
    
    -- Типы атак (как в Undertale)
    UT_BULLET_HELL.attackPatterns = {
        -- Обычные атаки
        bones = {
            horizontal = function(bounds, wave)
                local bullets = {}
                local yPos = bounds.top + wave * 50 + math.sin(CurTime() * 3) * 20
                for i = -3, 3 do
                    table.insert(bullets, {
                        x = bounds.left + (bounds.right - bounds.left) / 2 + i * 60,
                        y = yPos,
                        width = 40,
                        height = 15,
                        vx = 0,
                        vy = (wave % 2 == 0 and 200 or -200),
                        type = "bone",
                        damage = 4,
                        color = Color(240, 240, 255)
                    })
                end
                return bullets
            end,
            
            vertical = function(bounds, wave)
                local bullets = {}
                local xPos = bounds.left + wave * 80 + math.sin(CurTime() * 2) * 30
                for i = -2, 2 do
                    table.insert(bullets, {
                        x = xPos,
                        y = bounds.top + i * 50,
                        width = 15,
                        height = 40,
                        vx = (wave % 2 == 0 and 150 or -150),
                        vy = 0,
                        type = "bone",
                        damage = 4,
                        color = Color(240, 240, 255)
                    })
                end
                return bullets
            end
        },
        
        -- Атаки как в оригинале Undertale
        papyrus = {
            -- "Синие атаки" (не двигаться)
            blueAttack = function(bounds)
                local bullets = {}
                for i = 1, 5 do
                    table.insert(bullets, {
                        x = bounds.left + math.random(0, bounds.right - bounds.left),
                        y = bounds.top - 50,
                        width = 80,
                        height = 20,
                        vx = 0,
                        vy = 150,
                        type = "blueBone",
                        damage = 0, -- Не наносит урон, но заставляет стоять на месте
                        isBlue = true
                    })
                end
                return bullets
            end
        },
        
        mettaton = {
            -- Атаки с лабиринтом
            laser = function(bounds)
                local bullets = {}
                local patterns = {
                    {x = bounds.left + 100, vy = 300},
                    {x = bounds.right - 100, vy = -300},
                    {x = bounds.left + 200, vy = 200},
                    {x = bounds.right - 200, vy = -200}
                }
                for _, pattern in ipairs(patterns) do
                    table.insert(bullets, {
                        x = pattern.x,
                        y = bounds.top - 20,
                        width = 10,
                        height = 30,
                        vx = 0,
                        vy = pattern.vy,
                        type = "laser",
                        damage = 6,
                        color = Color(255, 100, 255),
                        warning = true,
                        warningTime = 0.5
                    })
                end
                return bullets
            end
        }
    }
    
    -- Система "синих атак" (останавливают сердце)
    UT_BULLET_HELL.blueBonesActive = false
    
    -- Функция для создания волны атаки
    UT_BULLET_HELL.CreateAttackWave = function(attackName, waveIndex, bounds)
        local parts = string.Split(attackName, ".")
        local category = parts[1]
        local pattern = parts[2]
        
        if UT_BULLET_HELL.attackPatterns[category] and 
           UT_BULLET_HELL.attackPatterns[category][pattern] then
            return UT_BULLET_HELL.attackPatterns[category][pattern](bounds, waveIndex)
        end
        return {}
    end
    
    -- Система "Карма" (как в битве с Сансом)
    UT_BULLET_HELL.karma = 0
    UT_BULLET_HELL.karmaDecay = 5 -- Уменьшение кармы в секунду
    
    function UT_BULLET_HELL.ApplyKarmaDamage(damage)
        UT_BULLET_HELL.karma = UT_BULLET_HELL.karma + damage
        return math.floor(UT_BULLET_HELL.karma)
    end
    
    function UT_BULLET_HELL.UpdateKarma()
        if UT_BULLET_HELL.karma > 0 then
            UT_BULLET_HELL.karma = math.max(0, UT_BULLET_HELL.karma - UT_BULLET_HELL.karmaDecay * FrameTime())
        end
    end
    
    print("[UNDERTALE] Система bullet hell загружена")
end