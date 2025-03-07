local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local MergedAimbot = {
	Settings = {
		Enabled = false,
		FireMode = "none",
		LockMode = 1,
		LockPart = "Head",
		Sensitivity = 0,
		Sensitivity2 = 3.5,
		TeamCheck = true,
		AliveCheck = true,
		WallCheck = false,
	},
	FOVSettings = {
		Enabled = true,
		Radius = 90,
		Color = Color3.fromRGB(255, 255, 255),
		LockedColor = Color3.fromRGB(255, 150, 150),
		RainbowColor = false,
		RainbowSpeed = 1,
	},
	ESPEnabled = true,
	Target = nil,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = MergedAimbot.FOVSettings.Enabled
FOVCircle.Radius = MergedAimbot.FOVSettings.Radius
FOVCircle.Color = MergedAimbot.FOVSettings.Color
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local function GetRainbowColor()
	local t = tick() % MergedAimbot.FOVSettings.RainbowSpeed / MergedAimbot.FOVSettings.RainbowSpeed
	return Color3.fromHSV(t, 1, 1)
end

local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MergedAimbotUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
MergedAimbot.ScreenGui = screenGui

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0.6, 0, 0.7, 0)
mainContainer.Position = UDim2.new(0.2, 0, 0.15, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui
makeDraggable(mainContainer)

local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Size = UDim2.new(0.2, 0, 1, 0)
sideBar.Position = UDim2.new(0, 0, 0, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainContainer

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(0.8, 0, 1, 0)
contentContainer.Position = UDim2.new(0.2, 0, 0, 0)
contentContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainContainer

local tabs = {"Aimbot", "ESP", "Config", "Misc"}
local pages = {}
local currentPage = nil
local tabButtonHeight = 40
local tabSpacing = 5

for i, tabName in ipairs(tabs) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = "Tab_" .. tabName
	tabButton.Size = UDim2.new(1, 0, 0, tabButtonHeight)
	tabButton.Position = UDim2.new(0, 0, 0, (tabButtonHeight + tabSpacing) * (i - 1) + 10)
	tabButton.BackgroundColor3 = Color3.fromRGB(50, 70, 70)
	tabButton.TextColor3 = Color3.fromRGB(210, 230, 230)
	tabButton.Font = Enum.Font.Gotham
	tabButton.TextSize = 16
	tabButton.Text = tabName
	tabButton.Parent = sideBar

	local page = Instance.new("Frame")  
	page.Name = "Page_" .. tabName  
	page.Size = UDim2.new(1, 0, 1, 0)  
	page.Position = UDim2.new(0, 0, 0, 0)  
	page.BackgroundColor3 = Color3.fromRGB(30, 50, 50)  
	page.BorderSizePixel = 0  
	page.Visible = false  
	page.Parent = contentContainer  
	pages[tabName] = page  

	local pageLabel = Instance.new("TextLabel")  
	pageLabel.Name = "TitleLabel"  
	pageLabel.Size = UDim2.new(1, 0, 0, 30)  
	pageLabel.Position = UDim2.new(0, 0, 0, 0)  
	pageLabel.BackgroundTransparency = 1  
	pageLabel.Text = "Configurações de " .. tabName  
	pageLabel.TextColor3 = Color3.new(1, 1, 1)
	pageLabel.Font = Enum.Font.GothamSemibold
	pageLabel.TextSize = 18
	pageLabel.Parent = page  

	tabButton.MouseButton1Click:Connect(function()  
		if currentPage then  
			currentPage.Visible = false  
		end  
		page.Visible = true  
		currentPage = page  
	end)
end

if #tabs > 0 and pages[tabs[1]] then
	pages[tabs[1]].Visible = true
	currentPage = pages[tabs[1]]
end

local resizeHandle = Instance.new("Frame")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 5, 1, 0)
resizeHandle.Position = UDim2.new(1, -5, 0, 0)
resizeHandle.BackgroundColor3 = Color3.new(1, 1, 1)
resizeHandle.BackgroundTransparency = 0.5
resizeHandle.ZIndex = 2
resizeHandle.Active = true
resizeHandle.Selectable = true
resizeHandle.Parent = sideBar

local draggingResize = false
local dragStartX, originalWidth

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingResize = true
		dragStartX = input.Position.X
		originalWidth = sideBar.AbsoluteSize.X
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingResize = false
			end
		end)
	end
end)

resizeHandle.InputChanged:Connect(function(input)
	if draggingResize and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position.X - dragStartX
		local newWidth = originalWidth + delta
		local containerWidth = mainContainer.AbsoluteSize.X
		local newScale = newWidth / containerWidth
		newScale = math.clamp(newScale, 0.1, 0.5)
		sideBar.Size = UDim2.new(newScale, 0, 1, 0)
		contentContainer.Position = UDim2.new(newScale, 0, 0, 0)
		contentContainer.Size = UDim2.new(1 - newScale, 0, 1, 0)
	end
end)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 50, 0, 25)
minimizeButton.Position = UDim2.new(1, -55, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 70, 70)
minimizeButton.TextColor3 = Color3.fromRGB(210, 230, 230)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Text = "-"
minimizeButton.Parent = mainContainer

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
	if isMinimized then
		mainContainer.Visible = true
		minimizeButton.Text = "-"
		isMinimized = false
	else
		mainContainer.Visible = false
		isMinimized = true
	end
