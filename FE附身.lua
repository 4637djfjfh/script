
local player = game.Players.LocalPlayer
local WALK_SPEED_THRESHOLD = 16

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")

    -- Confirm rig is R15
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        return
    end

    local animator = humanoid:WaitForChild("Animator")

    -- Stop currently playing animations
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop(0.1)
    end

    local animateScript = character:WaitForChild("Animate")
    local idle = animateScript:WaitForChild("idle")
    local walk = animateScript:WaitForChild("walk")
    local run = animateScript:WaitForChild("run")

    -- Optional sub-states
    local jump = animateScript:FindFirstChild("jump")
    local fall = animateScript:FindFirstChild("fall")
    local climb = animateScript:FindFirstChild("climb")

    -- Assign new animation IDs
    idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=80103653497738"
    idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=75794256017298"
    walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=88508412373927"
    run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=88508412373927"

    -- Load walk animation
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = "rbxassetid://88508412373927"
    local walkTrack = animator:LoadAnimation(walkAnim)
    walkTrack.Priority = Enum.AnimationPriority.Movement

    -- Helper to load and set priority for optional animations
    local function loadAndSetAnimation(animContainer)
        if animContainer and animContainer:FindFirstChildWhichIsA("StringValue") then
            local anim = Instance.new("Animation")
            anim.AnimationId = animContainer:FindFirstChildWhichIsA("StringValue").Value
            local track = animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action
            return track
        end
    end

    local jumpTrack = loadAndSetAnimation(jump)
    local fallTrack = loadAndSetAnimation(fall)
    local climbTrack = loadAndSetAnimation(climb)

    humanoid.Running:Connect(function(speed)
        if speed > 0 and speed <= WALK_SPEED_THRESHOLD then
            if not walkTrack.IsPlaying then
                walkTrack:Play()
            end
        else
            if walkTrack.IsPlaying then
                walkTrack:Stop(0.1)
            end
        end
    end)

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping
            or newState == Enum.HumanoidStateType.Freefall
            or newState == Enum.HumanoidStateType.Climbing then
            if walkTrack.IsPlaying then
                walkTrack:Stop(0.1)
            end
        end
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end