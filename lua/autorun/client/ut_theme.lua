-- ФАЙЛ: ut_theme.lua
-- Стили и цвета для интерфейса, как в Undertale
if CLIENT then
    UT_THEME = UT_THEME or {}

    -- Цвета для UI (точь-в-точь как в игре)
    UT_THEME.Colors = {
        HP_GOOD    = Color(164, 0,  0,   255),   -- тёмно-красный (неон)
        HP_LOW     = Color(255, 64,  64,  255),   -- ярко-красный при <30%
        HP_CRIT    = Color(255, 128, 0,   255),   -- оранжевый мигающий
        TEXT_MAIN  = Color(255, 255, 255, 255),
        TEXT_DIM   = Color(200, 200, 200, 200),
        BORDER     = Color(80,  80,  80,  255),
        PANEL_BG   = Color(0,   0,   0,   200),
    }

    -- Шрифты (используем те, что у вас уже есть)
    UT_THEME.Fonts = {
        Name  = "UT_PlayerName",   -- для имени
        LV    = "UT_Small",        -- для "LV"
        HPLabel = "UT_Small",      -- для "HP"
        HPValue  = "UT_Pixel_Small", -- для цифр HP
    }

    -- Позиции внутри информационной панели (infoPanel)
    UT_THEME.InfoPanel = {
        WidthOffset = 40,            -- доп. ширина относительно кнопки FIGHT
        Height      = 65,            -- высота панели
        YOffset     = -10,           -- смещение вверх от кнопок
        
        NameX       = 12,            -- X имени (от левого края)
        NameY       = 8,             -- Y имени
        LVX         = 12,            -- X метки LV
        LVY         = 32,            -- Y метки LV
        LVValueX    = 45,            -- X значения LV (после "LV")
        LVValueY    = 32,
        
        HPLabelX    = 12,            -- X надписи "HP"
        HPLabelY    = 50,            -- Y надписи "HP"
        HPBarX      = 40,            -- X полоски HP
        HPBarY      = 48,            -- Y полоски HP
        HPBarWidth  = 120,           -- ширина полоски
        HPBarHeight = 12,            -- высота полоски
        HPTextX     = 170,           -- X текста "XX/20"
        HPTextY     = 52,            -- Y текста HP
    }

    print("[UNDERTALE] Тема загружена")
end