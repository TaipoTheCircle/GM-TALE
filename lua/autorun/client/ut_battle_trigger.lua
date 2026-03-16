-- ФАЙЛ: ut_battle_trigger.lua (УСИЛЕННАЯ ЗАЩИТА ОТ УРОНА)
if CLIENT then
    print("[UNDERTALE] Загрузка триггера с РЕАЛЬНЫМИ врагами и УСИЛЕННОЙ НЕУЯЗВИМОСТЬЮ...")
    
    UT_BATTLE_TRIGGER = UT_BATTLE_TRIGGER or {}
    
    UT_BATTLE_TRIGGER.detectionRadius = 300
    UT_BATTLE_TRIGGER.checkInterval = 0.5
    UT_BATTLE_TRIGGER.lastCheck = 0
    UT_BATTLE_TRIGGER.battleEntities = {} -- Реальные entity в текущем бою
    
    -- ФЛАГ ДЛЯ ОТСЛЕЖИВАНИЯ НЕУЯЗВИМОСТИ
    UT_BATTLE_TRIGGER.playerWasInvincible = false
    
    -- ТИПЫ ВРАГОВ (данные для боя)
    UT_BATTLE_TRIGGER.EnemyTypes = {
        ["npc_zombie"] = {
            name = "ЗОМБИ",
            hp = 25,
            maxhp = 25,
            class = "npc_zombie",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 200,
                    count = 8,
                    color = Color(255, 50, 50)
                }
            },
            dialog = {
                "* Зомби медленно приближается...",
                "* Вы чувствуете запах гниения",
                "* Зомби Рычит"
            }
        },
        
        ["npc_combine_s"] = {
            name = "СОЛДАТ",
            hp = 30,
            maxhp = 30,
            class = "npc_combine_s",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 250,
                    count = 12,
                    color = Color(0, 255, 255)
                },
                {
                    type = "WAVE",
                    speed = 180,
                    count = 5,
                    color = Color(255, 255, 0)
                }
            },
            dialog = {
                "* Солдат Overwatch нацеливается на вас",
                "* Слышен звук заряжания оружия",
                '* Солдат Overwatch говорит: "Стоять!"'
            }
        },

        ["npc_combine"] = {
            name = "СОЛДАТ",
            hp = 30,
            maxhp = 30,
            class = "npc_combine",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 250,
                    count = 12,
                    color = Color(0, 255, 255)
                },
                {
                    type = "WAVE",
                    speed = 180,
                    count = 5,
                    color = Color(255, 255, 0)
                }
            },
            dialog = {
                "* Солдат Overwatch нацеливается на вас",
                "* Слышен звук заряжания оружия",
                '* Солдат Overwatch говорит: "Стоять!"'
            }
        },
        
        ["npc_antlion"] = {
            name = "МУРАВЬИННЫЙ ЛЕВ",
            hp = 35,
            maxhp = 35,
            class = "npc_antlion",
            attacks = {
                {
                    type = "CIRCLE",
                    speed = 150,
                    count = 16,
                    color = Color(255, 150, 0)
                }
            },
            dialog = {
                "* Муравьинный Лев рычит",
                "* Муравьинный Лев готовится к прыжку",
                "* Острые когти блестят"
            }
        },
        
        ["npc_antlionworker"] = {
            name = "РАБОЧИЙ МУРАВЬИННЫХ ЛЬВОВ",
            hp = 20,
            maxhp = 20,
            class = "npc_antlionworker",
            attacks = {
                {
                    type = "WAVE",
                    speed = 120,
                    count = 6,
                    color = Color(150, 255, 150)
                }
            },
            dialog = {
                "* Рабочий суетится",
                "* Рабочий выглядит слабее других",
                "* Рабочий все ещё опасен"
            }
        },
        
        ["npc_headcrab"] = {
            name = "ХЕДКРАБ",
            hp = 15,
            maxhp = 15,
            class = "npc_headcrab",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 180,
                    count = 4,
                    color = Color(255, 100, 100)
                }
            },
            dialog = {
                "* Хедкраб прыгает!",
                "* Хедкраб пытается укусить",
                "* Хедкраб - маленький, но опасный"
            }
        },
        
        ["npc_fastzombie"] = {
            name = "БЫСТРЫЙ ЗОМБИ",
            hp = 40,
            maxhp = 40,
            class = "npc_fastzombie",
            attacks = {
                {
                    type = "SNIPER",
                    speed = 300,
                    count = 10,
                    color = Color(255, 0, 0)
                }
            },
            dialog = {
                "* Быстрый зомби бежит!",
                "* Быстрый зомби очень быстрый!",
                "* Будь осторожен!"
            }
        }
    }
    
    -- ФУНКЦИЯ ВКЛЮЧЕНИЯ НЕУЯЗВИМОСТИ
    UT_BATTLE_TRIGGER.EnableInvincibility = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Сохраняем текущее состояние неуязвимости
        UT_BATTLE_TRIGGER.playerWasInvincible = ply:GetNWBool("ut_invincible", false)
        
        -- Включаем неуязвимость (усиленная версия)
        RunConsoleCommand("ut_invincible", "1")
        RunConsoleCommand("ut_protect_player", "1")
        
        print("[UNDERTALE] УСИЛЕННАЯ НЕУЯЗВИМОСТЬ ВКЛЮЧЕНА")
        chat.AddText(Color(0, 255, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
            "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
    end
    
    -- ФУНКЦИЯ ВЫКЛЮЧЕНИЯ НЕУЯЗВИМОСТИ
    UT_BATTLE_TRIGGER.DisableInvincibility = function()
        if not UT_BATTLE_TRIGGER.playerWasInvincible then
            -- Если игрок не был неуязвим до боя, выключаем
            RunConsoleCommand("ut_invincible", "0")
            RunConsoleCommand("ut_protect_player", "0")
            print("[UNDERTALE] Неуязвимость ВЫКЛЮЧЕНА")
            chat.AddText(Color(255, 0, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
                "Вы снова уязвимы в реальном мире!")
        else
            print("[UNDERTALE] Неуязвимость осталась включенной (была включена до боя)")
        end
    end
    
    -- ПОИСК ВСЕХ ВРАГОВ ВОКРУГ
    UT_BATTLE_TRIGGER.FindNearbyEnemies = function(centerPos, radius)
        local enemies = {}
        local allNPCs = ents.FindInSphere(centerPos, radius)
        
        for _, ent in ipairs(allNPCs) do
            if ent:IsNPC() and not ent.BattleTriggered then
                local enemyType = UT_BATTLE_TRIGGER.EnemyTypes[ent:GetClass()]
                if enemyType then
                    table.insert(enemies, {
                        entity = ent,
                        data = enemyType
                    })
                end
            end
        end
        
        return enemies
    end
    
    -- ФУНКЦИЯ ДЛЯ ОСТАНОВКИ NPC (ТОЛЬКО КЛИЕНТСКИЕ МЕТКИ)
    UT_BATTLE_TRIGGER.StopNPC = function(ent)
        if not IsValid(ent) then return end
        
        -- Сохраняем, что NPC был остановлен
        ent.BattleWasStopped = true
        
        print("[UNDERTALE] NPC помечен как остановленный: " .. tostring(ent))
        
        -- Отправляем сообщение на сервер для остановки NPC
        RunConsoleCommand("ut_stop_npc", tostring(ent:EntIndex()))
    end
    
    -- ФУНКЦИЯ ДЛЯ ВОЗОБНОВЛЕНИЯ NPC
    UT_BATTLE_TRIGGER.ResumeNPC = function(ent)
        if not IsValid(ent) then return end
        
        -- Убираем метку остановки
        ent.BattleWasStopped = nil
        
        print("[UNDERTALE] NPC возобновлен: " .. tostring(ent))
        
        -- Отправляем сообщение на сервер для возобновления NPC
        RunConsoleCommand("ut_resume_npc", tostring(ent:EntIndex()))
    end
    
    -- ЗАПУСК БОЯ С РЕАЛЬНЫМИ ВРАГАМИ
    UT_BATTLE_TRIGGER.StartRealBattle = function(triggerEnemy)
        print("[UNDERTALE] ===== ЗАПУСК РЕАЛЬНОГО БОЯ =====")
        
        if not UT_BATTLE_CORE then
            print("[UNDERTALE] ОШИБКА: Ядро не загружено!")
            return 
        end
        
        if UT_BATTLE_CORE.battleActive then
            print("[UNDERTALE] Триггер: Бой уже активен")
            return 
        end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- ВКЛЮЧАЕМ УСИЛЕННУЮ НЕУЯЗВИМОСТЬ В РЕАЛЬНОМ МИРЕ
        UT_BATTLE_TRIGGER.EnableInvincibility()
        
        -- Находим ВСЕХ врагов в радиусе
        local nearbyEnemies = UT_BATTLE_TRIGGER.FindNearbyEnemies(ply:GetPos(), UT_BATTLE_TRIGGER.detectionRadius)
        
        if #nearbyEnemies == 0 then
            print("[UNDERTALE] Нет врагов поблизости")
            return
        end
        
        print("[UNDERTALE] Найдено врагов: " .. #nearbyEnemies)
        
        -- Помечаем всех врагов как участвующих в бою
        UT_BATTLE_TRIGGER.battleEntities = {}
        UT_BATTLE_CORE.currentTargets = {}
        
        -- Создаем список врагов для боя
        for i, enemyInfo in ipairs(nearbyEnemies) do
            local ent = enemyInfo.entity
            local data = enemyInfo.data
            
            -- Помечаем врага
            ent.BattleTriggered = true
            ent.InRealBattle = true
            table.insert(UT_BATTLE_TRIGGER.battleEntities, ent)
            
            -- ОСТАНАВЛИВАЕМ NPC
            UT_BATTLE_TRIGGER.StopNPC(ent)
            
            -- Добавляем в список целей
            table.insert(UT_BATTLE_CORE.currentTargets, {
                name = data.name,
                class = ent:GetClass(),
                hp = data.hp,
                maxhp = data.maxhp,
                entity = ent,
                attacks = data.attacks,
                dialog = data.dialog,
                isReal = true
            })
            
            print("[UNDERTALE] Добавлен враг: " .. data.name)
        end
        
        -- Выбираем первого врага как текущего для диалога
        UT_BATTLE_CORE.currentEnemy = {
            entity = nearbyEnemies[1].entity,
            data = nearbyEnemies[1].data,
            currentAttack = 1
        }
        
        -- Запускаем музыку
        if UT_BATTLE_MUSIC and UT_BATTLE_MUSIC.Start then
            UT_BATTLE_MUSIC.Start({class = "default"})
        end
        
        -- Показываем сообщение о начале боя
        local enemyNames = ""
        for i, target in ipairs(UT_BATTLE_CORE.currentTargets) do
            enemyNames = enemyNames .. target.name
            if i < #UT_BATTLE_CORE.currentTargets then
                enemyNames = enemyNames .. ", "
            end
        end
        
        chat.AddText(Color(255, 50, 50), "[БОЙ НАЧАТ!] ", Color(255, 255, 255), 
            "Вы встретили: " .. enemyNames)
        chat.AddText(Color(255, 255, 0), "[СИСТЕМА] ", Color(255, 255, 255), 
            "В бою " .. #UT_BATTLE_CORE.currentTargets .. " врагов!")
        chat.AddText(Color(0, 255, 0), "[УСИЛЕННАЯ НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
            "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
        
        -- Создаем меню боя
        timer.Simple(1, function()
            if UT_BATTLE_HUD and UT_BATTLE_HUD.CreateBattleMenu then
                UT_BATTLE_HUD.CreateBattleMenu()
            end
        end)
    end
    
    -- ПОИСК ВРАГОВ
    UT_BATTLE_TRIGGER.FindEnemies = function()
        if not UT_BATTLE_CORE then 
            return 
        end
        
        if UT_BATTLE_CORE.battleActive == true then
            return 
        end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Ищем первого врага для триггера
        local enemies = ents.FindInSphere(ply:GetPos(), UT_BATTLE_TRIGGER.detectionRadius)
        
        for _, ent in pairs(enemies) do
            if ent:IsNPC() and not ent.BattleTriggered then
                local enemyType = UT_BATTLE_TRIGGER.EnemyTypes[ent:GetClass()]
                
                if enemyType then
                    print("[UNDERTALE] Обнаружен враг: "..enemyType.name)
                    
                    -- Запускаем бой со ВСЕМИ врагами рядом
                    UT_BATTLE_TRIGGER.StartRealBattle(ent)
                    break
                end
            end
        end
    end
    
    -- ФУНКЦИЯ ДЛЯ УБИЙСТВА РЕАЛЬНЫХ ВРАГОВ
    UT_BATTLE_TRIGGER.KillRealEnemy = function(enemyData)
        if not enemyData or not enemyData.entity or not IsValid(enemyData.entity) then 
            return 
        end
        
        local ent = enemyData.entity
        print("[UNDERTALE] Убиваем реального врага: " .. tostring(ent))
        
        -- Возвращаем нормальное состояние перед смертью
        UT_BATTLE_TRIGGER.ResumeNPC(ent)
        
        -- На клиенте мы не можем убить NPC напрямую, отправляем команду на сервер
        RunConsoleCommand("ut_kill_npc", tostring(ent:EntIndex()))
        
        -- Удаляем из списка
        for i, battleEnt in ipairs(UT_BATTLE_TRIGGER.battleEntities) do
            if battleEnt == ent then
                table.remove(UT_BATTLE_TRIGGER.battleEntities, i)
                break
            end
        end
    end
    
    -- ПРОВЕРКА ОКОНЧАНИЯ БОЯ
    UT_BATTLE_TRIGGER.CheckBattleEnd = function()
        if not UT_BATTLE_CORE or not UT_BATTLE_CORE.currentTargets then 
            return false 
        end
        
        -- Проверяем, все ли реальные враги мертвы
        local allDead = true
        for _, target in ipairs(UT_BATTLE_CORE.currentTargets) do
            if target.hp > 0 then
                allDead = false
                break
            end
        end
        
        if allDead and #UT_BATTLE_CORE.currentTargets > 0 then
            print("[UNDERTALE] Все враги побеждены! Убиваем реальных...")
            
            -- Убиваем всех реальных врагов
            for _, target in ipairs(UT_BATTLE_CORE.currentTargets) do
                if target.entity and IsValid(target.entity) then
                    UT_BATTLE_TRIGGER.KillRealEnemy(target)
                end
            end
            
            -- Возвращаем оставшихся в нормальное состояние
            for _, ent in ipairs(UT_BATTLE_TRIGGER.battleEntities) do
                if IsValid(ent) then
                    UT_BATTLE_TRIGGER.ResumeNPC(ent)
                end
            end
            
            UT_BATTLE_TRIGGER.battleEntities = {}
            
            return true
        end
        
        return false
    end
    
    -- СБРОС ТРИГГЕРОВ
    UT_BATTLE_TRIGGER.ResetTriggers = function()
        print("[UNDERTALE] Сброс триггеров врагов")
        
        local npcs = ents.FindByClass("npc_*")
        for _, npc in pairs(npcs) do
            if npc.BattleTriggered then
                npc.BattleTriggered = false
            end
            if npc.InRealBattle then
                npc.InRealBattle = false
                UT_BATTLE_TRIGGER.ResumeNPC(npc)
            end
        end
        
        UT_BATTLE_TRIGGER.battleEntities = {}
    end
    
    -- ХУК ДЛЯ ПРОВЕРКИ ОКОНЧАНИЯ БОЯ
    hook.Add("Think", "UT_CheckRealBattleEnd", function()
        if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
            if UT_BATTLE_TRIGGER.CheckBattleEnd() then
                timer.Simple(2, function()
                    if UT_BATTLE_CORE and UT_BATTLE_CORE.battleActive then
                        UT_BATTLE_CORE.EndBattle(true)
                        -- ВЫКЛЮЧАЕМ НЕУЯЗВИМОСТЬ ПОСЛЕ БОЯ
                        UT_BATTLE_TRIGGER.DisableInvincibility()
                    end
                end)
            end
        end
    end)
    
    -- ХУК ДЛЯ ОБРАБОТКИ ПРЕЖДЕВРЕМЕННОГО ЗАВЕРШЕНИЯ БОЯ
    hook.Add("UT_BattleEnded", "UT_DisableInvincibility", function()
        UT_BATTLE_TRIGGER.DisableInvincibility()
    end)
    
    -- ИНИЦИАЛИЗАЦИЯ
    UT_BATTLE_TRIGGER.Initialize = function()
        print("[UNDERTALE] Инициализация РЕАЛЬНОГО триггера боя с УСИЛЕННОЙ НЕУЯЗВИМОСТЬЮ")
        
        UT_BATTLE_TRIGGER.detectionRadius = UT_BATTLE_TRIGGER.detectionRadius or 300
        UT_BATTLE_TRIGGER.checkInterval = UT_BATTLE_TRIGGER.checkInterval or 0.5
        UT_BATTLE_TRIGGER.lastCheck = UT_BATTLE_TRIGGER.lastCheck or 0
        UT_BATTLE_TRIGGER.battleEntities = UT_BATTLE_TRIGGER.battleEntities or {}
        
        UT_BATTLE_TRIGGER.ResetTriggers()
        
        hook.Add("Think", "UT_BattleTrigger", function()
            if not UT_BATTLE_CORE then return end
            
            if not UT_BATTLE_TRIGGER.lastCheck then 
                UT_BATTLE_TRIGGER.lastCheck = CurTime() 
            end
            
            if CurTime() - UT_BATTLE_TRIGGER.lastCheck > UT_BATTLE_TRIGGER.checkInterval then
                UT_BATTLE_TRIGGER.FindEnemies()
                UT_BATTLE_TRIGGER.lastCheck = CurTime()
            end
        end)
        
        concommand.Add("ut_reset_triggers", function()
            UT_BATTLE_TRIGGER.ResetTriggers()
            chat.AddText(Color(0, 255, 0), "[ТРИГГЕРЫ] ", Color(255, 255, 255), 
                "Все триггеры врагов сброшены!")
        end)
        
        concommand.Add("ut_test_real_battle", function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return end
            
            local enemies = UT_BATTLE_TRIGGER.FindNearbyEnemies(ply:GetPos(), 500)
            if #enemies > 0 then
                UT_BATTLE_TRIGGER.StartRealBattle(enemies[1].entity)
            else
                chat.AddText(Color(255, 0, 0), "[ТЕСТ] ", Color(255, 255, 255), 
                    "Рядом нет врагов!")
            end
        end)
    end
    
    timer.Simple(5, function()
        UT_BATTLE_TRIGGER.Initialize()
        print("[UNDERTALE] Реальный триггер боя с усиленной неуязвимостью готов к работе")
        chat.AddText(Color(0, 255, 255), "[UNDERTALE] ", Color(255, 255, 255), 
            "РЕАЛЬНЫЙ бой активирован. Подойдите к врагам!")
        chat.AddText(Color(0, 255, 0), "[УСИЛЕННАЯ НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
            "На время боя вы ПОЛНОСТЬЮ НЕУЯЗВИМЫ в реальном мире!")
    end)
    
    print("[UNDERTALE] Реальный триггер боя с усиленной неуязвимостью загружен")
end

-- СЕРВЕРНАЯ ЧАСТЬ (для управления NPC и усиленной неуязвимостью)
if SERVER then
    print("[UNDERTALE] Загрузка серверной части триггера с УСИЛЕННОЙ НЕУЯЗВИМОСТЬЮ...")
    
    -- Переменная для хранения состояния неуязвимости игроков
    util.AddNetworkString("ut_invincible_status")
    
    -- Остановка NPC
    concommand.Add("ut_stop_npc", function(ply, cmd, args)
        if not args[1] then return end
        local entIndex = tonumber(args[1])
        local ent = Entity(entIndex)
        
        if IsValid(ent) and ent:IsNPC() then
            ent:SetSchedule(SCHED_IDLE_STAND)
            ent:SetEnemy(NULL)
            print("[UNDERTALE SERVER] NPC остановлен: " .. entIndex)
        end
    end)
    
    -- Возобновление NPC
    concommand.Add("ut_resume_npc", function(ply, cmd, args)
        if not args[1] then return end
        local entIndex = tonumber(args[1])
        local ent = Entity(entIndex)
        
        if IsValid(ent) and ent:IsNPC() then
            ent:SetSchedule(SCHED_IDLE_WANDER)
            print("[UNDERTALE SERVER] NPC возобновлен: " .. entIndex)
        end
    end)
    
    -- Убийство NPC
    concommand.Add("ut_kill_npc", function(ply, cmd, args)
        if not args[1] then return end
        local entIndex = tonumber(args[1])
        local ent = Entity(entIndex)
        
        if IsValid(ent) and ent:IsNPC() then
            ent:TakeDamage(ent:Health() + 100, ply, ply)
            ent:Remove()
            print("[UNDERTALE SERVER] NPC убит: " .. entIndex)
        end
    end)
    
    -- Переменная для отслеживания защищенных игроков
    UT_ProtectedPlayers = UT_ProtectedPlayers or {}
    
    -- Включение/выключение усиленной неуязвимости
    concommand.Add("ut_invincible", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if not args[1] then return end
        
        local enable = tonumber(args[1]) == 1
        
        if enable then
            ply:SetNWBool("ut_invincible", true)
            UT_ProtectedPlayers[ply] = true
            ply:GodEnable()
            print("[UNDERTALE SERVER] Усиленная неуязвимость включена для " .. ply:Name())
        else
            ply:SetNWBool("ut_invincible", false)
            UT_ProtectedPlayers[ply] = nil
            ply:GodDisable()
            print("[UNDERTALE SERVER] Усиленная неуязвимость выключена для " .. ply:Name())
        end
        
        -- Отправляем статус всем клиентам
        net.Start("ut_invincible_status")
        net.WriteEntity(ply)
        net.WriteBool(enable)
        net.Broadcast()
    end)
    
    -- Дополнительная команда для максимальной защиты
    concommand.Add("ut_protect_player", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if not args[1] then return end
        
        local enable = tonumber(args[1]) == 1
        
        if enable then
            UT_ProtectedPlayers[ply] = true
            print("[UNDERTALE SERVER] Максимальная защита включена для " .. ply:Name())
        else
            UT_ProtectedPlayers[ply] = nil
            print("[UNDERTALE SERVER] Максимальная защита выключена для " .. ply:Name())
        end
    end)
    
    -- Защита от снятия неуязвимости во время боя
    hook.Add("PlayerGodDisable", "UT_ProtectInvincibility", function(ply)
        if ply:GetNWBool("ut_invincible", false) then
            -- Если неуязвимость должна быть включена, не даем ее выключить
            return true
        end
    end)
    
    -- УСИЛЕННАЯ защита от урона во время боя
    hook.Add("EntityTakeDamage", "UT_SuperProtectPlayerInBattle", function(target, dmgInfo)
        if not IsValid(target) or not target:IsPlayer() then return end
        
        -- Проверяем оба флага защиты
        if target:GetNWBool("ut_invincible", false) or UT_ProtectedPlayers[target] then
            -- Полностью блокируем урон
            dmgInfo:SetDamage(0)
            
            -- Дополнительно: удаляем все эффекты урона
            dmgInfo:SetDamageForce(Vector(0, 0, 0))
            dmgInfo:SetDamagePosition(target:GetPos())
            
            -- Отменяем любой возможный урон
            return true
        end
    end)
    
    -- Защита от взрывов и другого Area of Effect урона
    hook.Add("ScalePlayerDamage", "UT_ProtectFromAoE", function(ply, hitgroup, dmginfo)
        if ply:GetNWBool("ut_invincible", false) or UT_ProtectedPlayers[ply] then
            dmginfo:SetDamage(0)
            return true
        end
    end)
    
    -- Защита от огня и других типов урона
    hook.Add("PlayerShouldTakeDamage", "UT_BlockAllDamage", function(ply, attacker)
        if ply:GetNWBool("ut_invincible", false) or UT_ProtectedPlayers[ply] then
            return false
        end
    end)
    
    print("[UNDERTALE] Серверная часть триггера с усиленной неуязвимостью загружена")
end

-- КЛИЕНТСКАЯ ЧАСТЬ ДЛЯ ОБРАБОТКИ СТАТУСА НЕУЯЗВИМОСТИ
if CLIENT then
    net.Receive("ut_invincible_status", function()
        local ply = net.ReadEntity()
        local enabled = net.ReadBool()
        
        if ply == LocalPlayer() then
            if enabled then
                chat.AddText(Color(0, 255, 0), "[УСИЛЕННАЯ НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
                    "Статус: ВКЛЮЧЕНО (вы ПОЛНОСТЬЮ неуязвимы в реальном мире)")
            else
                chat.AddText(Color(255, 0, 0), "[НЕУЯЗВИМОСТЬ] ", Color(255, 255, 255), 
                    "Статус: ВЫКЛЮЧЕНО")
            end
        end
    end)
end