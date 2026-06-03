-- ФАЙЛ: ut_enemy_data.lua
if CLIENT then
    print("[UNDERTALE] Загрузка данных врагов...")
    
    UT_ENEMY_DATA = UT_ENEMY_DATA or {}
    
    -- Данные врагов
    UT_ENEMY_DATA.enemies = {
        npc_zombie = {
            name = "ЗОМБИ",
            hp = 25,
            maxhp = 25,
            attack = 5,
            defense = 2,
            exp = 10,
            gold = 15,
            check_text = "* ЗОМБИ - HP: 25, ATK: 5, DEF: 2\n* Медленный, но упорный.",
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Зомби пялится в ответ.", info = true },
                { name = "ПОГРОЗИТЬ", text = "* Зомби не понимает угроз." },
                { name = "ЦВЕТОК", text = "* Зомби смотрит в замешательстве." }
            },
            mercy_text = "* Зомби отступает...",
            heart_color = "RED"
        },
        
        npc_combine_s = {
            name = "СОЛДАТ",
            hp = 35,
            maxhp = 35,
            attack = 8,
            defense = 3, 
            exp = 20,
            gold = 25,
            check_text = "* СОЛДАТ - HP: 35, ATK: 8, DEF: 3\n* Обучен тактике и стрельбе.",
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Солдат прицеливается.", info = true },
                { name = "СЛОМАТЬ ОРУЖИЕ", text = "* Оружие слишком прочное." },
                { name = "ПЕРЕГОВОРЫ", text = "* Солдат не реагирует." }
            },
            mercy_text = "* Солдат опускает оружие.",
            heart_color = "BLUE"
        },

                npc_combine = {
            name = "СОЛДАТ",
            hp = 35,
            maxhp = 35,
            attack = 8,
            defense = 3, 
            exp = 20,
            gold = 25,
            check_text = "* СОЛДАТ - HP: 35, ATK: 8, DEF: 3\n* Обучен тактике и стрельбе.",
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Солдат прицеливается.", info = true },
                { name = "СЛОМАТЬ ОРУЖИЕ", text = "* Оружие слишком прочное." },
                { name = "ПЕРЕГОВОРЫ", text = "* Солдат не реагирует." }
            },
            mercy_text = "* Солдат опускает оружие.",
            heart_color = "BLUE"
        },

                        npc_headcrab = {
            name = "ХЕДКРАБ",
            hp = 15,
            maxhp = 15,
            attack = 3,
            defense = 3, 
            exp = 10,
            gold = 15,
            check_text = "* ХЕДКРАБ - HP: 35, ATK: 8, DEF: 3\n* Зеновский Паразит.",
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Хедкраб Насторожен.", info = true },
                { name = "НАПУГАТЬ", text = "* Хедкраб Напуган." },
                { name = "ПОГЛАДИТЬ", text = "* Хедкраб чуствует себя странно." }
            },
            mercy_text = "* Хедкраб Утихомирился.",
            heart_color = "BLUE"
        },
        
        -- Кляйнер (Санс)
        npc_kleiner = {
            name = "КЛЯЙНЕР",
            hp = 1,
            maxhp = 1,
            attack = 999,  -- Игнорируется, используется карма
            defense = 0,
            exp = 0,
            gold = 0,
            isSans = true,  -- Специальный флаг
            
            check_text = "* КЛЯЙНЕР - HP: 1, ATK: 1, DEF: 1\n* Самый Лёгкий Враг.",
            
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Кляйнер улыбается.", info = true },
                { name = "ПОГОВОРИТЬ", text = "* ...\n* Кляйнер молчит." },
                { name = "ПОЖАЛЕТЬ", text = "* ...\n* Но ничего не произошло." }
            },
            
            mercy_text = "* Кляйнер исчезает в вспышке света...",
            heart_color = "BLUE",
            
            -- Используем специальную битву
            specialBattle = "SANS"
        },

        npc_antlion = {
            name = "МУРАВЬИНЫЙ ЛЕВ",
            hp = 45,
            maxhp = 45,
            attack = 10,
            defense = 4,
            exp = 30,
            gold = 35,
            check_text = "* МУРАВЬИНЫЙ ЛЕВ - HP: 45, ATK: 10, DEF: 4\n* Осторожно: сильные челюсти.",
            acts = {
                { name = "ПРОВЕРИТЬ", text = "* Муравьиный лев щёлкает челюстями.", info = true },
                { name = "ПОКОРМИТЬ", text = "* Муравьиный лев отвлекается на еду!" }
            },
            mercy_text = "* Муравьиный лев уходит в песок.",
            heart_color = "RED"
        }
    }
    
    function UT_ENEMY_DATA.Get(class)
        return UT_ENEMY_DATA.enemies[class] or UT_ENEMY_DATA.enemies.npc_zombie
    end
    
    -- ФУНКЦИЯ ДЛЯ ПОКАЗА ПЕЧАТАЮЩЕГОСЯ ТЕКСТА
    function UT_ENEMY_DATA.ShowTypingMessage(message, duration, onComplete)
        if not IsValid(UT_BATTLE_CORE.dialogPanel) then return end
        
        local panel = UT_BATTLE_CORE.dialogPanel
        local fullText = message
        local charIndex = 0
        local displayedText = ""
        local lastCharTime = CurTime()
        local typingSpeed = 0.035
        local isComplete = false
        local hookId = "UT_InfoTyping_" .. tostring(panel)
        
        -- Очищаем старый хук
        if panel.infoTypingActive then
            hook.Remove("Think", hookId)
        end
        panel.infoTypingActive = true
        
        -- Разбиваем на строки для правильного отображения
        local lines = {}
        for line in string.gmatch(fullText, "[^\n]+") do
            table.insert(lines, line)
        end
        if #lines == 0 then
            lines = {fullText}
        end
        
        local function UpdateTyping()
            if not IsValid(panel) then 
                hook.Remove("Think", hookId)
                return 
            end
            
            if isComplete then return end
            
            local currentTime = CurTime()
            
            if currentTime - lastCharTime >= typingSpeed then
                if charIndex < #fullText then
                    charIndex = charIndex + 1
                    displayedText = string.sub(fullText, 1, charIndex)
                    lastCharTime = currentTime
                    
                    -- Звук на каждый символ
                    if UT_SOUNDS and UT_SOUNDS.PlayTypingSound then
                        UT_SOUNDS.PlayTypingSound()
                    end
                    
                    panel:InvalidateLayout()
                else
                    isComplete = true
                    panel.infoTypingActive = false
                    if onComplete then
                        onComplete()
                    end
                    hook.Remove("Think", hookId)
                    
                    -- Через 1.5 секунды возвращаем обычный диалог
                    timer.Simple(duration or 1.5, function()
                        if IsValid(panel) then
                            UT_BATTLE_HUD.UpdateDialogPanel()
                        end
                    end)
                end
            end
        end
        
        hook.Add("Think", hookId, UpdateTyping)
        
        -- Отрисовка с печатанием
        panel.Paint = function(self, w, h)
            draw.RoundedBox(30, 0, 0, w, h, Color(0, 0, 0, 230))
            surface.SetDrawColor(255, 255, 255, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            local xPos = 40
            local yPos = 70
            local lineHeight = 30
            
            -- Разбиваем напечатанный текст на строки
            local typedLines = {}
            for line in string.gmatch(displayedText, "[^\n]+") do
                table.insert(typedLines, line)
            end
            
            -- Рисуем каждую строку
            for i, line in ipairs(typedLines) do
                draw.SimpleText(line, "UT_Pixel", 
                    xPos, yPos + (i-1) * lineHeight, 
                    Color(255, 255, 255), TEXT_ALIGN_LEFT)
            end
            
            -- Мигающий курсор
            if not isComplete and math.floor(CurTime() * 12) % 2 == 0 then
                local lastLine = typedLines[#typedLines] or ""
                surface.SetFont("UT_Pixel")
                local textWidth = surface.GetTextSize(lastLine)
                local cursorY = yPos + (#typedLines - 1) * lineHeight
                
                draw.SimpleText("_", "UT_Pixel", 
                    xPos + textWidth + 5, cursorY,
                    Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            end
            
            -- HP игрока внизу
            draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Pixel_Small", 
                w - 30, h - 30, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
        end
    end
    
    -- ВЫПОЛНЕНИЕ ACT
    function UT_ENEMY_DATA.PerformAct(enemy_class, act_index, current_enemy)
        local enemy_data = UT_ENEMY_DATA.Get(enemy_class)
        if not enemy_data or not enemy_data.acts or not enemy_data.acts[act_index] then
            UT_ENEMY_DATA.ShowTypingMessage("* Ничего не произошло.", 1.5)
            return
        end
        
        local act = enemy_data.acts[act_index]
        
        -- Если действие "ПРОВЕРИТЬ" - показываем информацию о враге с печатанием
        if act.info then
            UT_ENEMY_DATA.ShowTypingMessage(enemy_data.check_text, 2.5)
        else
            -- Обычное действие - показываем текст действия с печатанием
            UT_ENEMY_DATA.ShowTypingMessage(act.text, 2)
        end
    end
    
    print("[UNDERTALE] Данные врагов загружены")
end