end)

-- Botão para destruir o GUI (X)
local destroyButton = Instance.new("TextButton")
destroyButton.Name = "DestroyButton"
destroyButton.Size = UDim2.new(0, 50, 0, 25)
destroyButton.Position = UDim2.new(1, -110, 0, 5)
destroyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
destroyButton.TextColor3 = Color3.new(1, 1, 1)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 18
destroyButton.Text = "X"
destroyButton.Parent = mainContainer

destroyButton.MouseButton1Click:Connect(function()
	MergedAimbot:Exit()
end)

do
	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(0, 60, 0, 34)
	switchFrame.Position = UDim2.new(0, 10, 0, 50)
	switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	switchFrame.Parent = pages["Aimbot"]
	local uiCornerSwitch = Instance.new("UICorner")
	uiCornerSwitch.CornerRadius = UDim.new(0, 17)
	uiCornerSwitch.Parent = switchFrame

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 30, 0, 30)
	sliderButton.Position = UDim2.new(0, 2, 0, 2)
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.Parent = switchFrame
	local uiCornerSlider = Instance.new("UICorner")
	uiCornerSlider.CornerRadius = UDim.new(0, 15)
	uiCornerSlider.Parent = sliderButton

	local isAimbotEnabled = false

	local function updateSwitch()
		if isAimbotEnabled then
			sliderButton.Position = UDim2.new(0, 32, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			sliderButton.Position = UDim2.new(0, 2, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	sliderButton.MouseButton1Click:Connect(function()
		isAimbotEnabled = not isAimbotEnabled
		updateSwitch()
		MergedAimbot.Settings.Enabled = isAimbotEnabled
	end)

	updateSwitch()
end

do
	local miscPage = pages["Misc"]
	local currentY = 40

	local function createLabel(text, height)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, height or 20)
		label.Position = UDim2.new(0, 10, 0, currentY)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 16
		label.Parent = miscPage
		currentY = currentY + (height or 20) + 5
	end

	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.new(0, 200, 0, 30)
	discordButton.Position = UDim2.new(0, 10, 0, currentY)
	discordButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	discordButton.TextColor3 = Color3.new(1, 1, 1)
	discordButton.Font = Enum.Font.GothamBold
	discordButton.TextSize = 16
	discordButton.Text = "Discord"
	discordButton.Parent = miscPage
	discordButton.MouseButton1Click:Connect(function()
		local url = "https://discord.gg/tuEawMf34u"
		local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
		if not success then
			setclipboard(url)
		end
	end)
	currentY = currentY + 40

	local youtubeButton = Instance.new("TextButton")
	youtubeButton.Size = UDim2.new(0, 200, 0, 30)
	youtubeButton.Position = UDim2.new(0, 10, 0, currentY)
	youtubeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	youtubeButton.TextColor3 = Color3.new(1, 1, 1)
	youtubeButton.Font = Enum.Font.GothamBold
	youtubeButton.TextSize = 16
	youtubeButton.Text = "YouTube"
	youtubeButton.Parent = miscPage
	youtubeButton.MouseButton1Click:Connect(function()
		local url = "https://youtube.com/@jinx_scripts?si=nt9aWeD2lRY7Ok9N"
		local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
		if not success then
			setclipboard(url)
		end
	end)
	currentY = currentY + 60

	-- Labels adicionais
	createLabel("DESTRUA-SE ROBLOX", 25)
	createLabel("Jinxscripts", 25)
	createLabel("\"not\" Justadev", 25)

	-- Botão "Aumentar FPS" que define os fastflags
	local fpsButton = Instance.new("TextButton")
	fpsButton.Size = UDim2.new(0, 200, 0, 30)
	fpsButton.Position = UDim2.new(0, 10, 0, currentY)
	fpsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	fpsButton.TextColor3 = Color3.new(1, 1, 1)
	fpsButton.Font = Enum.Font.GothamBold
	fpsButton.TextSize = 16
	fpsButton.Text = "Aumentar FPS"
	fpsButton.Parent = miscPage
	fpsButton.MouseButton1Click:Connect(function()
		-- Defina os fastflags conforme os JSONs fornecidos
		local fastFlags = {
			["FIntRenderMaxShadowAtlasUsageBeforeDownscale"] = "1",
			["FFlagDebugSelfViewPerfBenchmark"] = "False",
			["FFlagSelfViewAvoidErrorOnWrongFaceControlsParenting"] = "False",
			["DFFlagVoiceChatTurnOnMuteUnmuteNotificationHack"] = "False",
			["FFlagRenderDebugCheckThreading2"] = "True",
			["FFlagFixReducedMotionStuckIGM2"] = "True",
			["DFIntCSGLevelOfDetailSwitchingDistance"] = "0",
			["FIntRuntimeMaxNumOfThreads"] = "2400",
			["FFlagCSGDecalOptimizeVB"] = "True",
			["DFIntDebugAdditionalNumberOfMipsToSkipForNonAlbedoTextures"] = "0",
			["FFlagToastNotificationsResendDisplayOnInit"] = "False",
			["DFIntMicroProfilerDpiScaleOverride"] = "100",
			["FFlagLuaAppsEnableParentalControlsTab"] = "False",
			["FFlagDisableFeedbackSoothsayerCheck"] = "False",
			["FFlagControlBetaBadgeWithGuac"] = "False",
			["FFlagFixSensitivityTextPrecision"] = "False",
			["FFlagDebugDeterministicParticles"] = "False",
			["DFIntNumAssetsMaxToPreload"] = "2147483647",
			["FIntEnableVisBugChecksHundredthPercent27"] = "0",
			["FIntCameraMaxZoomDistance"] = "999999",
			["FFlagMigrateTextureManagerIsLocalAsset"] = "True",
			["FFlagRenderLightGridEfficientTextureAtlasUpdate"] = "True",
			["DFFlagGraphicsOptimizationModeMVPExposureEnrollment3"] = "False",
			["FFlagRemovedRbxRenderingPreProcessor"] = "False",
			["FIntAXAdaptiveScrollingJustSelectedMillis"] = "2000",
			["FFlagEngineAPICloudProcessingUseNotificationClient"] = "False",
			["FFlagDebugCodegenOptSize"] = "True",
			["FFlagEnableCommandAutocomplete"] = "False",
			["FFlagEnableBubbleChatFromChatService"] = "False",
			["FIntUITextureMaxUpdateDepth"] = "-1",
			["FIntRomarkStartWithGraphicQualityLevel"] = "1",
			["FFlagAXAdaptiveScrollingItemResetFix2"] = "True",
			["DFFlagAssetPreloadingUrlVersionEnabled2"] = "True",
			["FStringVoiceBetaBadgeLearnMoreLink"] = "null",
			["DFFlagUseVisBugChecks"] = "True",
			["FFlagFastGPULightCulling3"] = "True",
			["FFlagFRMRefactor"] = "False",
			["FFlagBetaBadgeLearnMoreLinkFormview"] = "False",
			["FFlagVRLaserPointerOptimization"] = "True",
			["FLogNetwork"] = "7",
			["FFlagRenderNoLowFrmBloom"] = "False",
			["DFFlagEnableMeshPreloading2"] = "True",
			["FFlagRenderFixFog"] = "True",
			["FFlagSelfViewUpdatedCamFraming"] = "False",
			["FFlagEnablePreferredTextSizeStyleFixesInExperienceMenu"] = "True",
			["DFIntTimestepArbiterThresholdCFLThou"] = "300",
			["DFFlagAudioEnableVolumetricPanningForPolys"] = "True",
			["FFlagLuaAppGamesPagePreloadingDisabled"] = "False",
			["FFlagRemoveRedundantFontPreloading"] = "True",
			["DFIntTeleportClientAssetPreloadingHundredthsPercentage"] = "100000",
			["FFlagStudioDataCollectionAddBasicNotification"] = "False",
			["FFlagEnablePreferredTextSizeStyleFixesInPurchasePrompt"] = "True",
			["DFIntWindowsWebViewTelemetryThrottleHundredthsPercent"] = "0",
			["FIntDebugFRMOptionalMSAALevelOverride"] = "1",
			["FFlagSelfViewTweaksPass"] = "False",
			["FFlagUserShowGuiHideToggles"] = "True",
			["DFIntCSGLevelOfDetailSwitchingDistanceL23"] = "0",
			["FIntTerrainOTAMaxTextureSize"] = "4",
			["FFlagShaderLightingRefactor"] = "True",
			["FFlagHandleAltEnterFullscreenManually"] = "False",
			["FFlagDebugSSAOForce"] = "False",
			["DFIntCSGLevelOfDetailSwitchingDistanceL34"] = "0",
			["DFFlagTeleportClientAssetPreloadingEnabledIXP2"] = "True",
			["FIntGrassMovementReducedMotionFactor"] = "0",
			["FFlagQuaternionPoseCorrection"] = "True",
			["FIntFRMMinGrassDistance"] = "0",
			["FFlagPreloadAllFonts"] = "True",
			["FFlagFixCountOfUnreadNotificationError"] = "False",
			["FFlagDebugDisableTelemetryV2Stat"] = "True",
			["FFlagEnablePreferredTextSizeGuiService"] = "True",
			["FFlagEnablePreferredTextSizeStyleFixesInReportMenu"] = "True",
			["FFlagSyncWebViewCookieToEngine2"] = "False",
			["DFIntCSGLevelOfDetailSwitchingDistanceL12"] = "0",
			["FFlagTopBarUseNewBadge"] = "False",
			["FFlagUserHideCharacterParticlesInFirstPerson"] = "True",
			["FFlagEnablePreferredTextSizeSettingInMenus2"] = "True",
			["DFIntDebugFRMQualityLevelOverride"] = "1",
			["FIntRefreshRateLowerBound"] = "120",
			["FIntVertexSmoothingGroupTolerance"] = "1",
			["FFlagEnableBetterHapticsResultHandling"] = "True",
			["FFlagEnableExperienceNotificationPrompts2"] = "False",
			["DFFlagSimOptimizeSetSize"] = "True",
			["DFFlagEnableTexturePreloading"] = "True",
			["DFIntAnimationLodFacsDistanceMax"] = "0",
			["FFlagEnableAudioPannerFiltering"] = "True",
			["FFlagUseNotificationsLocalization"] = "False",
			["DFIntPerformanceControlTextureQualityBestUtility"] = "-1",
			["FFlagNotificationButtonTypeVariantMappingEmphasis"] = "False",
			["FIntVRTouchControllerTransparency"] = "0",
			["FFlagFixParticleEmissionBias2"] = "False",
			["FFlagDisablePostFx"] = "True",
			["DFIntVoiceChatMaxRecordedDataDeliveryIntervalMs"] = "2147483647",
			["FFlagEnableAudioEmitterDistanceAttenuation"] = "True",
			["FFlagDebugDisableTelemetryEventIngest"] = "True",
			["FFlagDisableChromeV3StaticSelfView"] = "False",
			["FFlagNewOptimizeNoCollisionPrimitiveInMidphase637"] = "True",
			["FFlagRenderLegacyShadowsQualityRefactor"] = "True",
			["FFlagEnablePreferredTextSizeScalePerLayerCollector"] = "True",
			["FIntUnifiedLightingBlendZone"] = "1",
			["DFIntVideoMaxNumberOfVideosPlaying"] = "0",
			["FIntSSAOMipLevels"] = "1",
			["FFlagEnableVRFTUXExperienceV2"] = "True",
			["DFIntContentProviderPreloadHangTelemetryHundredthsPercentage"] = "0",
			["FFlagLoginPageOptimizedPngs"] = "True",
			["FFlagUpdateHTTPCookieStorageFromWKWebView"] = "False",
			["FFlagSelfViewRemoveVPFWhenClosed"] = "False",
			["FIntRenderGrassDetailStrands"] = "0",
			["FFlagDebugEnableDirectAudioOcclusion2"] = "True",
			["FFlagFixSelfViewPopin"] = "False",
			["FFlagPreOptimizeNoCollisionPrimitive"] = "True",
			["FIntRenderShadowIntensity"] = "0",
			["FFlagDeveloperToastNotificationsEnabled"] = "False",
			["FIntSelfViewTooltipLifetime"] = "0",
			["FFlagNotificationsNoLongerRequireControllerState"] = "False",
			["DFIntMacWebViewTelemetryThrottleHundredthsPercent"] = "0",
			["FFlagVRMouseMoveOptimization"] = "True",
			["FFlagContentProviderPreloadHangTelemetry"] = "False",
			["DFFlagSimSolverOptimizeGeometricStiffness4"] = "True",
			["FStringTerrainMaterialTable2022"] = "",
			["FFlagNotificationPluginSignalRReadEvents"] = "False",
			["FFlagClientToastNotificationsEnabled"] = "False",
			["FFlagAXPortraitSplitAdaptiveScrollingFix2"] = "True",
			["FFlagSimEnableDCD16"] = "True",
			["FIntRenderLocalLightUpdatesMin"] = "1",
			["DFFlagOpenCloudV1CreateUserNotificationAsync"] = "False",
			["FFlagAXSearchLandingPageIXPEnabled4"] = "False",
			["FFlagDebugDisableTelemetryEphemeralStat"] = "True",
			["FIntTextureCompositorLowResFactor"] = "4",
			["DFFlagPhysicsMechanismCacheOptimizeAlloc"] = "True",
			["FFlagFixParticleAttachmentCulling"] = "False",
			["DFFlagAudioEnableVolumetricPanningForMeshes"] = "True",
			["FIntStudioWebView2TelemetryHundredthsPercent"] = "0",
			["DFIntTextureQualityOverride"] = "0",
			["FIntFullscreenTitleBarTriggerDelayMillis"] = "3600000",
			["FIntRobloxGuiBlurIntensity"] = "0",
			["FFlagGuiHidingApiSupport2"] = "True",
			["DFFlagOptimizeIsA"] = "True",
			["FFlagEnableChromeFTUX"] = "True",
			["DFFlagAdsPreloadInteractivityAssets"] = "True",
			["DFFlagSimRefactorCollisionGeometry2"] = "True",
			["DFIntTeleportClientAssetPreloadingHundredthsPercentage2"] = "100000",
			["FFlagGraphicsGLEnableSuperHQShadersExclusion"] = "False",
			["FFlagEnablePreferredTextSizeStyleFixesAddFriends"] = "True",
			["FIntFriendRequestNotificationThrottle"] = "0",
			["FFlagDebugSkyGray"] = "True",
			["FFlagUseNotificationServiceIsConnected"] = "False",
			["FIntTargetRefreshRate"] = "144",
			["DFFlagDebugSkipMeshVoxelizer"] = "True",
			["FIntFixForBulkPresenceNotifications"] = "0",
			["DFIntRakNetMtuValue3InBytes"] = "1250",
			["DFFlagEnableSoundPreloading"] = "True",
			["FIntFRMMaxGrassDistance"] = "0",
			["FFlagWindowsReportAbuseNotification"] = "False",
			["FFlagAXAdaptiveScrollingAvatarEditor2"] = "True",
			["FFlagSelfViewLookUpHumanoidByType"] = "False",
			["DFFlagEngineAPISendNotificationClientAnalytics"] = "False",
			["FStringInExperienceNotificationsLayer"] = "",
			["DFIntHttpParallelLimit_RequestExperienceNotificationService"] = "0",
			["DFFlagDisableDPIScale"] = "False",
			["DFIntHACDPointSampleDistApartTenths"] = "2147483647",
			["FFlagDebugForceGenerateHSR"] = "True",
			["DFIntCanHideGuiGroupId"] = "32380007",
			["FFlagVoiceBetaBadge"] = "False",
			["FIntDebugForceMSAASamples"] = "1",
			["FFlagDebugForceFSMCPULightCulling"] = "True",
			["FIntDebugTextureManagerSkipMips"] = "5",
			["FIntDirectionalAttenuationMaxPoints"] = "1",
			["FFlagGraphicsGLEnableHQShadersExclusion"] = "False",
			["FFlagPreloadTextureItemsOption4"] = "True",
			["DFIntTaskSchedulerTargetFps"] = "9999",
			["DFFlagUnifyLegacyJointGeometry"] = "True",
			["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
			["FFlagSelfViewMoreNilChecks"] = "False",
			["FIntStudioExternalNotificationImplMessageWriteTimeOut"] = "0",
			["FFlagDebugEnableVRFTUXExperienceInStudio"] = "True",
			["FFlagFixExitDialogBlockVRView"] = "True",
			["FFlagSelfViewCameraDefaultButtonInViewPort"] = "False",
			["DFFlagOptimizeClusterCacheAlloc"] = "True",
			["DFStringAltTelegrafAddress"] = "127.0.0.1",
			["DFIntCullFactorPixelThresholdShadowMapLowQuality"] = "2147483647",
			["FFlagDebugDisableTelemetryV2Event"] = "True",
			["FFlagVideoTextureSupportHardwareRender"] = "True",
			["FFlagDebugRenderingSetDeterministic"] = "True",
			["FFlagFixEmotesMenuVR"] = "True",
			["FFlagVisBugChecksThreadYield"] = "True",
			["FFlagAdaptiveScrollingFrameOnServer"] = "True",
			["FFlagEnablePreferredTextSizeStyleFixesInPlayerList"] = "True",
			["DFIntCullFactorPixelThresholdShadowMapHighQuality"] = "2147483647",
			["FFlagImproveShiftLockTransition"] = "True",
			["DFFlagTeleportPreloadingMetrics5"] = "True",
			["FFlagVRBackpackImproved"] = "True",
			["FFlagFixIGMTabTransitions"] = "True",
			["FFlagAXFixAdaptiveScrollingSnapAndroid"] = "True",
			["DFFlagTeleportClientAssetPreloadingDoingExperiment2"] = "True",
			["FIntTaskSchedulerThreadMin"] = "3",
			["FFlagAXAdaptiveScrollingImprovementIXPEnabled"] = "True",
			["DFIntRakNetMtuValue2InBytes"] = "1337",
			["FFlagFixIGMBottomBarVisibility"] = "True",
			["FFlagRenderOptimizeDecalTransparencyInvalidation"] = "True",
			["FStringGraphicsDisableUnalignedDxtGPUNameBlacklist"] = "null",
			["DFIntAnimationLodFacsDistanceMin"] = "0",
			["DFFlagAudioUseVolumetricPanning"] = "True",
			["FIntBootstrapperWebView2InstallationTelemetryHundredthPercent"] = "0",
			["FFlagSignalRNotificationManagerMaybeStart"] = "False",
			["FFlagAssetPreloadingIXP"] = "True",
			["DFFlagTeleportClientAssetPreloadingEnabledIXP"] = "True",
			["FFlagFixChunkLightingUpdate2"] = "True",
			["FIntRenderLocalLightUpdatesMax"] = "1",
			["FFlagEnableIOSWebViewCookieSyncFix"] = "False",
			["DFIntMaxFrameBufferSize"] = "4",
			["FFlagSelfViewHumanoidNilCheck"] = "False",
			["FFlagSelfieViewEnabled"] = "True",
			["FFlagToastNotificationsProtocolEnabled2"] = "False",
			["DFFlagWindowsWebViewTelemetryEnabled"] = "False",
			["FFlagInExperienceUpsellSelfViewFix"] = "False",
			["DFFlagTextureQualityOverrideEnabled"] = "False",
			["FFlagAdServiceEnabled"] = "False",
			["DFFlagEnableExperienceNotificationOptInPrompt"] = "False",
			["FFlagRenderSkipReadingShaderData"] = "False",
			["FFlagPreferredTextSizeSettingBetaFeature"] = "True",
			["FIntTerrainArraySliceSize"] = "0",
			["FFlagFixOutdatedTimeScaleParticles"] = "False",
			["DFIntDefaultTimeoutTimeMs"] = "10000",
			["FIntSmoothTerrainPhysicsCacheSize"] = "1",
			["FIntRenderLocalLightFadeInMs"] = "0",
			["FFlagEnablePreferredTextSizeStyleFixesGameTile"] = "True",
			["FFlagDebugStudioForceSystemDeprecationNotification"] = "False",
			["FFlagGraphicsTextureCopy"] = "True",
			["FIntPreferredTextSizeSettingBetaFeatureRolloutPercent"] = "100",
			["DFFlagTeleportClientAssetPreloadingDoingExperiment"] = "True",
			["FFlagDebugGraphicsPreferD3D11"] = "True",
			["DFFlagDebugOverrideDPIScale"] = "False",
			["FIntRenderShadowmapBias"] = "-1",
			["FFlagDebugDisableTelemetryEphemeralCounter"] = "True",
			["FFlagShoeSkipRenderMesh"] = "False",
			["FFlagMockOpenSelfViewForCameraUser"] = "False",
			["FFlagViewCollisionFadeToBlackInVR"] = "False",
			["DFIntAnimationLodFacsVisibilityDenominator"] = "0",
			["FFlagAXAdaptiveScrollingSnapItemEditor"] = "True",
			["FFlagEnablePreferredTextSizeStyleFixesInCaptureMenu"] = "True",
			["DFIntRakNetMtuValue1InBytes"] = "1396",
			["FFlagEnablePreferredTextSizeStyleFixesInAppShell3"] = "True",
			["FFlagSettingsHubIndependentBackgroundVisibility"] = "True",
			["FFlagFixSettingsHubVRBackgroundError"] = "True",
			["DFFlagAudioToggleVolumetricPanning"] = "True",
			["FFlagDebugCheckRenderThreading"] = "True",
			["FFlagCoreGuiSelfViewVisibilityFixed"] = "False",
			["FIntBloomFrmCutoff"] = "-1",
			["FFlagRenderCBRefactor2"] = "True",
			["FFlagEnableVisBugChecks27"] = "True",
			["FFlagEnablePreferredTextSizeConnection"] = "True",
			["FFlagNewLightAttenuation"] = "True",
			["DFFlagTeleportClientAssetPreloadingEnabled9"] = "True",
			["FFlagRenderShadowSkipHugeCulling"] = "True",
			["DFStringWebviewUrlAllowlist"] = "",
			["FFlagChatTranslationEnableSystemMessage"] = "False",
			["DFFlagOptimizeNoCollisionPrimitiveInMidphaseCrash"] = "True",
			["FFlagSquadToastNotificationsEnabled"] = "False",
			["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
			["DFFlagDebugPerfMode"] = "True",
			["FFlagEnableRemoveIsFromToastNotification"] = "False",
			["FFlagUserEnableCameraToggleNotification"] = "False",
			["DFFlagDebugPauseVoxelizer"] = "True",
			["FIntStudioResendDisconnectNotificationInterval"] = "0",
			["FFlagSelfViewGetRidOfFalselyRenderedFaceDecal"] = "False",
			["FFlagToastNotificationsReceivedAndDismissedSignals"] = "False",
			["FFlagPreloadMinimalFonts"] = "True",
			["FFlagUserSoundsUseRelativeVelocity2"] = "True",
			["FFlagDebugDisableTelemetryPoint"] = "True",
			["FStringTerrainMaterialTablePre2022"] = "",
			["FFlagUserFixLoadAnimationError"] = "True",
			["DFFlagNotificationServiceIsConnectedProperty"] = "False",
			["FFlagEnablePreferredTextSizeScale"] = "True",
			["FFlagSelfViewFixes"] = "False",
			["DFIntDebugLimitMinTextureResolutionWhenSkipMips"] = "0",
			["FFlagToastNotificationsUpdateEventParams"] = "False",
			["FFlagAvatarChatIncludeSelfViewOnTelemetry"] = "False",
			["FFlagDebugDisableTelemetryV2Counter"] = "True",
			["FFlagDontRerenderForBadTexture"] = "True",
			["FStringWhitelistVerifiedUserId"] = "1307880661"
		}
		for flag, value in pairs(fastFlags) do
			pcall(function() setfflag(flag, value) end)
		end
		print("Fastflags aplicados para aumento de FPS!")
	end)
end

do
	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(0, 60, 0, 34)
	switchFrame.Position = UDim2.new(0, 10, 0, 50)
	switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	switchFrame.Parent = pages["ESP"]
	local uiCornerESPFrame = Instance.new("UICorner")
	uiCornerESPFrame.CornerRadius = UDim.new(0, 17)
	uiCornerESPFrame.Parent = switchFrame

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 30, 0, 30)
	sliderButton.Position = UDim2.new(0, 2, 0, 2)
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.Parent = switchFrame
	local uiCornerESPSlider = Instance.new("UICorner")
	uiCornerESPSlider.CornerRadius = UDim.new(0, 15)
	uiCornerESPSlider.Parent = sliderButton

	local isESPEnabled = MergedAimbot.ESPEnabled

	local function updateSwitch()
		if isESPEnabled then
			sliderButton.Position = UDim2.new(0, 32, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			sliderButton.Position = UDim2.new(0, 2, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	sliderButton.MouseButton1Click:Connect(function()
		isESPEnabled = not isESPEnabled
		updateSwitch()
		MergedAimbot.ESPEnabled = isESPEnabled
	end)

	updateSwitch()
end

do
	local configPage = pages["Config"]

	local configControlsFrame = Instance.new("Frame")
	configControlsFrame.Name = "ConfigControls"
	configControlsFrame.Size = UDim2.new(1, -20, 1, -50)
	configControlsFrame.Position = UDim2.new(0, 10, 0, 40)
	configControlsFrame.BackgroundTransparency = 1
	configControlsFrame.Parent = configPage

	local currentY = 0

	local function createLabel(text, parent)
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 16
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Position = UDim2.new(0, 0, 0, currentY)
		label.Parent = parent
		currentY = currentY + 25
		return label
	end

	do
		createLabel("Exibir FOV", configControlsFrame)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 60, 0, 34)
		toggleFrame.Position = UDim2.new(0, 10, 0, currentY)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = configControlsFrame
		local uiCornerFOVToggle = Instance.new("UICorner")
		uiCornerFOVToggle.CornerRadius = UDim.new(0, 17)
		uiCornerFOVToggle.Parent = toggleFrame

		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 30, 0, 30)
		toggleButton.Position = UDim2.new(0, 2, 0, 2)
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame
		local uiCornerFOVToggleButton = Instance.new("UICorner")
		uiCornerFOVToggleButton.CornerRadius = UDim.new(0, 15)
		uiCornerFOVToggleButton.Parent = toggleButton

		local isFOVEnabled = MergedAimbot.FOVSettings.Enabled

		local function updateToggle()
			if isFOVEnabled then
				toggleButton.Position = UDim2.new(0, 32, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			else
				toggleButton.Position = UDim2.new(0, 2, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		toggleButton.MouseButton1Click:Connect(function()
			isFOVEnabled = not isFOVEnabled
			MergedAimbot.FOVSettings.Enabled = isFOVEnabled
			FOVCircle.Visible = isFOVEnabled
			updateToggle()
		end)
		updateToggle()
		currentY = currentY + 40
	end

	do
		local fovLabel = createLabel("Raio do FOV: " .. MergedAimbot.FOVSettings.Radius, configControlsFrame)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
		sliderFrame.Position = UDim2.new(0, 10, 0, currentY)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		sliderFrame.Parent = configControlsFrame

		-- Criação de um handle para redimensionamento (exemplo)
		local cornerResizeHandle = Instance.new("Frame")
		cornerResizeHandle.Name = "CornerResizeHandle"
		cornerResizeHandle.Size = UDim2.new(0, 20, 0, 20)
		cornerResizeHandle.AnchorPoint = Vector2.new(1, 1)
		cornerResizeHandle.Position = UDim2.new(1, 0, 1, 0)
		cornerResizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		cornerResizeHandle.BorderSizePixel = 0
		cornerResizeHandle.ZIndex = 3
		cornerResizeHandle.Parent = mainContainer

		local resizingCorner = false
		local initialMousePos, initialSize

		cornerResizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizingCorner = true
				initialMousePos = input.Position
				initialSize = mainContainer.AbsoluteSize
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizingCorner = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if resizingCorner and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - initialMousePos
				local minSize = 25
				local maxSize = 300
				local newWidth = math.clamp(initialSize.X + delta.X, minSize, maxSize)
				local newHeight = math.clamp(initialSize.Y + delta.Y, minSize, maxSize)
				mainContainer.Size = UDim2.new(0, newWidth, 0, newHeight)
			end
		end)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 1, 0)
		knob.Position = UDim2.new((MergedAimbot.FOVSettings.Radius / 180), 0, 0, 0)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.Parent = sliderFrame

		local draggingSlider = false
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = true
			end
		end)
		knob.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)
		sliderFrame.InputChanged:Connect(function(input)
			if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
				local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
				local scale = relativeX / sliderFrame.AbsoluteSize.X
				knob.Position = UDim2.new(scale, 0, 0, 0)
				local newFOV = math.floor(scale * 180)
				MergedAimbot.FOVSettings.Radius = newFOV
				fovLabel.Text = "Raio do FOV: " .. newFOV
				FOVCircle.Radius = newFOV
			end
		end)
		currentY = currentY + 30
	end

	do
		createLabel("Cor do FOV", configControlsFrame)
		local colorButton = Instance.new("TextButton")
		colorButton.Size = UDim2.new(0, 100, 0, 30)
		colorButton.Position = UDim2.new(0, 10, 0, currentY)
		colorButton.Text = "Alterar Cor"
		colorButton.BackgroundColor3 = MergedAimbot.FOVSettings.Color
		colorButton.TextColor3 = Color3.new(0, 0, 0)
		colorButton.Parent = configControlsFrame

		local colors = {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(255, 255, 0),
		}
		local colorIndex = 1
		colorButton.MouseButton1Click:Connect(function()
			colorIndex = colorIndex % #colors + 1
			local newColor = colors[colorIndex]
			MergedAimbot.FOVSettings.Color = newColor
			colorButton.BackgroundColor3 = newColor
			if not MergedAimbot.FOVSettings.RainbowColor then
				FOVCircle.Color = newColor
			end
		end)
		currentY = currentY + 40
	end

	do
		createLabel("Efeito Rainbow", configControlsFrame)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 60, 0, 34)
		toggleFrame.Position = UDim2.new(0, 10, 0, currentY)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = configControlsFrame

		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 30, 0, 30)
		toggleButton.Position = UDim2.new(0, 2, 0, 2)
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame

		local isRainbow = MergedAimbot.FOVSettings.RainbowColor

		local function updateToggle()
			if isRainbow then
				toggleButton.Position = UDim2.new(0, 32, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			else
				toggleButton.Position = UDim2.new(0, 2, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		toggleButton.MouseButton1Click:Connect(function()
			isRainbow = not isRainbow
			MergedAimbot.FOVSettings.RainbowColor = isRainbow
			updateToggle()
		end)
		updateToggle()
		currentY = currentY + 40
	end

	do
		local rainbowLabel = createLabel("Velocidade Rainbow: " .. MergedAimbot.FOVSettings.RainbowSpeed, configControlsFrame)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
		sliderFrame.Position = UDim2.new(0, 10, 0, currentY)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		sliderFrame.Parent = configControlsFrame

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 1, 0)
		local currentSpeed = MergedAimbot.FOVSettings.RainbowSpeed
		local normalizedSpeed = (currentSpeed - 0.1) / (5 - 0.1)
		knob.Position = UDim2.new(normalizedSpeed, 0, 0, 0)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.Parent = sliderFrame

		local draggingSlider = false
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = true
			end
		end)
		knob.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)
		sliderFrame.InputChanged:Connect(function(input)
			if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
				local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
				local scale = relativeX / sliderFrame.AbsoluteSize.X
				knob.Position = UDim2.new(scale, 0, 0, 0)
				local newSpeed = 0.1 + scale * (5 - 0.1)
				MergedAimbot.FOVSettings.RainbowSpeed = newSpeed
				rainbowLabel.Text = "Velocidade Rainbow: " .. string.format("%.2f", newSpeed)
			end
		end)
		currentY = currentY + 30
	end

