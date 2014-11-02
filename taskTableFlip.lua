scriptId = 'ninja.chainsaw.taskTableFlip'
version = '0.1.1'

-- IMPORTANT NOTES:
-- You MUST have this as the last script in your script list, otherwise it is going to want to run all the time.

-- Mappings
-- Fingers Spread, Lift or Lower greater than 60 degrees and then release (Flip a table with your fingers spread) - Unlock and hold windows key, press tab
-- Wave Right - (tab) advance once
-- Wave Left - (shift tab) go back once
-- Fist - (win key) release windows key

-- Effects

-- Variables
debugFlag = 0
tentativeOn = false
startPitchDegrees = 0
tabing = false

function debugMsg(consoleMsg)
	if debugFlag == 1 then
		myo.debug(consoleMsg)
	end
end

function startTabing()
    myo.keyboard("left_win", "down")
	myo.keyboard("tab", "press")
end

function tab()
    myo.keyboard("tab", "press")
end

function tabBack()
	myo.keyboard("tab", "press", "shift")
end

function tabRelease()
	myo.keyboard("left_win", "up")
end

-- Helpers

function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

function radiansToDegrees(radians)
    return (radians * (180.0 / math.pi))
end

-- Unlock mechanism

function unlock()
    enabled = true
    extendUnlock()
end

function extendUnlock()
    enabledSince = myo.getTimeMilliseconds()
end


-- Triggers
function onPoseEdge(pose, edge)
    
	if(edge == on) then
		if(tentativeOn) then
			debugMsg("tentativeOn is true")
		else
			debugMsg("tentativeOn is false")
		end
	end
	
	if(edge == "on") then
		if(tentativeOn) then
			debugMsg("tentativeOn = true")
		else
			debugMsg("tentativeOn = false")
		end
	end
	
	if pose == "fingersSpread" and edge == "off" and tentativeOn then
		debugMsg("ending PitchDegrees is ".. radiansToDegrees(myo.getPitch()))
		if (((startPitchDegrees + tableFlipDegrees) < radiansToDegrees(myo.getPitch())) or ((startPitchDegrees - tableFlipDegrees) > radiansToDegrees(myo.getPitch()))) then
			--myo.vibrate("short")
			--myo.vibrate("short")
			enabledSince = myo.getTimeMilliseconds()
			unlock()
			startTabing()
			tabing = true
			--TODO: FIX THIS BEFORE PROD / DELETE THIS NOTICE
		end
	end
	if pose == "fingersSpread" and edge == "off" and tentativeOn and not (((startPitchDegrees + tableFlipDegrees) < radiansToDegrees(myo.getPitch())) or ((startPitchDegrees - tableFlipDegrees) > radiansToDegrees(myo.getPitch()))) then
		debugMsg("failed flip")
		tenativeOn = false
		startPitchDegrees = nil
	end
	
	if pose == "fingersSpread" and edge == "on" and not tentativeOn then
		--myo.vibrate("short")
		tentativeOn = true
		startPitchDegrees = radiansToDegrees(myo.getPitch())
		debugMsg("startPitchDegrees is "..startPitchDegrees)
	end
	
	if enabled then
    --if enabled and edge == "on" then
        pose = conditionallySwapWave(pose)
        if pose == "waveOut" and edge == "on" then
            myo.vibrate("short")
            extendUnlock()
            tab()
        end
        if pose == "waveIn" and edge == "on" then
            myo.vibrate("short")
            extendUnlock()
			tabBack()
        end
        if pose == "fist" and edge == "on" then
			tabRelease()
			debugMsg("Release win")
            myo.vibrate("medium")
			enabled = false
			if(tabing) then
				tabing = false
			end
        end
    end
end

-- All timeouts in milliseconds
ENABLED_TIMEOUT = 2200
currentYaw = 0
currentPitch = 0
currentRoll = 0
tableFlipDegrees = 45

function onPeriodic()
    currentYaw = myo.getYaw()
    currentPitch = myo.getPitch()
    currentRoll = myo.getRoll()

	if(tentativeOn and false) then
		debugMsg("Pitch... ".. currentPitch)
		debugMsg("Yaw... "..currentYaw)
		debugMsg("Roll... "..currentRoll)
    
	end
	
	--myo.debug("Pitch... "..currentPitch)
    --myo.debug("Yaw... "..currentYaw)
    --myo.debug("Roll... "..currentRoll)
        
	
	local now = myo.getTimeMilliseconds()
    
	
	if enabled then
		if myo.getTimeMilliseconds() - enabledSince > ENABLED_TIMEOUT then
            enabled = false
        end
		
		--if enabled == true and (volumeDirection == "up" or volumeDirection == "down") then
			--Double Check direction
			--if currentRoll > startRoll then
			--	volumeDirection = "up"
			--	volumeUp()
			--else
			--	volumeDirection = "down"
			--	volumeDown()
			--end
		--end
    end
end

function onForegroundWindowChange(app, title)
    debugMsg("Title: " .. title)
	if(title ~= "") then --TODO: FIX THIS THIS DOESN'T WORK!
		tabing = false
		tentativeOn = false
		tabRelease() --TODO: Test this...
	end
	
	local wantActive = false
    activeApp = ""
    if platform == "Windows" then
        wantActive = true
        activeApp = "taskTableFlip"
    end
    return wantActive
end

function activeAppName()
    return activeApp
end

function onActiveChange(isActive)
    if not isActive then
        enabled = false
    end
end
