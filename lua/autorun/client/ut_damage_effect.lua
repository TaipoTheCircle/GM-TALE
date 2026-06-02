-- ФАЙЛ: ut_damage_effect.lua (ИСПРАВЛЕННЫЙ)
if CLIENT then
    print("[UNDERTALE] Загрузка системы эффектов урона...")
    
    UT_DAMAGE_EFFECT = UT_DAMAGE_EFFECT or {}
    
    -- Активные эффекты урона
    UT_DAMAGE_EFFECT.activeEffects = {}
    
    -- 6 кадров анимации удара (208x880)
    UT_DAMAGE_EFFECT.slashSprites = {
        { name = "undertale/slash1.png", duration = 0.05 },
        { name = "undertale/slash2.png", duration = 0.05 },
        { name = "undertale/slash3.png", duration = 0.05 },
        { name = "undertale/slash4.png", duration = 0.05 },
        { name = "undertale/slash5.png", duration = 0.05 },
        { name = "undertale/slash6.png", duration = 0.05 }
    }
    
    -- Загружаем материалы заранее
    UT_DAMAGE_EFFECT.slashMaterials = {}
    for i, sprite in ipairs(UT_DAMAGE_EFFECT.slashSprites) do
        if file.Exists("materials/" .. sprite.name, "GAME") then
            local mat = Material(sprite.name)
            if not mat:IsError() then
                UT_DAMAGE_EFFECT.slashMaterials[i] = mat
                print("[UNDERTALE] Загружен спрайт: " .. sprite.name)
            else
                print("[UNDERTALE] Ошибка загрузки: " .. sprite.name)
            end
        else
            print("[UNDERTALE] Файл не найден: " .. sprite.name)
        end
    end
    
-- Добавить эффект анимированного удара
function UT_DAMAGE_EFFECT.AddHitEffect(enemyX, enemyY, enemyW, enemyH, isCritical)
    print("[UNDERTALE] Добавлен эффект удара")
    
    local effect = {
        x = enemyX,
        y = enemyY,
        width = enemyW,
        height = enemyH,
        startTime = CurTime(),
        duration = 0.35,
        isCritical = isCritical or false,
        type = "slash"
    }
    
    table.insert(UT_DAMAGE_EFFECT.activeEffects, effect)
    
    -- Удаляем старый хук если есть
    if UT_DAMAGE_EFFECT.hookActive then
        hook.Remove("HUDPaint", "UT_DamageEffectDraw")
    end
    
    -- Добавляем хук заново
    UT_DAMAGE_EFFECT.hookActive = true
    hook.Add("HUDPaint", "UT_DamageEffectDraw", UT_DAMAGE_EFFECT.DrawEffects)
end
        
    

