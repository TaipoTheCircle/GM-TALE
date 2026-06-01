-- ФАЙЛ: ut_typing.lua (ПОЛНАЯ СИСТЕМА ПЕЧАТАНИЯ)
if CLIENT then
    print("[UNDERTALE] Загрузка системы печатания текста...")
    
    UT_TYPING = UT_TYPING or {}
    
    -- Активные текстовые анимации
    UT_TYPING.activeMessages = {}
    
    -- Показать текст с эффектом печатания
    function UT_TYPING.ShowTypingMessage(message, duration, onComplete, skipSound)
        if not message or message == "" then return end
        
        local id = SysTime()
        local fullText = message
        
        local typingData = {
            id = id,
            fullText = fullText,
            displayedText = "",
            charIndex = 0,
            isComplete = false,
            startTime = CurTime(),
            duration = duration or (#fullText * 0.03 + 1.5),
            onComplete = onComplete,
            lastCharTime = CurTime(),
            typingSpeed = 0.03,  -- 30 мс на символ
            lastSoundTime = 0,
            skipSound = skipSound or false
        }
        
        table.insert(UT_TYPING.activeMessages, typingData)
        
        -- Первый звук
        if not skipSound and UT_SOUNDS and UT_SOUNDS.PlayTypingSound then
            UT_SOUNDS.PlayTypingSound()
            typingData.lastSoundTime = CurTime()
        end
        
        UT_TYPING.StartTypingHooks()
        
        return id
    end
    
    -- Показать текст в диалоговой панели с печатанием
    function UT_TYPING.ShowDialogText(message, panel, onComplete)
        if not IsValid(panel) then return end
        
        local fullText = message
        local charIndex = 0
        local displayedText = ""
        local lastCharTime = CurTime()
        local typingSpeed = 0.025
        local isComplete = false
        local lastSoundTime = 0
        
        -- Сохраняем данные в панели
        panel.typingData = {
            fullText = fullText,
            displayedText = "",
            charIndex = 0,
            isComplete = false,
            typingSpeed = typingSpeed,
            lastCharTime = CurTime(),
            lastSoundTime = 0,
            onComplete = onComplete
        }
        
        -- Создаем хук для этого панели
        local function UpdateTyping()
            if not IsValid(panel) then 
                hook.Remove("Think", "UT_DialogTyping_" .. tostring(panel:EntIndex()))
                return 
            end
            
            local data = panel.typingData
            if not data or data.isComplete then return end
            
            local currentTime = CurTime()
            
            if currentTime - data.lastCharTime >= data.typingSpeed then
                if data.charIndex < #data.fullText then
                    data.charIndex = data.charIndex + 1
                    data.displayedText = string.sub(data.fullText, 1, data.charIndex)
                    data.lastCharTime = currentTime
                    
                    -- Звук на каждый символ
                    if currentTime - data.lastSoundTime >= 0.02 then
                        if UT_SOUNDS and UT_SOUNDS.PlayTypingSound then
                            UT_SOUNDS.PlayTypingSound()
                        end
                        data.lastSoundTime = currentTime
                    end
                    
                    -- Обновляем отрисовку панели
                    if panel.PaintOverride then
                        panel.PaintOverride()
                    end
                else
                    data.isComplete = true
                    if data.onComplete then
                        data.onComplete()
                    end
                    hook.Remove("Think", "UT_DialogTyping_" .. tostring(panel:EntIndex()))
                end
            end
        end
        
        hook.Add("Think", "UT_DialogTyping_" .. tostring(panel:EntIndex()), UpdateTyping)
        
        -- Обновляем отрисовку панели
        panel.PaintOverride = function()
            local data = panel.typingData
            if data and data.displayedText then
                -- Рисуем фон
                draw.RoundedBox(30, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 230))
                surface.SetDrawColor(255, 255, 255, 150)
                surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall(), 2)
                
                -- Рисуем текст
                draw.SimpleText(data.displayedText, "UT_Menu", 
                    panel:GetWide()/2, panel:GetTall()/2 - 20, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Мигающий курсор
                if not data.isComplete and math.floor(CurTime() * 10) % 2 == 0 then
                    local textWidth = draw.GetTextSize(data.displayedText, "UT_Menu")
                    draw.SimpleText("_", "UT_Menu", 
                        panel:GetWide()/2 + textWidth/2 + 10, panel:GetTall()/2 - 20,
                        Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
                
                -- HP игрока внизу
                draw.SimpleText("ВАШЕ HP: "..(UT_BATTLE_CORE and UT_BATTLE_CORE.playerHp or 20).."/20", "UT_Menu", 
                    panel:GetWide()/2, panel:GetTall() - 30, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER)
                return true
            end
            return false
        end
    end
    
    -- Запустить хуки для анимации
    function UT_TYPING.StartTypingHooks()
        if UT_TYPING.hooksStarted then return end
        UT_TYPING.hooksStarted = true
        
        -- Хук для обновления печатания
        hook.Add("Think", "UT_TypingThink", function()
            local anyActive = false
            
            for i, data in ipairs(UT_TYPING.activeMessages) do
                anyActive = true
                
                if not data.isComplete then
                    local currentTime = CurTime()
                    
                    if currentTime - data.lastCharTime >= data.typingSpeed then
                        if data.charIndex < #data.fullText then
                            data.charIndex = data.charIndex + 1
                            data.displayedText = string.sub(data.fullText, 1, data.charIndex)
                            data.lastCharTime = currentTime
                            
                            -- Звук на каждый символ
                            if not data.skipSound and currentTime - data.lastSoundTime >= 0.02 then
                                if UT_SOUNDS and UT_SOUNDS.PlayTypingSound then
                                    UT_SOUNDS.PlayTypingSound()
                                end
                                data.lastSoundTime = currentTime
                            end
                        else
                            data.isComplete = true
                        end
                    end
                end
            end
            
            -- Удаляем завершенные сообщения
            for i = #UT_TYPING.activeMessages, 1, -1 do
                local data = UT_TYPING.activeMessages[i]
                if data.isComplete and CurTime() - data.startTime >= data.duration then
                    if data.onComplete then
                        data.onComplete()
                    end
                    table.remove(UT_TYPING.activeMessages, i)
                end
            end
            
            if not anyActive then
                hook.Remove("Think", "UT_TypingThink")
                hook.Remove("HUDPaint", "UT_TypingDraw")
                UT_TYPING.hooksStarted = false
            end
        end)
        
        -- Хук для отрисовки текста
        hook.Add("HUDPaint", "UT_TypingDraw", function()
            local yOffset = 0
            
            for i, data in ipairs(UT_TYPING.activeMessages) do
                if data.displayedText and data.displayedText ~= "" then
                    local alpha = 255
                    local fadeStart = data.duration - 0.5
                    if CurTime() - data.startTime > fadeStart then
                        local fadeProgress = (CurTime() - (data.startTime + fadeStart)) / 0.5
                        alpha = 255 * (1 - fadeProgress)
                    end
                    
                    draw.SimpleText(
                        data.displayedText,
                        "UT_Menu",
                        ScrW() / 2,
                        ScrH() * 0.7 + yOffset,
                        Color(255, 255, 255, alpha),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )
                    
                    -- Мигающий курсор
                    if not data.isComplete and math.floor(CurTime() * 12) % 2 == 0 then
                        local textWidth = draw.GetTextSize(data.displayedText, "UT_Menu")
                        draw.SimpleText(
                            "_",
                            "UT_Menu",
                            ScrW() / 2 + textWidth/2 + 5,
                            ScrH() * 0.7 + yOffset,
                            Color(255, 255, 255, alpha),
                            TEXT_ALIGN_LEFT,
                            TEXT_ALIGN_CENTER
                        )
                    end
                    
                    yOffset = yOffset + 35
                end
            end
        end)
    end
    
    -- Очистить все сообщения
    function UT_TYPING.ClearMessages()
        UT_TYPING.activeMessages = {}
        hook.Remove("Think", "UT_TypingThink")
        hook.Remove("HUDPaint", "UT_TypingDraw")
        UT_TYPING.hooksStarted = false
    end
    
    print("[UNDERTALE] Система печатания текста загружена")
end