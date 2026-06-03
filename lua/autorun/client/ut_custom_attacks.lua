-- ФАЙЛ: ut_custom_attacks.lua
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/
if CLIENT then
    print("[UNDERTALE] Загрузка системы кастомных атак...")
    
    UT_CUSTOM_ATTACKS = UT_CUSTOM_ATTACKS or {}
    
    -- ===== КЭШ ДЛЯ ТЕКСТУР =====
    UT_CUSTOM_ATTACKS.textureCache = {}
    
    -- ===== ФУНКЦИЯ ЗАГРУЗКИ ТЕКСТУРЫ ВРАГА =====
    function UT_CUSTOM_ATTACKS.GetEnemyTexture(enemyClass, textureName)
        local cacheKey = enemyClass .. "_" .. textureName
        if UT_CUSTOM_ATTACKS.textureCache[cacheKey] then
            return UT_CUSTOM_ATTACKS.textureCache[cacheKey]
        end
        
        local path = string.format("enemies/%s/%s.png", enemyClass, textureName)
        if file.Exists("materials/" .. path, "GAME") then
            local mat = Material(path)
            if not mat:IsError() then
                UT_CUSTOM_ATTACKS.textureCache[cacheKey] = mat
                return mat
            end
        end
        return nil
    end
    
    -- ===== БАЗОВЫЕ ТИПЫ АТАК =====
    
    -- 1. ПРЯМОЛИНЕЙНЫЙ СНАРЯД
    UT_CUSTOM_ATTACKS.Projectile = {
        name = "projectile",
        Create = function(enemy, params)
            local bullets = {}
            local count = params.count or 5
            local speed = params.speed or 300
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            local size = params.size or 24
            
            for i = 1, count do
                local side = params.direction or math.random(1, 4)
                local startX, startY, targetX, targetY
                
                -- Определяем стартовую позицию
                if side == 1 then -- сверху
                    startX = math.random(100, ScrW() - 100)
                    startY = -50
                    targetX = ScrW()/2 + math.random(-50, 50)
                    targetY = ScrH() * 0.55 + 100
                elseif side == 2 then -- снизу
                    startX = math.random(100, ScrW() - 100)
                    startY = ScrH() + 50
                    targetX = ScrW()/2 + math.random(-50, 50)
                    targetY = ScrH() * 0.55 + 100
                elseif side == 3 then -- слева
                    startX = -50
                    startY = math.random(100, ScrH() - 100)
                    targetX = ScrW()/2 + math.random(-50, 50)
                    targetY = ScrH() * 0.55 + 100
                else -- справа
                    startX = ScrW() + 50
                    startY = math.random(100, ScrH() - 100)
                    targetX = ScrW()/2 + math.random(-50, 50)
                    targetY = ScrH() * 0.55 + 100
                end
                
                bullets[#bullets + 1] = {
                    x = startX, y = startY,
                    targetX = targetX, targetY = targetY,
                    speed = speed + math.random(-50, 50),
                    texture = texture,
                    size = size,
                    damage = params.damage or 2,
                    type = "projectile",
                    color = params.color or Color(255, 100, 100)
                }
            end
            return bullets
        end
    }
    
    -- 2. ВОЛНОВАЯ АТАКА
    UT_CUSTOM_ATTACKS.Wave = {
        name = "wave",
        Create = function(enemy, params)
            local bullets = {}
            local waves = params.waves or 3
            local speed = params.speed or 200
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            local size = params.size or 32
            
            for wave = 1, waves do
                for i = -2, 2 do
                    local delay = wave * 0.3
                    bullets[#bullets + 1] = {
                        x = ScrW()/2 + i * 60,
                        y = -50 - delay * 100,
                        targetX = ScrW()/2 + i * 40,
                        targetY = ScrH() * 0.55 + 100,
                        speed = speed,
                        texture = texture,
                        size = size,
                        damage = params.damage or 2,
                        type = "wave",
                        delay = delay,
                        color = params.color or Color(200, 200, 255)
                    }
                end
            end
            return bullets
        end
    }
    
    -- 3. КРУГОВАЯ АТАКА (снаряды летят по кругу)
    UT_CUSTOM_ATTACKS.Circle = {
        name = "circle",
        Create = function(enemy, params)
            local bullets = {}
            local count = params.count or 12
            local speed = params.speed or 150
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            local size = params.size or 20
            local radius = params.radius or 200
            
            local centerX = ScrW()/2
            local centerY = ScrH() * 0.3
            
            for i = 1, count do
                local angle = (i / count) * math.pi * 2
                local startX = centerX + math.cos(angle) * radius
                local startY = centerY + math.sin(angle) * radius
                
                bullets[#bullets + 1] = {
                    x = startX, y = startY,
                    targetX = centerX,
                    targetY = ScrH() * 0.55 + 100,
                    speed = speed,
                    texture = texture,
                    size = size,
                    damage = params.damage or 3,
                    type = "circle",
                    color = params.color or Color(255, 150, 50)
                }
            end
            return bullets
        end
    }
    
    -- 4. ЛАЗЕР (линия, которая появляется с предупреждением)
    UT_CUSTOM_ATTACKS.Laser = {
        name = "laser",
        Create = function(enemy, params)
            local lasers = {}
            local count = params.count or 3
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "laser")
            local warningTex = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, "warning")
            
            for i = 1, count do
                local x = math.random(100, ScrW() - 100)
                lasers[#lasers + 1] = {
                    x = x,
                    y = -50,
                    targetY = ScrH() + 50,
                    width = params.width or 15,
                    height = ScrH() + 100,
                    speed = params.speed or 800,
                    texture = texture,
                    warningTex = warningTex,
                    damage = params.damage or 5,
                    type = "laser",
                    warningTime = 0.8,
                    color = params.color or Color(255, 50, 50)
                }
            end
            return lasers
        end
    }
    
    -- 5. СЛОЖНАЯ ТРАЕКТОРИЯ (дуга)
    UT_CUSTOM_ATTACKS.Arc = {
        name = "arc",
        Create = function(enemy, params)
            local bullets = {}
            local count = params.count or 4
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            
            for i = 1, count do
                bullets[#bullets + 1] = {
                    x = math.random(100, ScrW() - 100),
                    y = -50,
                    targetX = ScrW()/2 + (i - count/2) * 60,
                    targetY = ScrH() * 0.55 + 100,
                    speed = params.speed or 250,
                    texture = texture,
                    size = params.size or 28,
                    damage = params.damage or 3,
                    type = "arc",
                    arcHeight = params.arcHeight or 120,
                    color = params.color or Color(255, 200, 100)
                }
            end
            return bullets
        end
    }
    
    -- 6. ДОЖДЬ (снаряды падают сверху)
    UT_CUSTOM_ATTACKS.Rain = {
        name = "rain",
        Create = function(enemy, params)
            local bullets = {}
            local count = params.count or 15
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            
            for i = 1, count do
                local delay = (i - 1) * 0.1
                bullets[#bullets + 1] = {
                    x = math.random(100, ScrW() - 100),
                    y = -50 - delay * 150,
                    targetX = math.random(100, ScrW() - 100),
                    targetY = ScrH() + 50,
                    speed = params.speed or 350,
                    texture = texture,
                    size = params.size or 20,
                    damage = params.damage or 2,
                    type = "rain",
                    delay = delay,
                    color = params.color or Color(180, 180, 255)
                }
            end
            return bullets
        end
    }
    
