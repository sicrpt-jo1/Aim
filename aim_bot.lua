local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false

-- إنشاء واجهة المستخدم الرئيسية
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- 1. زر صغير جداً للإخفاء والظهور (بدون أيقونة وبحجم مصغر)
local HideShowBtn = Instance.new("TextButton", ScreenGui)
HideShowBtn.Size = UDim2.new(0, 28, 0, 28) -- حجم أصغر بكثير
HideShowBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
HideShowBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HideShowBtn.BackgroundTransparency = 0.7 -- شفاف وخفيف
HideShowBtn.Text = "" -- بدون شكل العين
HideShowBtn.Active = true
HideShowBtn.Draggable = true
Instance.new("UICorner", HideShowBtn).CornerRadius = UDim.new(1, 0) -- زر دائري صغير

-- إطار خفيف لزر الإخفاء
local HideStroke = Instance.new("UIStroke", HideShowBtn)
HideStroke.Color = Color3.fromRGB(150, 150, 150)
HideStroke.Transparency = 0.5
HideStroke.Thickness = 1

-- 2. زر تفعيل/إيقاف الأيم بوت (شفاف جداً)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 120, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleBtn.BackgroundTransparency = 0.75 -- شفافية عالية جداً
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextTransparency = 0.2
ToggleBtn.Text = "Aimbot: OFF"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Visible = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- إطار خفيف جداً لزر الأيم بوت
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(150, 150, 150)
ToggleStroke.Transparency = 0.6
ToggleStroke.Thickness = 1

-- ربط زر الإخفاء والظهور (يخفي/يظهر زر الأيم بوت عند الضغط عليه)
HideShowBtn.MouseButton1Click:Connect(function()
    ToggleBtn.Visible = not ToggleBtn.Visible
end)

-- تفعيل/إيقاف الأيم بوت عند الضغط على الزر
ToggleBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        ToggleBtn.Text = "Aimbot: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleBtn.BackgroundTransparency = 0.6
    else
        ToggleBtn.Text = "Aimbot: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ToggleBtn.BackgroundTransparency = 0.75
    end
end)

local function IsEnemy(player)
    if player.Team ~= nil and LocalPlayer.Team ~= nil then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- دالة فحص الجدران (إذا كان اللاعب وراء حائط لا يمسك عليه الإيم)
local function IsVisible(head)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local ignoreList = {character, head.Parent}
    local obscuredParts = Camera:GetPartsObscuringTarget({head.Position}, ignoreList)
    
    return #obscuredParts == 0
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = nil
        local shortestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsEnemy(player) then
                local char = player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local head = char and char:FindFirstChild("Head")
                
                if hum and hum.Health > 0 and head then
                    if IsVisible(head) then
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local mag = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            
                            if mag < shortestDistance then
                                target = player
                                shortestDistance = mag
                            end
                        end
                    end
                end
            end
        end

        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
