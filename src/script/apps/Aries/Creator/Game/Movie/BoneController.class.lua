--[[
Title: Bone controllers
Author(s): LiXizhi
Date: 2015/9/25
Desc: Bone controllers are transforms vectors into multiple bones's parameters, it is mostly used in facial expression. 
Controllers in animation files(such as bmax, fbx, x) can be specified in an xml file using same model filename. 
for example, if model file is test.bmax, then we will automatically look for test.bmax.xml for controller file. 

---++ controller meta file format
<verbatim>
the meta file may contains other informations, so the controller section should be at xpath "mesh/controller"
<mesh>
	<controllers>
		<controller name="mouth">
			<input type="vector2" min_value="-1" max_value="1">
				<output bone="upper_lip_trans" converter="">
					<converter>
						output[2]=input[2]*0.02;output[3]=input[1]*0.02;
					</converter>
				</output>
				<output bone="lower_lip_trans" converter="output[2]=input[2]*0.02"/>
			</input>
		</controller>
	</controllers>
</mesh>
</verbatim>
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BoneController.lua");
local BoneController = commonlib.gettable("MyCompany.Aries.Game.Movie.BoneController");
BoneController.ShowPage()
-------------------------------------------------------
]]
-- @param OnClose: function(values) end 
-- @param last_values: {text, ...}
function BoneController.ShowPage()
end

-- @param filename: the x, fbx, or parax file name or the meta file
function BoneController:LoadFromFile(filename)
end
