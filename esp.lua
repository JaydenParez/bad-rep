assert(Drawing, "missing dependency: drawing");

-- services
local run_service = game:GetService("RunService");
local players = game:GetService("Players");
local workspace = game:GetService("Workspace");

-- variables
local camera = workspace.CurrentCamera;
local get_pivot = workspace.GetPivot;
local wtvp = camera.WorldToViewportPoint;
local viewport_size = camera.ViewportSize;
local localplayer = players.LocalPlayer;
local cache = table.create(players.MaxPlayers);

-- locals
local new_drawing = Drawing.new;
local new_vector2 = Vector2.new;
local new_color3 = Color3.new;
local rad = math.rad;
local tan = math.tan;
local floor = math.floor;

local function create_esp(player)
    local esp = {};

    esp.boxOutline = new_drawing("Square", true);
    esp.boxOutline.Color = new_color3(0, 0, 0);
    esp.boxOutline.Thickness = 3;
    esp.boxOutline.Filled = false;

    esp.box = new_drawing("Square", true);
    esp.box.Color = new_color3(1, 1, 1);
    esp.box.Thickness = 1;
    esp.box.Filled = false;
    
    esp.tracer = new_drawing("Line", true); 
    esp.tracer.Color = new_color3(1, 1, 1);
    esp.tracer.Thickness = 1;

    esp.name = new_drawing("Text", true);
    esp.name.Color = new_color3(1, 1, 1);
    esp.name.Size = 14;
    esp.name.Center = true;

    esp.distance = new_drawing("Text", true);
    esp.distance.Color = new_color3(1, 1, 1);
    esp.distance.Size = 14;
    esp.distance.Center = true;

    esp.healthText = new_drawing("Text", true);
    esp.healthText.Color = new_color3(1, 1, 1);
    esp.healthText.Size = 14;
    esp.healthText.Center = true;
    
    esp.healthOutline = new_drawing("Square", true);
    esp.healthOutline.Color = new_color3(0, 0, 0);
    esp.healthOutline.Thickness = 0.3;
    esp.healthOutline.Filled = false;

    esp.health = new_drawing("Square", true);
    esp.health.Color = new_color3(0, 1, 0);
    esp.health.Thickness = 0.1;
    esp.health.Filled = false;

    cache[player] = esp;
end

local function remove_esp(player)
    for _, drawing in next, cache[player] do
        drawing:Remove();
    end

    cache[player] = nil;
end

local function update_esp()
    for player, esp in next, cache do
        local character = player and player.Character;
        if character and player.Team ~= localplayer.Team and character.Humanoid.Health > 0 then
            local cframe = get_pivot(character);
            local position, visible = wtvp(camera, cframe.Position);

            esp.boxOutline.Visible = visible;
            esp.box.Visible = visible;
            esp.tracer.Visible = visible;
            esp.name.Visible = visible;
            esp.distance.Visible = visible;
            esp.healthText.Visible = visible;
            esp.healthOutline.Visible = visible;
            esp.health.Visible = visible;

            if visible then
                local scale_factor = 1 / (position.Z * tan(rad(camera.FieldOfView * 0.5)) * 2) * 100;
                local width, height = floor(35 * scale_factor), floor(50 * scale_factor);
                local width2 = floor(1 * scale_factor)
                local x, y = floor(position.X), floor(position.Y);

                esp.boxOutline.Size = new_vector2(width, height);
                esp.boxOutline.Position = new_vector2(floor(x - width * 0.5), floor(y - height * 0.5));

                esp.box.Size = new_vector2(width, height);
                esp.box.Position = new_vector2(floor(x - width * 0.5), floor(y - height * 0.5));

                esp.tracer.From = new_vector2(floor(viewport_size.X * 0.5), floor(viewport_size.Y));
                esp.tracer.To = new_vector2(x, floor(y + height * 0.5));

                esp.name.Text = player.Name;
                esp.name.Position = new_vector2(x, floor(y - height * 0.5 - esp.name.TextBounds.Y));

                esp.distance.Text = floor(position.Z) .. " studs";
                esp.distance.Position = new_vector2(x, floor(y + height * 0.6));

                esp.healthText.Text = floor(character.Humanoid.Health) .. " HP";
                esp.healthText.Position = new_vector2(x, floor(y + height * 0.9));

                esp.healthOutline.Size = Vector2.new(2,height)
                esp.healthOutline.Position = Vector2.new(position.X - esp.boxOutline.Size.X / 2,position.Y - esp.boxOutline.Size.Y / 2) + Vector2.new(-3,0)

                esp.health.Size = Vector2.new(1,-(esp.healthOutline.Size.Y - 2) * (character.Humanoid.Health / 100))
                esp.health.Position = esp.healthOutline.Position + Vector2.new(1, -1 + esp.healthOutline.Size.Y)
            end
        else
            esp.boxOutline.Visible = false;
            esp.box.Visible = false;
            esp.tracer.Visible = false;
            esp.name.Visible = false;
            esp.distance.Visible = false;
            esp.healthText.Visible = false;
            esp.healthOutline.Visible = false;
            esp.health.Visible = false;
        end
    end
end

-- connections
players.PlayerAdded:Connect(create_esp);
players.PlayerRemoving:Connect(remove_esp);
run_service.RenderStepped:Connect(update_esp);

for _, player in next, players:GetPlayers() do
    if player ~= localplayer then
        create_esp(player);
    end
end
