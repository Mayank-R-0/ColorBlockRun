--!Type(UI)

--!Bind
local roundLabel : UILabel = nil
--!Bind
local colorLabel : UILabel = nil
--!Bind
local timerLabel : UILabel = nil
--!Bind
local messageLabel : UILabel = nil
--!Bind
local MessageContainer : VisualElement = nil

--!Bind
local InstructionContainer : VisualElement = nil
--!Bind
local title : UILabel = nil
--!Bind
local instructions : UILabel = nil

--!Bind
local backgroundColorOne : VisualElement = nil
--!Bind
local backgroundColorTwo : VisualElement = nil
--!Bind
local backgroundColorThree : VisualElement = nil
--!Bind
local backgroundColorFour : VisualElement = nil
--!Bind
local backgroundColorFive : VisualElement = nil

function startLoad()
    setRoundText("ROUND 0/15")
    updateRoundColor("")
    setTimerText("10")
    MessageContainer.visible = false
    InstructionContainer.visible = false
end

function enableInstructions()
    title:SetPrelocalizedText("INSTRUCTIONS", false)
    instructions:SetPrelocalizedText("1. Get on displayed color tile \nin 5 sec. \n2. Quick 15-round races. \n3. Fall? Reset and race on. \n4. Finish in 15 rounds for placing.", false)
    InstructionContainer.visible = true
    Timer.After(8, function() InstructionContainer.visible = false end)
end

function setRoundText(text)
    roundLabel:SetPrelocalizedText(text, false)
end

function updateRoundColor(text)
    if(text == "" or text == nil) then 
        colorLabel.visible = false
    else
        colorLabel.visible = true
    end

    local recievedText = ""
    if(text == "1") then
        recievedText = "RED"
    elseif(text == "2") then
        recievedText = "GREEN"
    elseif(text == "3") then
        recievedText = "YELLOW"
    elseif(text == "4") then
        recievedText = "BLUE"
    elseif(text == "5") then
        recievedText = "CYAN"
    end
        
    colorLabel:SetPrelocalizedText(recievedText, false)
    updateBackgroundColor(recievedText)
end

function setTimerText(text)
    timerLabel:SetPrelocalizedText(text, false)
end

function setMessageText(text)
    messageLabel:SetPrelocalizedText(text, false)
    MessageContainer.visible = true
end

function hideMessageBox()
    MessageContainer.visible = false
end

function updateBackgroundColor(colorKey)
    if(colorKey == "RED") then
        backgroundColorOne.visible = true
        backgroundColorTwo.visible = false
        backgroundColorThree.visible = false
        backgroundColorFour.visible = false
        backgroundColorFive.visible = false
    elseif(colorKey == "GREEN") then
        backgroundColorOne.visible = false
        backgroundColorTwo.visible = true
        backgroundColorThree.visible = false
        backgroundColorFour.visible = false
        backgroundColorFive.visible = false        
    elseif(colorKey == "YELLOW") then
        backgroundColorOne.visible = false
        backgroundColorTwo.visible = false
        backgroundColorThree.visible = true
        backgroundColorFour.visible = false
        backgroundColorFive.visible = false        
    elseif(colorKey == "BLUE") then
        backgroundColorOne.visible = false
        backgroundColorTwo.visible = false
        backgroundColorThree.visible = false
        backgroundColorFour.visible = true
        backgroundColorFive.visible = false 
    elseif(colorKey == "CYAN") then
        backgroundColorOne.visible = false
        backgroundColorTwo.visible = false
        backgroundColorThree.visible = false
        backgroundColorFour.visible = false
        backgroundColorFive.visible = true
    else
        backgroundColorOne.visible = false
        backgroundColorTwo.visible = false
        backgroundColorThree.visible = false
        backgroundColorFour.visible = false
        backgroundColorFive.visible = false
    end
end