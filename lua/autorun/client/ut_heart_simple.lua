-- ФАЙЛ: ut_heart_simple.lua (ОБНОВЛЕННЫЙ - БЕЗ ТЕКСТА, СЕТКИ И ОБВОДКИ СЕРДЦА)
-- РАЗМЕСТИТЕ: addons/gm-tale/lua/autorun/client/

if CLIENT then
    print("[UNDERTALE] Загрузка простой системы сердца...")
    
    UT_HEART_SIMPLE = UT_HEART_SIMPLE or {}
    
    -- ====== СОСТОЯНИЕ ======
    UT_HEART_SIMPLE.is_active = false
    UT_HEART_SIMPLE.player_hp = 20
    UT_HEART_SIMPLE.player_alive = true
    UT_HEART_SIMPLE.heart_trail = {}
    
    -- ====== ЗАПУСК ======
    function UT_HEART_SIMPLE.Start(enemy_data)
        print("[UNDERTALE] Запуск простой системы сердца")
        
        -- Останавливаем предыдущую
        UT_HEART_SIMPLE.Stop()
        
        -- Настройки
        UT_HEART_SIMPLE.is_active = true
        UT_HEART_SIMPLE.player_hp = 20
        UT_HEART_SIMPLE.player_alive = true
        UT_HEART_SIMPLE.heart_trail = {}
        
        -- Сердце
        UT_HEART_SIMPLE.heart = {
            x = 0.5,
            y = 0.5,
            size = 20,
            speed = 0.8
        }
        
        -- Снаряды
        UT_HEART_SIMPLE.bullets = {}
        
        -- Изменяем размер панели на квадрат (ЧИСТЫЙ БЕЗ ТЕКСТА)
        if IsValid(UT_BATTLE_CORE.dialogPanel) then
            local panel = UT_BATTLE_CORE.dialogPanel
            
            -- Делаем квадрат (350x350)
            panel:SetSize(350, 350)
            panel:SetPos(ScrW()/2 - 175, ScrH()/2 + 20)
            
            -- Новая функция отрисовки (БЕЗ ТЕКСТА И СЕТКИ И БЕЗ ОБВОДКИ СЕРДЦА)
            panel.Paint = function(self, w, h)
                -- Фон панели (полностью черный)
                draw.RoundedBox(15, 0, 0, w, h, Color(0, 0, 0, 240))
                
                -- Границы игрового поля
                local padding = 30
                local game_left = padding
                local game_top = padding
                local game_right = w - padding
                local game_bottom = h - padding
                local game_width = game_right - game_left
                local game_height = game_bottom - game_top
                
                -- Фон игрового поля (темный)
                surface.SetDrawColor(10, 10, 20, 220)
                surface.DrawRect(game_left, game_top, game_width, game_height)
                
                -- Простая обводка игрового поля (без сетки)
                surface.SetDrawColor(255, 255, 255, 80)
                surface.DrawOutlinedRect(game_left, game_top, game_width, game_height, 2)
                
                -- Загружаем спрайт сердца один раз (оптимизация)
                local heart_material = Material("undertale/hearth.png", "noclamp smooth")
                local has_heart_sprite = not heart_material:IsError()
                
                
                -- СНАРЯДЫ
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
                        
                        -- Обводка для квадратных снарядов
                        surface.SetDrawColor(0, 0, 0, 150)
                        surface.DrawOutlinedRect(bx - 6, by - 6, 12, 12, 1)
                    end
                end
                
                -- СЕРДЦЕ (БЕЗ БЕЛОЙ ОБВОДКИ ВОКРУГ!)
                if UT_HEART_SIMPLE.player_alive then
                    local hx = game_left + UT_HEART_SIMPLE.heart.x * game_width
                    local hy = game_top + UT_HEART_SIMPLE.heart.y * game_height
                    
                    if has_heart_sprite then
                        -- Рисуем спрайт сердца (ТОЛЬКО СПРАЙТ, БЕЗ ОБВОДКИ)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(heart_material)
                        local heart_size = UT_HEART_SIMPLE.heart.size * 2  -- Увеличиваем размер для спрайта
                        surface.DrawTexturedRect(
                            hx - heart_size/2, 
                            hy - heart_size/2, 
                            heart_size, 
                            heart_size
                        )
                    else
                        -- Запасной вариант: красный ромб если спрайт не найден (ТОЖЕ БЕЗ ОБВОДКИ)
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
                    
                    -- ⛔⛔⛔ УБРАЛИ ЭТУ ОБВОДКУ ВОКРУГ СЕРДЦА ⛔⛔⛔
                    -- surface.SetDrawColor(255, 255, 255, 80)
                    -- surface.DrawOutlinedRect(
                    --     hx - UT_HEART_SIMPLE.heart.size - 1,
                    --     hy - UT_HEART_SIMPLE.heart.size - 1,
                    --     UT_HEART_SIMPLE.heart.size * 2 + 2,
                    --     UT_HEART_SIMPLE.heart.size * 2 + 2,
                    --     1
                    -- )
                end
                
                -- БЕЗ ТЕКСТА ВЕРХУ И ВНИЗУ - ТОЛЬКО ИГРОВОЕ ПОЛЕ
            end
        end
        
        -- Первые снаряды
        timer.Simple(1, function()
            if UT_HEART_SIMPLE.is_active then
                UT_HEART_SIMPLE.CreateBullets()
            end
        end)
        
        -- Таймер для новых снарядов
        timer.Create("UT_SimpleHeart_Bullets", 2.0, 0, function()
            if UT_HEART_SIMPLE.is_active then
                UT_HEART_SIMPLE.CreateBullets()
            end
        end)
        
        -- Хук для обновления
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
            
            if start_side == 1 then -- Сверху
                x = math.random() * 0.8 + 0.1
                y = -0.05
                vx = (math.random() - 0.5) * 0.2
                vy = 0.4
            elseif start_side == 2 then -- Справа
                x = 1.05
                y = math.random() * 0.8 + 0.1
                vx = -0.4
                vy = (math.random() - 0.5) * 0.2
            elseif start_side == 3 then -- Снизу
                x = math.random() * 0.8 + 0.1
                y = 1.05
                vx = (math.random() - 0.5) * 0.2
                vy = -0.4
            else -- Слева
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
        
        -- Управление сердцем
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
        
        -- ХВОСТ (УВЕЛИЧИЛИ ДЛИНУ И ЧАСТОТУ ОБНОВЛЕНИЯ)
        table.insert(UT_HEART_SIMPLE.heart_trail, 1, {
            x = UT_HEART_SIMPLE.heart.x,
            y = UT_HEART_SIMPLE.heart.y
        })
        
        -- УВЕЛИЧИВАЕМ МАКСИМАЛЬНУЮ ДЛИНУ ХВОСТА
        while #UT_HEART_SIMPLE.heart_trail > 25 do  -- БЫЛО 20, СТАЛО 25
            table.remove(UT_HEART_SIMPLE.heart_trail)
        end
        
        -- Обновление снарядов
        for i = #UT_HEART_SIMPLE.bullets, 1, -1 do
            local bullet = UT_HEART_SIMPLE.bullets[i]
            
            bullet.x = bullet.x + bullet.vx * bullet.speed
            bullet.y = bullet.y + bullet.vy * bullet.speed
            
            -- Проверка столкновения
            local dx = bullet.x - UT_HEART_SIMPLE.heart.x
            local dy = bullet.y - UT_HEART_SIMPLE.heart.y
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < 0.06 then
                UT_HEART_SIMPLE.OnHit()
                table.remove(UT_HEART_SIMPLE.bullets, i)
                continue
            end
            
            -- Удаление за пределами
            if bullet.x < -0.1 or bullet.x > 1.1 or bullet.y < -0.1 or bullet.y > 1.1 then
                table.remove(UT_HEART_SIMPLE.bullets, i)
            end
        end
    end
    
    -- ====== ПОПАДАНИЕ ======
    function UT_HEART_SIMPLE.OnHit()
        if not UT_HEART_SIMPLE.player_alive then return end
        
        UT_HEART_SIMPLE.player_hp = math.max(0, UT_HEART_SIMPLE.player_hp - 2)
        
        surface.PlaySound("buttons/button15.wav")
        
        if UT_BATTLE_CORE then
            UT_BATTLE_CORE.playerHp = UT_HEART_SIMPLE.player_hp
        end
        
        if UT_HEART_SIMPLE.player_hp <= 0 then
            UT_HEART_SIMPLE.player_alive = false
            
            timer.Simple(2, function()
                UT_HEART_SIMPLE.Stop()
                
                if UT_BATTLE_CORE then
                    UT_BATTLE_CORE.battleMode = "MENU"
                    
                    if IsValid(UT_BATTLE_CORE.dialogPanel) then
                        local panel = UT_BATTLE_CORE.dialogPanel
                        panel:SetSize(900, 250)
                        panel:SetPos(ScrW()/2 - 450, ScrH() * 0.55)
                        
                        if UT_BATTLE_HUD and UT_BATTLE_HUD.UpdateDialogPanel then
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                    end
                    
                    chat.AddText(Color(255, 0, 0), "[ПОРАЖЕНИЕ] ", Color(255, 255, 255), "Вы были побеждены!")
                end
            end)
        end
    end
    
    -- ====== ОСТАНОВКА ======
    function UT_HEART_SIMPLE.Stop()
        print("[UNDERTALE] Остановка простой системы сердца")
        
        UT_HEART_SIMPLE.is_active = false
        timer.Remove("UT_SimpleHeart_Bullets")
        hook.Remove("Think", "UT_SimpleHeart_Think")
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
    
    print("[UNDERTALE] Простая система сердца загружена")
end