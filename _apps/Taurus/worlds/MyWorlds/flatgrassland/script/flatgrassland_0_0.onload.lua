local sceneLoader = ParaScene.GetObject("<managed_loader>flatgrassland_0_0.onload.lua");
if (sceneLoader:IsValid() == true) then 
	ParaScene.Attach(sceneLoader);
	return
end
sceneLoader = ParaScene.CreateManagedLoader("flatgrassland_0_0.onload.lua");
local player, asset, playerChar,att;
local cpmesh=ParaScene.CreateMeshPhysicsObject;
	asset = ParaAsset.LoadStaticMesh("", "model/04deco/v5/blockworld/Torch/Torch_Side.x");
player=cpmesh("", asset, 1.29853,1.29853,1.29853, false, "1.04167,0,0,0,1.04167,0,0,0,1.04167,0,0,0");
player:SetPosition(342.18747,-2.60417,275.52082);sceneLoader:AddChild(player);
	asset = ParaAsset.LoadStaticMesh("", "model/05plants/v5/01tree/GreenBroadleaf/GreenBroadleaf_all.x");
player=cpmesh("", asset, 22.02563,22.02563,22.02563, true, "1,0,0,0,1,0,0,0,1,0,0,0");
player:SetPosition(253.33483,0,245.18471);sceneLoader:AddChild(player);
	asset = ParaAsset.LoadStaticMesh("", "model/05plants/v5/01tree/SandyBrownHardwood/SandyBrownHardwood.x");
player=cpmesh("", asset, 5.42259,5.42259,5.42259, false, "0.8,0,0,0,0.8,0,0,0,0.8,0,0,0");
player:SetPosition(264.85883,0,238.13016);sceneLoader:AddChild(player);
ParaScene.Attach(sceneLoader);
