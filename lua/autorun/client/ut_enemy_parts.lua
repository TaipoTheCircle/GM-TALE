-- ФАЙЛ: ut_enemy_parts.lua (ЧАСТИ НАКЛАДЫВАЮТСЯ ДРУГ НА ДРУГА)
if CLIENT then
    print("[UNDERTALE] Загрузка системы частей врагов...")
    
    UT_ENEMY_PARTS = UT_ENEMY_PARTS or {}
    
    -- Кэш материалов для частей
    UT_ENEMY_PARTS.partMaterials = {}
    
    -- Конфигурация анимации для каждого типа врага (БЕЗ СМЕЩЕНИЙ - всё в одной позиции)
    UT_ENEMY_PARTS.enemyConfigs = {
        -- Зомби
        npc_zombie = {
            headSwingRange = 4,
            headSwingSpeed = 5.2,
            torsoSwingRange = 4,
            torsoSwingSpeed = 10.0,
            legsSwingRange = 6,
            legsSwingSpeed = 1.5,
            hasAllParts = true
        },
        
        -- Солдат Combine
        npc_combine_s = {
            headSwingRange = 5,
            headSwingSpeed = 0.8,
            torsoSwingRange = 3,
            torsoSwingSpeed = 0.6,
            legsSwingRange = 7,
            legsSwingSpeed = 1.2,
            hasAllParts = true
        },
        
        -- Солдат (альтернативный)
        npc_combine = {
            headSwingRange = 5,
            headSwingSpeed = 0.8,
            torsoSwingRange = 3,
            torsoSwingSpeed = 0.6,
            legsSwingRange = 7,
            legsSwingSpeed = 1.2,
            hasAllParts = true
        },
        
        -- Муравьиный лев (только голова и тело)
        npc_antlion = {
            headSwingRange = 10,
            headSwingSpeed = 1.5,
            torsoSwingRange = 5,
            torsoSwingSpeed = 0.9,
            hasLegs = false,
            hasAllParts = false
            
        },
        
        -- Рабочий муравьиный лев
        npc_antlionworker = {
            headSwingRange = 8,
            headSwingSpeed = 1.3,
            torsoSwingRange = 4,
            torsoSwingSpeed = 0.8,
            legsSwingRange = 5,
            legsSwingSpeed = 1.4,
            hasAllParts = true
        },
        
        -- Хедкраб (только голова и ноги)
        npc_headcrab = {
            headSwingRange = 12,
            headSwingSpeed = 8.0,
            legsSwingRange = 7,
            legsSwingSpeed = 4.0,
            hasTorso = false,
            hasAllParts = false
        },
        
        -- Быстрый зомби
        npc_fastzombie = {
            headSwingRange = 10,
            headSwingSpeed = 11.5,
            torsoSwingRange = 6,
            torsoSwingSpeed = 60.2,
            legsSwingRange = 12,
            legsSwingSpeed = 10.0,
            hasAllParts = true
        }
    }
    
    -- Получение материала части врага
    function UT_ENEMY_PARTS.GetPartMaterial(enemyClass, partName)
        local cacheKey = enemyClass .. "_" .. partName
        
        if UT_ENEMY_PARTS.partMaterials[cacheKey] then
            return UT_ENEMY_PARTS.partMaterials[cacheKey]
        end
        
        -- Путь к файлу: enemies/npc_antlion/ut_head.png
        local filePath = string.format("enemies/%s/ut_%s.png", enemyClass, partName)
        
        if file.Exists("materials/" .. filePath, "GAME") then
            local material = Material(filePath)
            if not material:IsError() then
                UT_ENEMY_PARTS.partMaterials[cacheKey] = material
                return material
            end
        end
        
        return nil
    end
    
    -- Получение конфигурации врага (с дефолтными значениями)
    function UT_ENEMY_PARTS.GetEnemyConfig(className)
        local config = UT_ENEMY_PARTS.enemyConfigs[className]
        if not config then
            -- Дефолтная конфигурация
            config = {
                headSwingRange = 6,
                headSwingSpeed = 1.0,
                torsoSwingRange = 4,
                torsoSwingSpeed = 0.8,
                legsSwingRange = 5,
                legsSwingSpeed = 1.2,
                hasTorso = true,
                hasLegs = true,
                hasAllParts = true
            }
        end
        return config
    end
    
    -- Анимация покачивания части
    function UT_ENEMY_PARTS.GetPartOffset(swingRange, swingSpeed, timeOffset)
        if not swingRange or swingRange == 0 then return 0, 0 end
        
        -- Горизонтальное покачивание
        local offsetX = math.sin(CurTime() * (swingSpeed or 1.0) + (timeOffset or 0)) * swingRange
        
        -- Вертикальное покачивание (дыхание) - небольшое
        local offsetY = math.abs(math.sin(CurTime() * (swingSpeed or 1.0) * 0.5 + (timeOffset or 0))) * 2 - 1
        
        return offsetX, offsetY
    end
    
    -- Отрисовка врага по частям (все части в одной позиции)
    function UT_ENEMY_PARTS.DrawEnemyByParts(enemy, x, y, w, h, isSelected)
        local className = enemy.class or "npc_zombie"
        local config = UT_ENEMY_PARTS.GetEnemyConfig(className)
        
        -- Базовые размеры (одинаковые для всех частей)
        local enemyW = w * 0.9
        local enemyH = h * 0.85
        
        -- Центрируем изображение
        local baseX = x + (w - enemyW) / 2
        local baseY = y + (h - enemyH) / 2
        
        -- Вибрация при выборе цели (общая для всех частей)
        local shakeX = 0
        local shakeY = 0
        if isSelected then
            shakeX = math.sin(CurTime() * 20) * 2
            shakeY = math.cos(CurTime() * 18) * 1
        end
        
        -- Временные смещения для разных частей (чтобы двигались не синхронно)
        local timeOffsets = { head = 0, torso = 1.2, legs = 2.4 }
        
        -- Порядок отрисовки: сзади наперёд (ноги -> тело -> голова)
        
        -- 1. Рисуем ноги (самый нижний слой)
        if config.hasLegs ~= false then
            local legsMaterial = UT_ENEMY_PARTS.GetPartMaterial(className, "legs")
            if legsMaterial then
                local swingX, swingY = UT_ENEMY_PARTS.GetPartOffset(
                    config.legsSwingRange, config.legsSwingSpeed, timeOffsets.legs
                )
                UT_ENEMY_PARTS.DrawPart(legsMaterial, baseX + swingX + shakeX, baseY + swingY + shakeY, enemyW, enemyH, false)
            end
        end
        
        -- 2. Рисуем тело (средний слой)
        if config.hasTorso ~= false then
            local torsoMaterial = UT_ENEMY_PARTS.GetPartMaterial(className, "torso")
            if torsoMaterial then
                local swingX, swingY = UT_ENEMY_PARTS.GetPartOffset(
                    config.torsoSwingRange, config.torsoSwingSpeed, timeOffsets.torso
                )
                UT_ENEMY_PARTS.DrawPart(torsoMaterial, baseX + swingX + shakeX, baseY + swingY + shakeY, enemyW, enemyH, false)
            end
        end
        
        -- 3. Рисуем голову (верхний слой) - только для неё рисуем обводку выбора
        local headMaterial = UT_ENEMY_PARTS.GetPartMaterial(className, "head")
        if headMaterial then
            local swingX, swingY = UT_ENEMY_PARTS.GetPartOffset(
                config.headSwingRange, config.headSwingSpeed, timeOffsets.head
            )
            UT_ENEMY_PARTS.DrawPart(headMaterial, baseX + swingX + shakeX, baseY + swingY + shakeY, enemyW, enemyH, isSelected)
        end
        
        -- HP бар и имя (только для живых)
        if enemy.hp > 0 then
            local nameY = y + h + 10
            draw.SimpleTextOutlined(enemy.name or "Враг", "UT_EnemyName", 
                x + w/2, nameY, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                3, Color(0, 0, 0, 200))
            
            local hpPercent = math.max(0, enemy.hp / enemy.maxhp)
            local hpBarW = w * 0.8
            local hpBarH = 15
            local hpBarX = x + (w - hpBarW) / 2
            local hpBarY = nameY + 30
            
            surface.SetDrawColor(50, 50, 50, 200)
            surface.DrawRect(hpBarX, hpBarY, hpBarW, hpBarH)
            surface.SetDrawColor(0, 0, 0, 180)
            surface.DrawOutlinedRect(hpBarX - 2, hpBarY - 2, hpBarW + 4, hpBarH + 4, 3)
            
            local hpColor
            if hpPercent > 0.5 then
                hpColor = Color(0, 255, 0, 255)
            elseif hpPercent > 0.2 then
                hpColor = Color(255, 255, 0, 255)
            else
                hpColor = Color(255, 50, 0, 255)
                local pulse = math.sin(CurTime() * 5) * 0.3 + 0.7
                hpColor = Color(255 * pulse, 50 * pulse, 0, 255)
            end
            
            surface.SetDrawColor(hpColor.r, hpColor.g, hpColor.b, 255)
            surface.DrawRect(hpBarX, hpBarY, hpBarW * hpPercent, hpBarH)
            
            draw.SimpleTextOutlined(math.ceil(enemy.hp) .. "/" .. enemy.maxhp, "UT_EnemyName", 
                x + w/2, hpBarY - 20, 
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                2, Color(0, 0, 0, 200))
        end
    end
    
    -- Отрисовка части с текстурой
    function UT_ENEMY_PARTS.DrawPart(material, x, y, w, h, isSelected)
        -- Сама текстура (без обводки, чтобы части сочетались)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(material)
        surface.DrawTexturedRect(x, y, w, h)
        
        -- Жёлтая обводка только для выбранной цели (только на голове)
        if isSelected then
            surface.SetDrawColor(255, 255, 0, 220)
            for i = 1, 4 do
                surface.DrawOutlinedRect(x - i - 2, y - i - 2, w + (i+2)*2, h + (i+2)*2, 2)
            end
        end
    end
    
    print("[UNDERTALE] Система частей врагов загружена")
end