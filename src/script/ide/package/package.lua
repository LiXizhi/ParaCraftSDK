--[[ 
Title: NPL package system 
Author(s): LiXizhi
Date: 2008.5.11
Desc: This class is part of commonlib
---++ What is a package?
A package is a redistributable zip file containing asset files and may optionally having an installer script or an start up script. 
A zip package file is first downloaded or manually copied to the "packages/" directory. And should be named as [MyPackageName]-[version].zip
When a package is loaded, the files in side the zip package files will be available via the NPL file io. 

There are four kinds of packages: startup, lib, installer, redist

---+++ startup packages
package files under "packages/startup/" are assumed to be start up packages. They are loaded early when ParaEngine start up. It is suitable to 
distribute core applications, common assets, etc as startup packages. The package start up script is called when a package is loaded this way.
the startup script file must be named "[MyPackageName]-[version].zip.startup.lua", and it will search for this file in the "packages/" directory 
as well as all its first level sub directories. 
HINT: one can put the start up script inside the zip package itself.

---+++ lib packages
package files under "packages/" are assumed to be lib packages. They are loaded On Demand when a client applications calls commonlib.package.use("MyPackageName"). 
It is suitable to distribute extensions to applications, such as world specific assets, extension games, shared art pack, etc as lib packages. The package start up script is called when a package is loaded this way.
the startup script file must be named "[MyPackageName]-[version].zip.startup.lua", and it will search for this file in the "packages/" directory 
as well as all its first level sub directories. 

---+++ installer packages
package files under "packages/installer" are assumed to be installer packages. When the main interface is loaded, the ParaWorld platform will popup a dialog 
for each installer package, asking for user to install or skip the package. It is suitable to distribute application patches, updates or very important big 
applications as installer packages. The package installer script is called when a package is loaded this way.
the installer script file must be named "[MyPackageName]-[version].zip.startup.lua", and it will search for this file in the "packages/" directory 
as well as all its first level sub directories. 

---+++ redist packages
This is actually not a specific package type. Developers can create new packages in this directory, since contents in this folder are not processed in the package system. 
When it is ready, they can copy or move the packages to other folders accroding to package type. The AssetsApp contains a PackageMaker application that helps developers 
to make redistributable packages.

---++ Package Versioning
At run time, multiple versions of a packages can be loaded at the same time, however whether it can work properly is up to the package author. 
An author is encourage to write and use version aware application codes. Basically if one uses a package without specifying its version, the latest version is automatically located and used. 

---++ Package Format
There are two supported package file format: zip or pkg. Zip is the widely supported zip format; where pkg is an encrpted zip format defined by ParaEngine and solely used by official applications. 
if there is a zip and pkg file with the same name and version number under a directory, the zip file is used. Zip file only falls back to pkg file. 

Use Lib:
------------------------------------------------------
NPL.load("(gl)script/ide/package/package.lua");

-- at any time, call following to ensure package is loaded on demand. 
commonlib.package.require("MyPackageName", "1.0")
commonlib.package.require("MyPackageName")

-- when ParaEngine starts up, call following function only once to start startup script. Usually at one of the beginning lines of the game interface script.
commonlib.package.Startup();
------------------------------------------------------
]]

NPL.load("(gl)script/ide/NPLExtension.lua");

if(commonlib==nil) then commonlib={} end
if(commonlib.package==nil) then commonlib.package={} end
local package = commonlib.package;
-- mapping from package name to package info
package.pkgs = {};

-------------------------------------
-- public methods:
-------------------------------------

-- use a package, this function will ensure that the package is loaded
-- @param packageName: string name of the package without version number. e.g. suppose your package file is 
--  called packages/mypackage-101.zip. then the package name should be "mypackage"
-- @param packageVersion: the version can be nil, a number or a string containing a number. 
--  If nil, the latest version will be used. Otherwise it will try to find an available version.
-- @return: true if loaded, otherwise nil. 
function package.require(packageName, packageVersion)
	local pkgInfo = package.pkgs[packageName];
	local version;
	if(type(packageVersion)== "string") then
		version = tonumber(string.match(packageVersion, "%d+"));
		if(version == nil) then
			commonlib.log("warning: %s, %s package version must either be a number or contain a number.\n", packageName, tostring(packageVersion))
		end
	else
		version = packageVersion;
	end
	version = version or 0;
	
	if(pkgInfo) then
		if(pkgInfo.version>=version) then
			return pkgInfo:Load();
		else
			commonlib.log("warning: no matching version found for package %s-%s. The current highest version is %s\n", packageName, tostring(packageVersion), tostring(pkgInfo.version));
		end
	else
		commonlib.log("warning: uable to find package %s-%s. \n", packageName, tostring(packageVersion))
	end
