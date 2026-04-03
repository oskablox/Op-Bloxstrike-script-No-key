local correctKey = "6543"

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, -150, 0.5, -90)

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0.8, 0, 0, 40)
TextBox.Position = UDim2.new(0.1, 0, 0.3, 0)
TextBox.PlaceholderText = "Wpisz klucz..."

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.8, 0, 0, 40)
Button.Position = UDim2.new(0.1, 0, 0.6, 0)
Button.Text = "Sprawdź klucz"

Button.MouseButton1Click:Connect(function()
    if TextBox.Text:gsub("%s+", "") == correctKey then
        Button.Text = "OK!"

        wait(0.5)
        ScreenGui:Destroy()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/oskablox/Op-Bloxstrike-script-No-key/main/main.lua"))()
    else
        Button.Text = "Zły klucz!"
    end
end)
