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
player:SetPosition(875.52,-2.60,1342.19);sceneLoader:AddChild(player);
	asset = ParaAsset.LoadStaticMesh("", "model/05plants/v5/01tree/GreenBroadleaf/GreenBroadleaf_all.x");
player=cpmesh("", asset, 22.02563,22.02563,22.02563, true, "1,0,0,0,1,0,0,0,1,0,0,0");
player:SetPosition(786.67,0.00,1311.85);sceneLoader:AddChild(player);
	asset = ParaAsset.LoadStaticMesh("", "model/05plants/v5/01tree/SandyBrownHardwood/SandyBrownHardwood.x");
player=cpmesh("", asset, 5.42259,5.42259,5.42259, false, "0.8,0,0,0,0.8,0,0,0,0.8,0,0,0");
player:SetPosition(798.19,0.00,1304.80);sceneLoader:AddChild(player);
ParaScene.Attach(sceneLoader);