-- Атака "Сфера Нихиланта"
UT_CUSTOM_ATTACKS.NihilanthSphere = {
    name = "nihilanth_sphere",
    Create = function(enemy, params)
        local bullets = {}
        local count = params.count or 6
        
        for i = 1, count do
            local angle = (i / count) * math.pi * 2 + CurTime() * 2
            local radius = 250
            
            bullets[#bullets + 1] = {
                x = ScrW()/2 + math.cos(angle) * radius,
                y = ScrH() * 0.35 + math.sin(angle) * radius,
                targetX = ScrW()/2,
                targetY = ScrH() * 0.55 + 100,
                speed = params.speed or 150,
                size = 25,
                damage = params.damage or 4,
                type = "projectile",
                color = Color(255, 100, 255),
                shape = "circle"
            }
        end
        return bullets
    end
}

    -- 7. ПРЕСЛЕДУЮЩИЙ СНАРЯД
    UT_CUSTOM_ATTACKS.Homing = {
        name = "homing",
        Create = function(enemy, params)
            local bullets = {}
            local count = params.count or 3
            local texture = UT_CUSTOM_ATTACKS.GetEnemyTexture(enemy.class, params.texture or "attack")
            
            for i = 1, count do
                bullets[#bullets + 1] = {
                    x = math.random(50, ScrW() - 50),
                    y = -50,
                    targetX = ScrW()/2,
                    targetY = ScrH() * 0.55 + 100,
                    speed = params.speed or 200,
                    texture = texture,
                    size = params.size or 24,
                    damage = params.damage or 2,
                    type = "homing",
                    homingStrength = params.homingStrength or 2,
                    color = params.color or Color(255, 100, 255)
                }
            end
            return bullets
        end
    }
    
    -- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
    
    -- Получить атаку по имени
    function UT_CUSTOM_ATTACKS.GetAttack(attackName)
        return UT_CUSTOM_ATTACKS[attackName]
    end
    
    -- Создать атаку для врага
    function UT_CUSTOM_ATTACKS.CreateAttack(enemy, attackConfig)
        local attackType = UT_CUSTOM_ATTACKS[attackConfig.type]
        if not attackType then
            print("[UNDERTALE] Неизвестный тип атаки: " .. tostring(attackConfig.type))
            return {}
        end
        
        return attackType.Create(enemy, attackConfig)
    end
    
    -- Звук атаки врага
    function UT_CUSTOM_ATTACKS.PlayAttackSound(enemy, soundName)
        local path = string.format("enemies/%s/%s.wav", enemy.class, soundName)
        if file.Exists("sound/" .. path, "GAME") then
            surface.PlaySound(path)
            return true
        end
        return false
    end
    
    print("[UNDERTALE] Система кастомных атак загружена")
end