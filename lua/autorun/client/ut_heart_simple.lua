-- ФАЙЛ: ut_heart_simple.lua (ИСПРАВЛЕННЫЙ - МЕРЦАНИЕ ПРОПАДАНИЕМ)
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка простой системы сердца...")
    
    UT_HEART_SIMPLE = UT_HEART_SIMPLE or {}
    
    -- ====== СОСТОЯНИЕ ======
    UT_HEART_SIMPLE.is_active = false
    UT_HEART_SIMPLE.player_hp = 20
    UT_HEART_SIMPLE.player_alive = true
    UT_HEART_SIMPLE.heart_trail = {}
    UT_HEART_SIMPLE.phaseTimer = nil
    UT_HEART_SIMPLE.phaseDuration = 10
    
    -- ====== ПЕРЕМЕННЫЕ ДЛЯ МЕРЦАНИЯ ======
    UT_HEART_SIMPLE.damageBlinkTimer = 0
    UT_HEART_SIMPLE.damageBlinkDuration = 0.6  -- Длительность мерцания
    UT_HEART_SIMPLE.damageBlinkSpeed = 12      -- Скорость мерцания
    
    -- ====== ТАЙМЕР ДЛЯ ЗАВЕРШЕНИЯ ФАЗЫ ======
    function UT_HEART_SIMPLE.StartPhaseTimer()
        if UT_HEART_SIMPLE.phaseTimer then
            timer.Remove("UT_SimpleHeart_PhaseEnd")
        end
        
        timer.Create("UT_SimpleHeart_PhaseEnd", UT_HEART_SIMPLE.phaseDuration, 1, function()
            if UT_HEART_SIMPLE.is_active and UT_HEART_SIMPLE.player_alive then
                print("[UNDERTALE] Фаза сердца успешно завершена по времени!")
                
                UT_HEART_SIMPLE.Stop()
                
                if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                    UT_BATTLE_CORE.battleMode = "MENU"
                    
                    if IsValid(UT_BATTLE_CORE.dialogPanel) then
                        UT_BATTLE_CORE.dialogPanel:SetSize(900, 250)
                        UT_BATTLE_CORE.dialogPanel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
                        
                        if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                    end
                    
                    chat.AddText(Color(0, 255, 0), "[ФАЗА СЕРДЦА] ", Color(255, 255, 255), 
                        "Вы уклонились от всех атак!")
                end
            end
        end)
        
        UT_HEART_SIMPLE.phaseTimer = CurTime()
    end
    
    -- ====== ЗАПУСК ======
    function UT_HEART_SIMPLE.Start(enemy_data)
        print("[UNDERTALE] Запуск простой системы сердца")
        
        UT_HEART_SIMPLE.Stop()
        
        UT_HEART_SIMPLE.is_active = true
        UT_HEART_SIMPLE.player_hp = 20
        UT_HEART_SIMPLE.player_alive = true
        UT_HEART_SIMPLE.heart_trail = {}
        UT_HEART_SIMPLE.damageBlinkTimer = 0
        
        UT_HEART_SIMPLE.heart = {
            x = 0.5,
            y = 0.5,
            size = 20,
            speed = 0.8
        }
        
        UT_HEART_SIMPLE.bullets = {}
        
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            local panel = UT_BATTLE_CORE.dialogPanel
            
            panel:SetSize(350, 350)
            panel:SetPos(ScrW()/2 - 175, ScrH()/2 + 20)
            
            panel.Paint = function(self, w, h)
                draw.RoundedBox(15, 0, 0, w, h, Color(0, 0, 0, 240))
                
                local padding = 30
                local game_left = padding
                local game_top = padding
                local game_right = w - padding
                local game_bottom = h - padding
                local game_width = game_right - game_left
                local game_height = game_bottom - game_top
                
                surface.SetDrawColor(10, 10, 20, 220)
                surface.DrawRect(game_left, game_top, game_width, game_height)
                
                surface.SetDrawColor(255, 255, 255, 80)
                surface.DrawOutlinedRect(game_left, game_top, game_width, game_height, 2)
                
                -- Рисуем снаряды
                for _, bullet in ipairs(UT_HEART_SIMPLE.bullets) do
                    local bx = game_left + bullet.x * game_width
                    local by = game_top + bullet.y * game_height
                    
                    surface.SetDrawColor(bullet.color.r, bullet.color.g, bullet.color.b, 255)
                    
                    if bullet.type == "circle" then
                        for i = 0, 8 do
                            local angle1 = (i / 8) * math.pi * 2
                            local angle2 = ((i + 1) / 8) * math.pi * 2
                            
                            surface.DrawLine(
                                bx + math.cos(angle1) * 6,
                                by + math.sin(angle1) * 6,
                                bx + math.cos(angle2) * 6,
                                by + math.sin(angle2) * 6
                            )
                        end
                    else
                        surface.DrawRect(bx - 6, by - 6, 12, 12)
                        surface.SetDrawColor(0, 0, 0, 150)
                        surface.DrawOutlinedRect(bx - 6, by - 6, 12, 12, 1)
                    end
                end
                
                -- ====== РИСУЕМ СЕРДЦЕ С МЕРЦАНИЕМ ======
                if UT_HEART_SIMPLE.player_alive then
                    local hx = game_left + UT_HEART_SIMPLE.heart.x * game_width
                    local hy = game_top + UT_HEART_SIMPLE.heart.y * game_height
                    
                    -- Проверяем, нужно ли рисовать сердце (мерцание = пропадание)
                    local shouldDrawHeart = true
                    
                    if UT_HEART_SIMPLE.damageBlinkTimer > 0 and 
                       CurTime() - UT_HEART_SIMPLE.damageBlinkTimer < UT_HEART_SIMPLE.damageBlinkDuration then
                        local elapsed = CurTime() - UT_HEART_SIMPLE.damageBlinkTimer
                        -- Чередуем: рисуем/не рисуем с определенной скоростью
                        local blinkPhase = math.floor(elapsed * UT_HEART_SIMPLE.damageBlinkSpeed)
                        shouldDrawHeart = (blinkPhase % 2 == 0)
                    end
                    
                    -- Рисуем сердце только если shouldDrawHeart = true
                    if shouldDrawHeart then
                        local heart_material = Material("undertale/hearth.png", "noclamp smooth")
                        local has_heart_sprite = not heart_material:IsError()
                        
                        if has_heart_sprite then
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(heart_material)
                            local heart_size = UT_HEART_SIMPLE.heart.size * 2
                            surface.DrawTexturedRect(
                                hx - heart_size/2, 
                                hy - heart_size/2, 
                                heart_size, 
                                heart_size
                            )
                        else
                            surface.SetDrawColor(255, 0, 0, 255)
                            draw.NoTexture()
                            
                            local points = {
                                {x = hx, y = hy - UT_HEART_SIMPLE.heart.size},
                                {x = hx + UT_HEART_SIMPLE.heart.size, y = hy},
                                {x = hx, y = hy + UT_HEART_SIMPLE.heart.size},
                                {x = hx - UT_HEART_SIMPLE.heart.size, y = hy}
                            }
                            
                            surface.DrawPoly(points)
                        end
                    end
                end
            end
        end
        
        timer.Simple(1, function()
            if UT_HEART_SIMPLE.is_active then
                UT_HEART_SIMPLE.CreateBullets()
            end
        end)
        
        timer.Create("UT_SimpleHeart_Bullets", 2.0, 0, function()
            if UT_HEART_SIMPLE.is_active then
                UT_HEART_SIMPLE.CreateBullets()
            end
        end)
        
        UT_HEART_SIMPLE.StartPhaseTimer()
        
        hook.Add("Think", "UT_SimpleHeart_Think", function()
            if UT_HEART_SIMPLE.is_active then
                UT_HEART_SIMPLE.Update()
            end
        end)
        
        return true
    end
    
    -- ====== СОЗДАНИЕ СНАРЯДОВ ======
    function UT_HEART_SIMPLE.CreateBullets()
        for i = 1, 3 do
            local start_side = math.random(1, 4)
            local x, y, vx, vy
            
            if start_side == 1 then
                x = math.random() * 0.8 + 0.1
                y = -0.05
                vx = (math.random() - 0.5) * 0.2
                vy = 0.4
            elseif start_side == 2 then
                x = 1.05
                y = math.random() * 0.8 + 0.1
                vx = -0.4
                vy = (math.random() - 0.5) * 0.2
            elseif start_side == 3 then
                x = math.random() * 0.8 + 0.1
                y = 1.05
                vx = (math.random() - 0.5) * 0.2
                vy = -0.4
            else
                x = -0.05
                y = math.random() * 0.8 + 0.1
                vx = 0.4
                vy = (math.random() - 0.5) * 0.2
            end
            
            table.insert(UT_HEART_SIMPLE.bullets, {
                x = x, y = y,
                vx = vx, vy = vy,
                speed = math.random(50, 80) / 1000,
                color = Color(math.random(200, 255), math.random(200, 255), math.random(200, 255)),
                type = math.random() > 0.5 and "circle" or "square"
            })
        end
    end
    
    -- ====== ОБНОВЛЕНИЕ ======
    function UT_HEART_SIMPLE.Update()
        if not UT_HEART_SIMPLE.player_alive then return end
        
        local frame_time = FrameTime()
        local move_speed = UT_HEART_SIMPLE.heart.speed or 0.8
        
        if input.IsKeyDown(KEY_LEFT) then 
            UT_HEART_SIMPLE.heart.x = math.max(0.05, UT_HEART_SIMPLE.heart.x - move_speed * frame_time) 
        end
        if input.IsKeyDown(KEY_RIGHT) then 
            UT_HEART_SIMPLE.heart.x = math.min(0.95, UT_HEART_SIMPLE.heart.x + move_speed * frame_time) 
        end
        if input.IsKeyDown(KEY_UP) then 
            UT_HEART_SIMPLE.heart.y = math.max(0.05, UT_HEART_SIMPLE.heart.y - move_speed * frame_time) 
        end
        if input.IsKeyDown(KEY_DOWN) then 
            UT_HEART_SIMPLE.heart.y = math.min(0.95, UT_HEART_SIMPLE.heart.y + move_speed * frame_time) 
        end
        
        table.insert(UT_HEART_SIMPLE.heart_trail, 1, {
            x = UT_HEART_SIMPLE.heart.x,
            y = UT_HEART_SIMPLE.heart.y
        })
        
        while #UT_HEART_SIMPLE.heart_trail > 25 do
            table.remove(UT_HEART_SIMPLE.heart_trail)
        end
        
        for i = #UT_HEART_SIMPLE.bullets, 1, -1 do
            local bullet = UT_HEART_SIMPLE.bullets[i]
            
            bullet.x = bullet.x + bullet.vx * bullet.speed
            bullet.y = bullet.y + bullet.vy * bullet.speed
            
            local dx = bullet.x - UT_HEART_SIMPLE.heart.x
            local dy = bullet.y - UT_HEART_SIMPLE.heart.y
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < 0.06 then
                UT_HEART_SIMPLE.OnHit()
                table.remove(UT_HEART_SIMPLE.bullets, i)
                continue
            end
            
            if bullet.x < -0.1 or bullet.x > 1.1 or bullet.y < -0.1 or bullet.y > 1.1 then
                table.remove(UT_HEART_SIMPLE.bullets, i)
            end
        end
    end
    
    -- ====== ПОПАДАНИЕ (С МЕРЦАНИЕМ) ======
    function UT_HEART_SIMPLE.OnHit()
        if not UT_HEART_SIMPLE.player_alive then return end
        
        UT_HEART_SIMPLE.player_hp = math.max(0, UT_HEART_SIMPLE.player_hp - 2)
        
        -- Звук урона
        if UT_SOUNDS and UT_SOUNDS.PlayDamageTaken then
            UT_SOUNDS.PlayDamageTaken()
        else
            surface.PlaySound("buttons/button15.wav")
        end
        
        -- ЗАПУСКАЕМ МЕРЦАНИЕ (пропадание спрайта)
        UT_HEART_SIMPLE.damageBlinkTimer = CurTime()
        
        -- Добавляем эффект вибрации
        local originalX = UT_HEART_SIMPLE.heart.x
        local originalY = UT_HEART_SIMPLE.heart.y
        
        local shakeAmount = 0.015
        UT_HEART_SIMPLE.heart.x = math.Clamp(UT_HEART_SIMPLE.heart.x + (math.random() - 0.5) * shakeAmount, 0.05, 0.95)
        UT_HEART_SIMPLE.heart.y = math.Clamp(UT_HEART_SIMPLE.heart.y + (math.random() - 0.5) * shakeAmount, 0.05, 0.95)
        
        timer.Simple(0.1, function()
            if UT_HEART_SIMPLE.is_active and UT_HEART_SIMPLE.player_alive then
                UT_HEART_SIMPLE.heart.x = originalX
                UT_HEART_SIMPLE.heart.y = originalY
            end
        end)
        
        if UT_BATTLE_CORE then
            UT_BATTLE_CORE.playerHp = UT_HEART_SIMPLE.player_hp
        end
        
        -- Отладочное сообщение
        print("[UNDERTALE] Сердце получило урон! HP: " .. UT_HEART_SIMPLE.player_hp .. "/20")
        
        if UT_HEART_SIMPLE.player_hp <= 5 and UT_HEART_SIMPLE.player_hp > 0 then
            chat.AddText(Color(255, 50, 50), "[КРИТИЧЕСКИЙ УРОВЕНЬ] ", Color(255, 255, 255), 
                "HP: " .. UT_HEART_SIMPLE.player_hp .. "/20")
        end
        
        if UT_HEART_SIMPLE.player_hp <= 0 then
            UT_HEART_SIMPLE.player_alive = false
            
            UT_HEART_SIMPLE.Stop()
            
            timer.Simple(2, function()
                UT_HEART_SIMPLE.Stop()
                
                if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                    UT_BATTLE_CORE.battleMode = "MENU"
                    
                    if IsValid(UT_BATTLE_CORE.dialogPanel) then
                        local panel = UT_BATTLE_CORE.dialogPanel
                        panel:SetSize(900, 250)
                        panel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
                        
                        if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                    end
                    
                    chat.AddText(Color(255, 0, 0), "[ПОРАЖЕНИЕ] ", Color(255, 255, 255), 
                        "Вы были побеждены!")
                end
            end)
        end
    end
    
    -- ====== ОСТАНОВКА ======
    function UT_HEART_SIMPLE.Stop()
        print("[UNDERTALE] Остановка простой системы сердца")
        
        UT_HEART_SIMPLE.is_active = false
        UT_HEART_SIMPLE.damageBlinkTimer = 0
        timer.Remove("UT_SimpleHeart_Bullets")
        timer.Remove("UT_SimpleHeart_PhaseEnd")
        hook.Remove("Think", "UT_SimpleHeart_Think")
        
        UT_HEART_SIMPLE.phaseTimer = nil
    end
    
    -- ====== ДЛЯ СОВМЕСТИМОСТИ ======
    if not UT_HEART_CORE then
        UT_HEART_CORE = {}
    end
    
    UT_HEART_CORE.StartHeartPhase = function(enemy_data)
        return UT_HEART_SIMPLE.Start(enemy_data)
    end
    
    UT_HEART_CORE.StopHeartPhase = function()
        UT_HEART_SIMPLE.Stop()
    end
    
    print("[UNDERTALE] Простая система сердца загружена (мерцание пропаданием спрайта)")
end