end

print("Merged Aimbot com UI customizada carregado com sucesso!")

local function getNearestPlayer()
	local nearestPlayer = nil
	local shortestDistanceSq = math.huge
	local camPos = Camera.CFrame.Position

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if MergedAimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then
				continue
			end
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if MergedAimbot.Settings.AliveCheck and (humanoid and humanoid.Health <= 0) then
				continue
			end

			local targetPart = player.Character:FindFirstChild(MergedAimbot.Settings.LockPart)
			if not targetPart then
				continue
			end

			local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
			local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
			local distToMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude

			if distToMouse <= MergedAimbot.FOVSettings.Radius then
				local distanceSq = (camPos - targetPart.Position).Magnitude^2
				if distanceSq < shortestDistanceSq then
					if MergedAimbot.Settings.WallCheck then
						if not hasLineOfSight(camPos, targetPart.Position, player.Character) then
							continue
						end
					end
					shortestDistanceSq = distanceSq
					nearestPlayer = player
				end
			end
		end
	end
	return nearestPlayer
end

RunService.RenderStepped:Connect(function(deltaTime)
	if MergedAimbot.FOVSettings.Enabled then
		local mousePos = UserInputService:GetMouseLocation()
		FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
		if MergedAimbot.FOVSettings.RainbowColor then
			FOVCircle.Color = GetRainbowColor()
		else
			FOVCircle.Color = MergedAimbot.FOVSettings.Color
		end
	end

	if MergedAimbot.Settings.Enabled then
		local target = getNearestPlayer()
		MergedAimbot.Target = target

		if target and target.Character then
			local character = target.Character
			local head = character:FindFirstChild("Head")
			local root = character:FindFirstChild("HumanoidRootPart")
			if head and root then
				local targetPosition
				if character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0 then
					targetPosition = root.Position
				else
					targetPosition = head.Position
				end

				if MergedAimbot.Settings.LockMode == 2 then
					local screenPoint = Camera:WorldToViewportPoint(targetPosition)
					local mousePos = UserInputService:GetMouseLocation()
					local deltaX = (screenPoint.X - mousePos.X) / MergedAimbot.Settings.Sensitivity2
					local deltaY = (screenPoint.Y - mousePos.Y) / MergedAimbot.Settings.Sensitivity2
					mousemoverel(deltaX, deltaY)
				else
					if MergedAimbot.Settings.Sensitivity > 0 then
						local tweenInfo = TweenInfo.new(MergedAimbot.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local newCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
						local tween = TweenService:Create(Camera, tweenInfo, { CFrame = newCFrame })
						tween:Play()
					else
						Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
					end
					UserInputService.MouseDeltaSensitivity = 0
				end

				if MergedAimbot.Settings.FireMode == "auto" then
					mouse1Click()
				elseif MergedAimbot.Settings.FireMode == "hold" then
					if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						mouse1Press()
					end
				else
					mouse1Release()
				end
			end
		else
			UserInputService.MouseDeltaSensitivity = 1
		end
	else
		UserInputService.MouseDeltaSensitivity = 1
		MergedAimbot.Target = nil
	end
end)

RunService.Heartbeat:Connect(function()
	if MergedAimbot.ESPEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local character = player.Character
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local teamColor = Color3.new(1, 1, 1)
					if player.Team and player.TeamColor then
						teamColor = player.TeamColor.Color
					end

					local highlight = character:FindFirstChild("ESP_Highlight")
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "ESP_Highlight"
						highlight.FillTransparency = 1
						highlight.OutlineTransparency = 0
						highlight.OutlineColor3 = teamColor
						highlight.Parent = character
					else
						highlight.OutlineColor3 = teamColor
					end
				else
					local highlight = character:FindFirstChild("ESP_Highlight")
					if highlight then
						highlight:Destroy()
					end
				end
			end
		end
	else
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local highlight = player.Character:FindFirstChild("ESP_Highlight")
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end)

function MergedAimbot:Exit()
	FOVCircle:Remove()
	if MergedAimbot.ScreenGui then
		MergedAimbot.ScreenGui:Destroy()
	end
	UserInputService.MouseDeltaSensitivity = 1
	self.Settings.Enabled = false
end

getgenv().MergedAimbot = MergedAimbot