-- Отрисовка всех эффектов
function UT_DAMAGE_EFFECT.DrawEffects()
    for i = #UT_DAMAGE_EFFECT.activeEffects, 1, -1 do
        local effect = UT_DAMAGE_EFFECT.activeEffects[i]
        local elapsed = CurTime() - effect.startTime
        
        if elapsed >= effect.duration then
            table.remove(UT_DAMAGE_EFFECT.activeEffects, i)
        else
            local progress = elapsed / effect.duration
            
            if effect.type == "slash" then
                -- Проверяем загружены ли материалы спрайтов
                local hasValidMaterials = false
                for _, mat in ipairs(UT_DAMAGE_EFFECT.slashMaterials) do
                    if mat and not mat:IsError() then
                        hasValidMaterials = true
                        break
                    end
                end
                
                if hasValidMaterials then
                    -- Отрисовка со спрайтами
                    local frameIndex = math.floor(elapsed / 0.058) + 1
                    if frameIndex <= #UT_DAMAGE_EFFECT.slashMaterials then
                        local material = UT_DAMAGE_EFFECT.slashMaterials[frameIndex]
                        if material and not material:IsError() then
                            local scale = 1 + progress * 0.2
                            local slashW = effect.width * scale
                            local slashH = effect.height * scale
                            local drawX = effect.x + effect.width/2 - slashW/2
                            local drawY = effect.y + effect.height/2 - slashH/2
                            local alpha = 255 * (1 - progress * 0.3)
                            
                            surface.SetDrawColor(255, 255, 255, alpha)
                            surface.SetMaterial(material)
                            surface.DrawTexturedRect(drawX, drawY, slashW, slashH)
                        end
                    end
                else
                    -- ====== РЕЗЕРВНАЯ ОТРИСОВКА (работает без спрайтов) ======
                    -- Рисуем диагональные полосы удара
                    local centerX = effect.x + effect.width/2
                    local centerY = effect.y + effect.height/2
                    local maxRadius = math.max(effect.width, effect.height) * (1 + progress * 0.5)
                    
                    -- Красный оттенок
                    local alpha = 200 * (1 - progress)
                    
                    -- Рисуем крест из линий (удар)
                    surface.SetDrawColor(255, 200, 100, alpha)
                    surface.DrawLine(
                        centerX - maxRadius, centerY - maxRadius,
                        centerX + maxRadius, centerY + maxRadius
                    )
                    surface.DrawLine(
                        centerX + maxRadius, centerY - maxRadius,
                        centerX - maxRadius, centerY + maxRadius
                    )
                    
                    -- Дополнительные линии для эффекта
                    surface.SetDrawColor(255, 255, 255, alpha * 0.8)
                    for i = -2, 2 do
                        surface.DrawLine(
                            centerX - maxRadius + i*5, centerY - maxRadius - i*3,
                            centerX + maxRadius + i*5, centerY + maxRadius - i*3
                        )
                        surface.DrawLine(
                            centerX + maxRadius - i*5, centerY - maxRadius + i*3,
                            centerX - maxRadius - i*5, centerY + maxRadius + i*3
                        )
                    end
                    
                    -- Красная вспышка
                    if progress < 0.2 then
                        surface.SetDrawColor(255, 0, 0, 180)
                        surface.DrawRect(effect.x, effect.y, effect.width, effect.height)
                    end
                end
            elseif effect.type == "flash" then
                local alpha = 255 * (1 - progress)
                surface.SetDrawColor(255, 0, 0, alpha * 0.6)
                surface.DrawRect(effect.x, effect.y, effect.width, effect.height)
                
                if progress < 0.2 then
                    local whiteAlpha = 255 * (1 - progress * 5)
                    surface.SetDrawColor(255, 255, 255, whiteAlpha)
                    surface.DrawRect(effect.x, effect.y, effect.width, effect.height)
                end
            end
        end
    end
    
    if #UT_DAMAGE_EFFECT.activeEffects == 0 then
        UT_DAMAGE_EFFECT.hookActive = false
        hook.Remove("HUDPaint", "UT_DamageEffectDraw")
    end
end
    -- Простая красная вспышка
    function UT_DAMAGE_EFFECT.AddFlashEffect(enemyX, enemyY, enemyW, enemyH, isCritical)
        local effect = {
            x = enemyX,
            y = enemyY,
            width = enemyW,
            height = enemyH,
            startTime = CurTime(),
            duration = 0.25,
            isCritical = isCritical or false,
            type = "flash"
        }
        
        table.insert(UT_DAMAGE_EFFECT.activeEffects, effect)
        
        if not UT_DAMAGE_EFFECT.hookActive then
            UT_DAMAGE_EFFECT.hookActive = true
            hook.Remove("HUDPaint", "UT_DamageEffectDraw")
hook.Add("PostDrawHUD", "UT_DamageEffectDraw", UT_DAMAGE_EFFECT.DrawEffects)
        end
    end
    
-- Отрисовка эффектов на панели (для использования в battleFrame)
function UT_DAMAGE_EFFECT.DrawEffectsOnPanel()
    for i = #UT_DAMAGE_EFFECT.activeEffects, 1, -1 do
        local effect = UT_DAMAGE_EFFECT.activeEffects[i]
        local elapsed = CurTime() - effect.startTime
        
        if elapsed >= effect.duration then
            table.remove(UT_DAMAGE_EFFECT.activeEffects, i)
        else
            local progress = elapsed / effect.duration
            
            if effect.type == "slash" then
                -- Резервная отрисовка диагональных линий
                local centerX = effect.x + effect.width/2
                local centerY = effect.y + effect.height/2
                local maxRadius = math.max(effect.width, effect.height) * (1 + progress * 0.5)
                local alpha = 200 * (1 - progress)
                
                surface.SetDrawColor(255, 200, 100, alpha)
                surface.DrawLine(
                    centerX - maxRadius, centerY - maxRadius,
                    centerX + maxRadius, centerY + maxRadius
                )
                surface.DrawLine(
                    centerX + maxRadius, centerY - maxRadius,
                    centerX - maxRadius, centerY + maxRadius
                )
            elseif effect.type == "flash" then
                local alpha = 255 * (1 - progress)
                surface.SetDrawColor(255, 0, 0, alpha * 0.6)
                surface.DrawRect(effect.x, effect.y, effect.width, effect.height)
            end
        end
    end
end
    
    -- Очистить все эффекты
    function UT_DAMAGE_EFFECT.ClearEffects()
        UT_DAMAGE_EFFECT.activeEffects = {}
        UT_DAMAGE_EFFECT.hookActive = false
        hook.Remove("HUDPaint", "UT_DamageEffectDraw")
    end
    
    print("[UNDERTALE] Система эффектов урона загружена")
end