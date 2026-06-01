-- ФАЙЛ: ut_enemy_attacks.lua (АТАКИ ДЛЯ СОЛДАТ COMBINE)
if CLIENT then
    print("[UNDERTALE] Загрузка атак для солдат Combine...")
    
    UT_ENEMY_ATTACKS = UT_ENEMY_ATTACKS or {}
    
    -- ===== АТАКИ ДЛЯ ОБЫЧНОГО СОЛДАТА =====
    UT_ENEMY_ATTACKS.CombineSoldierAttack = {
        name = "АВТОМАТИЧЕСКАЯ ОЧЕРЕДЬ",
        heartColor = "RED",     -- Красное сердце для свободного движения
        duration = 8,            -- Длительность атаки в секундах
        
        -- Создание волны атаки
        CreateWave = function(attack, waveIndex)
            local bullets = {}
            local burstCount = 3 + math.min(waveIndex, 3)  -- 3-6 пуль за волну
            
            for i = 1, burstCount do
                -- Небольшой разброс для имитации отдачи
                local spreadX = math.random(-40, 40)
                local spreadY = math.random(-30, 30)
                
                table.insert(bullets, {
                    x = math.random(50, ScrW() - 50),  -- Появляется с любой стороны
                    y = -20,
                    targetX = ScrW()/2 + spreadX,
                    targetY = ScrH() * 0.55 + 125 + spreadY,
                    speed = 400 + math.random(0, 80),
                    color = Color(0, 200, 255, 255),   -- Голубой цвет как у импульсной винтовки
                    size = 6,
                    type = "FAST",
                    trail = true,
                    damage = 2
                })
            end
            
            return bullets
        end,
        
        -- Диалог перед атакой
        dialog = {
            "* Солдат прицеливается!",
            "* Слышен звук заряжания оружия",
            "\"Стоять!\""
        }
    }
    
    -- ===== АТАКИ ДЛЯ ЭЛИТНОГО СОЛДАТА (белый) =====
    UT_ENEMY_ATTACKS.CombineEliteAttack = {
        name = "ПРИЦЕЛЬНЫЙ ОГОНЬ",
        heartColor = "BLUE",     -- Синее сердце (только прыжки!)
        duration = 10,
        
        CreateWave = function(attack, waveIndex)
            local bullets = {}
            local sniperCount = 2 + math.floor(waveIndex / 2)  -- 2-4 выстрела
            
            for i = 1, sniperCount do
                -- Точные выстрелы с разных сторон
                local side = math.random(1, 4)
                local startX, startY, targetX, targetY
                
                if side == 1 then -- Сверху
                    startX = math.random(200, ScrW() - 200)
                    startY = -30
                    targetX = ScrW()/2 + math.random(-30, 30)
                    targetY = ScrH() * 0.55 + 125 + math.random(-20, 20)
                elseif side == 2 then -- Снизу
                    startX = math.random(200, ScrW() - 200)
                    startY = ScrH() + 30
                    targetX = ScrW()/2 + math.random(-30, 30)
                    targetY = ScrH() * 0.55 + 125 + math.random(-20, 20)
                elseif side == 3 then -- Слева
                    startX = -30
                    startY = math.random(150, ScrH() - 150)
                    targetX = ScrW()/2 + math.random(-30, 30)
                    targetY = ScrH() * 0.55 + 125 + math.random(-20, 20)
                else -- Справа
                    startX = ScrW() + 30
                    startY = math.random(150, ScrH() - 150)
                    targetX = ScrW()/2 + math.random(-30, 30)
                    targetY = ScrH() * 0.55 + 125 + math.random(-20, 20)
                end
                
                table.insert(bullets, {
                    x = startX,
                    y = startY,
                    targetX = targetX,
                    targetY = targetY,
                    speed = 500,
                    color = Color(255, 100, 0, 255),    -- Оранжевый (как у арбалета)
                    size = 8,
                    type = "SNIPER",
                    trail = true,
                    damage = 3,
                    warning = true   -- Показывает линию прицела перед выстрелом
                })
            end
            
            return bullets
        end,
        
        dialog = {
            "* Элитный солдат целится в вас",
            "* Слышен высокочастотный звук",
            "\"Ликвидация\""
        }
    }
    
    -- ===== АТАКИ ДЛЯ ГРАНАТОМЁТЧИКА =====
    UT_ENEMY_ATTACKS.CombineGrenadeAttack = {
        name = "ГРАНАТОМЁТ",
        heartColor = "RED",
        duration = 12,
        
        CreateWave = function(attack, waveIndex)
            local bullets = {}
            local grenadeCount = 2
            
            for i = 1, grenadeCount do
                -- Траектория дугой
                local startX = math.random(100, ScrW() - 100)
                local startY = -40
                local targetX = ScrW()/2 + math.random(-150, 150)
                local targetY = ScrH() * 0.55 + 125
                
                table.insert(bullets, {
                    x = startX,
                    y = startY,
                    targetX = targetX,
                    targetY = targetY,
                    speed = 250,
                    color = Color(150, 150, 50, 255),
                    size = 12,
                    type = "ARC",           -- Дуга вместо прямой линии
                    arcHeight = 150,        -- Высота дуги
                    explosion = true,       -- Взрыв при попадании
                    explosionRadius = 80,
                    damage = 4
                })
            end
            
            return bullets
        end,
        
        dialog = {
            "* Солдат заряжает гранатомёт",
            "* Слышен характерный звук",
            "\"В укрытие!\""
        }
    }
    
    -- ===== ОЧЕРЕДЬ ИЗ-ЗА УКРЫТИЯ (два солдата) =====
    UT_ENEMY_ATTACKS.CombineCrossfireAttack = {
        name = "ПЕРЕКРЁСТНЫЙ ОГОНЬ",
        heartColor = "RED",
        duration = 8,
        
        CreateWave = function(attack, waveIndex)
            local bullets = {}
            local shotsPerSide = 2 + math.min(waveIndex, 2)
            
            -- Левая сторона
            for i = 1, shotsPerSide do
                table.insert(bullets, {
                    x = 50,
                    y = math.random(100, ScrH() - 100),
                    targetX = ScrW()/2 + math.random(-100, 0),
                    targetY = ScrH() * 0.55 + 125 + math.random(-40, 40),
                    speed = 350,
                    color = Color(0, 200, 255, 255),
                    size = 6,
                    type = "FAST"
                })
            end
            
            -- Правая сторона
            for i = 1, shotsPerSide do
                table.insert(bullets, {
                    x = ScrW() - 50,
                    y = math.random(100, ScrH() - 100),
                    targetX = ScrW()/2 + math.random(0, 100),
                    targetY = ScrH() * 0.55 + 125 + math.random(-40, 40),
                    speed = 350,
                    color = Color(0, 200, 255, 255),
                    size = 6,
                    type = "FAST"
                })
            end
            
            return bullets
        end,
        
        dialog = {
            "* Солдаты занимают позиции!",
            "* Перекрёстный огонь!",
            "\"Окружён!\""
        }
    }
    
    -- ===== АТАКИ ДЛЯ СОЛДАТА С ЦЕПНЫМ ГРАНАТОМЁТОМ =====
    UT_ENEMY_ATTACKS.CombineSMGAttack = {
        name = "УРАГАННЫЙ ОГОНЬ",
        heartColor = "RED",
        duration = 6,
        
        CreateWave = function(attack, waveIndex)
            local bullets = {}
            local bulletCount = 15 + waveIndex * 3  -- Много пуль
            
            for i = 1, bulletCount do
                local angle = math.random() * math.pi * 2
                local radius = math.random(200, 400)
                
                table.insert(bullets, {
                    x = ScrW()/2 + math.cos(angle) * radius,
                    y = ScrH() * 0.3 + math.sin(angle) * radius,
                    targetX = ScrW()/2 + math.random(-60, 60),
                    targetY = ScrH() * 0.55 + 125 + math.random(-40, 40),
                    speed = 300 + math.random(0, 100),
                    color = Color(255, 200, 0, 200),
                    size = 5,
                    type = "FAST"
                })
            end
            
            return bullets
        end,
        
        dialog = {
            "* Солдат открывает ураганный огонь!",
            "* Трассы проносятся мимо",
            "\"Огонь на подавление!\""
        }
    }
     
    -- ===== ПОЛУЧЕНИЕ АТАКИ ДЛЯ СОЛДАТА =====
    function UT_ENEMY_ATTACKS.GetAttackForCombine(class)
        local attacks = {
            combine_s = UT_ENEMY_ATTACKS.CombineSoldierAttack,     -- Обычный солдат
            combine_elite = UT_ENEMY_ATTACKS.CombineEliteAttack,   -- Элитный
            combine_grenade = UT_ENEMY_ATTACKS.CombineGrenadeAttack, -- С гранатами
            combine_shotgun = UT_ENEMY_ATTACKS.CombineSMGAttack,   -- С SMG
            combine_crossfire = UT_ENEMY_ATTACKS.CombineCrossfireAttack -- Тактический
        }
        return attacks[class] or UT_ENEMY_ATTACKS.CombineSoldierAttack
    end
end