end

-- refresh package info in "packages/" and its sub directories, and 
-- load the latest version of all packages in the packages/startup folder
-- @return: the number of packages are returned. 
function package.Startup()
	-- refresh package info in "packages/" and its sub directories.
	package.BuildPackageInfoInFolder("packages/", 1);

	-- load the latest version of all packages in the packages/startup folder
	local _, pkgInfo;
	for _, pkgInfo in pairs(package.pkgs) do
		if(pkgInfo.type == 1) then
			-- load only startup package
			pkgInfo:Load();
		end	
	end
end

-------------------------------------
-- package info
-------------------------------------
local PackageInfo = {
	-- nil: lib package, 1: startup package, 2: installer package, 3 is other (redist) package. 
	type = nil,
	-- whether the package is loaded or not. 
	IsLoaded = nil,
	-- package major name
	name = nil,
	-- package minor version. currently only the first minor number is used. 
	version = 0,
	-- startup script: nil means not searched. "" means does not have this script, or it should be an valid string path. 
	StartupScript = nil,
	-- full package file path string. 
	filepath = nil,
	-- file extension, zip or pkg.
	ext = nil,
}
function PackageInfo:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Load this package if not loaded before. it will cause the startup or installer script to be called. 
-- @return: true if loaded succesfully. 
function PackageInfo:Load()
	if(not self.IsLoaded) then
		self.IsLoaded = true;
		ParaAsset.OpenArchive(self.filepath);
		-- search for the installer or startup script and load it. 
		if(NPL.CheckLoad(self.filepath..".startup.lua") )then
			self.StartupScript = self.filepath..".startup.lua"
		else
			-- TODO: shall we search else where? such as the current zip file root and the redist folder?
		end
		log(self.filepath.." is loaded\n");
		if(self.StartupScript and self.StartupScript ~="") then
			log("\t\twith startup script.\n");
		end
		return true;
	end
end

-------------------------------------
-- private functions: 
-------------------------------------

-- a mapping from path to package type
local packageTypePath = {
	["packages"] = nil,
	["packages/startup"] = 1,
	["packages/installer"] = 2,
	["packages/redist"] = 3,
};
-- Create a new package from file path. It just derives package information from 
-- @param filepath: such as packages/startup/test-1.0.zip
-- @return nil or a new PackageInfo is returned.  
function PackageInfo.CreateFromPath(filepath)
	local parentDir, filename, ext = string.match(filepath, "^(.*)/([^/]+)%.(%w+)$")
	if(ext and (ext == "pkg" or ext == "zip")) then
		local name = string.match(filename, "([^%-]+)");
		-- currently only the first minor number is used. 
		local version = tonumber(string.match(filename, "%d+"));
		
		local pkgInfo = PackageInfo:new ({
			type = packageTypePath[parentDir],
			filepath = filepath, 
			name = name,
			version = version,
			ext=ext,
		});
		--commonlib.echo({type=pkgInfo.type, filepath=pkgInfo.filepath, ext=pkgInfo.ext})
		return pkgInfo;
	end
end

-- build package info of all packages in a given folder
-- @param folderPath: where the packages are located. such as "packages/startup/", "packages/installer/" , "packages/" , "packages/redist/" 
-- @param nSubFolderLevel: how many levels of sub folders to search for. if nil, it defaults to 0 which is the current folder. 
function package.BuildPackageInfoInFolder(folderPath, nSubFolderLevel)
	if(not string.match(folderPath, "[/\\]$")) then
		folderPath = folderPath.."/"
	end
	local files = {};
	commonlib.SearchFiles(files, folderPath, "*.*", nSubFolderLevel or 0, 3000, true);
	local k, path;
	for k, path in ipairs(files) do
		local pkgInfo = PackageInfo.CreateFromPath(folderPath..path)
		if(pkgInfo) then
			package.InsertPackageInfo(pkgInfo)
		end
	end	
end

-- insert a new package info to the current pool. 
function package.InsertPackageInfo(pkgInfo)
	if(pkgInfo and pkgInfo.name) then
		local oldInfo = package.pkgs[pkgInfo.name];
		if(oldInfo) then
			if (oldInfo.version > pkgInfo.version) then
				return -- there is already a newer version
			elseif (oldInfo.version == pkgInfo.version) then
				if( oldInfo.ext==pkgInfo.pkg or oldInfo.ext=="zip") then
					return -- there is already the same version or same zip version loaded. 
				end					
			end
		end
		package.pkgs[pkgInfo.name] = pkgInfo;
	end	
end
