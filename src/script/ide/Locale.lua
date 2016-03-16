--[[
Title: A simple lib for managing localization completely in the scripting interface. 
Author(s): LiXizhi
Date: 2006/11/24
Desc: I have referred to Locale-2.0 by ckknight
Use Lib: 
-------------------------------------------------------
-- in localization file KidsUI-enUS.lua, we can build strings like these
NPL.load("(gl)script/ide/Locale.lua");
local L = CommonCtrl.Locale:new("KidsUI");
L:RegisterTranslations("enUS", function() return {
	-- Bindings
	["Hello!"] = true,
	["Greating"] = "hi, there!",
} end);

-- in localization file KidsUI-zhCN.lua, we can build strings like these
NPL.load("(gl)script/ide/Locale.lua");
local L = CommonCtrl.Locale:new("KidsUI");
L:RegisterTranslations("zhCN", function() return {
	-- Bindings
	["Hello!"] = "你好！",
	["Greating"] = "你好啊!",
} end);

-- when application starts, load all available local files, see "script/lang.lua"
NPL.load("(gl)script/ide/Locale.lua");
CommonCtrl.Locale.AutoLoadFile("KidsUI-zhCN.lua");
CommonCtrl.Locale.AutoLoadFile("KidsUI-enUS.lua");

-- GNU gettext way
local L = CommonCtrl.Locale:new("KidsUI");
L:SetStrictness("nocheck");
L:Reset();
local t = L:GetTranslationTable();
t["Hello"] = "你好"; -- add all entries

-- in normal scripts, we can use.
local L = CommonCtrl.Locale:new("KidsUI");
local str = L("Hello!")..L"Greating"
-------------------------------------------------------
]]
-- common library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua");

-- whether write error log
local enable_log = false;
-- whether enable locale globally. 
local enable_locale = true;

-- used for printing errors
local function print_error(self, ...)
	if(enable_log) then
		commonlib.warning(self, ...);
	end
end

-- define a new control in the common control libary
local Locale = {
	registry = {}, 
	error = "",
	print_error = print_error,  
}
CommonCtrl.Locale = Locale;
commonlib.Locale = Locale;

-- whether to enable error log. log is disabled by default. however, one can enable it to debug missing locale. 
function Locale.EnableLog(bEnable)
	enable_log = bEnable;
end

-- this will enable/disable locale string look globally. If false, querying a string will always return the string itself without checking. 
function Locale.EnableLocale(bEnable)
	enable_locale = bEnable;
end

-- only load the file if the locale in the file matches the current locale. 
-- the file name must be in the format X[lang].lua, where [lang] is the locale string such as enUS.
-- if [lang] is not known locale, it will be discarded. 
function Locale.AutoLoadFile(file)
	-- get locale from file name
	local len = string.len(file);
	if(len > 8) then
		local lang = string.sub(file, len-7, len-4);
		if(lang == ParaEngine.GetLocale()) then
			NPL.load("(gl)"..file);
		end
	end	
end

-- get a given translation by its name. it will return nil if does not exist. 
function Locale:GetByName(name)
	return self.registry[name];
end

-- create or get a given translation. 
function Locale:new(name)
	
	if self.registry[name] then
		return self.registry[name]
	end
	
	local o = setmetatable({}, {
		__index = self.prototype,
		__call = self.prototype.GetTranslation,
		__tostring = function(self)
			return "Locale(" .. name .. ")"
		end
	})
	
	Locale.registry[name] = o
	return o
end

setmetatable(Locale, { __call = Locale.new })

Locale.prototype = {
	print_error = print_error,
}
Locale.prototype.class = Locale

function Locale.prototype:EnableDebugging()
	if self.baseTranslations then
		log("Cannot enable debugging after a translation has been registered.")
	end
	self.debugging = true
end


function Locale.prototype:RegisterTranslations(locale, func)
	if self.baseTranslations and ParaEngine.GetLocale() ~= locale then
		if self.debugging then
			local t = func()
			func = nil
			if type(t) ~= "table" then
				log("Bad argument #3 to `RegisterTranslation'. function did not return a table. (expected table)")
			end
			self.translationTables[locale] = t
			t = nil
		end
		func = nil
		collectgarbage()
		return
	end
	local t = func()
	func = nil
	if type(t) ~= "table" then
		log("Bad argument #3 to `RegisterTranslation'. function did not return a table. (expected table)")
	end
	
	self.translations = t
	if not self.baseTranslations then
		self.baseTranslations = t
		self.baseLocale = locale
		for key,value in pairs(self.baseTranslations) do
			if value == true then
				self.baseTranslations[key] = key
			end
		end
	else
		for key, value in pairs(self.translations) do
			if not self.baseTranslations[key] then
				self:print_error("Improper translation exists. %q is likely misspelled for locale %q.", key, locale)
			elseif value == true then
				self:print_error("Can only accept true as a value on the base locale. %q is the base locale, %q is not.", self.baseLocale, locale)
			end
		end
	end
	if self.debugging then
		if not self.translationTables then
			self.translationTables = {}
		end
		self.translationTables[locale] = t
	end
	t = nil
	collectgarbage()
end

-- @param strictness: "strict", "nocheck", nil: default to nil. "nocheck" is recommended for it just returned the text
function Locale.prototype:SetStrictness(strictness)
	local mt = getmetatable(self)
	if not mt then
		self:print_error("Cannot call `SetStrictness' without a metatable.")
	end
	if strictness == "strict" then
		mt.__call = self.GetTranslationStrict
	elseif strictness == "nocheck" then
		mt.__call = self.GetTranslationNoCheck
	else
		mt.__call = self.GetTranslation
	end
end

-- this function is mostly used by "nocheck" translation to register a new translation
function Locale.prototype:GetTranslationTable()
	return self.translations;
end

-- clear all translations. this function may be called when language is changed at runtime. 
function Locale.prototype:Reset()
	self.baseTranslations = nil;
	self.translations = {};
end

-- this is the fastest way to retrieve a translation for text. 
-- it gives no errors, just return the translated text or text if not found.  
function Locale.prototype:GetTranslationNoCheck(text)
	return self.translations[text] or text;
end

function Locale.prototype:GetTranslationStrict(text, sublevel)
	if(not enable_locale) then
		return text;
	end
	if not self.translations then
		self:print_error("No translations registered")
	end
	if sublevel then
		local t = self.translations[text]
		if type(t) ~= "table" then
			if type(self.baseTranslations[text]) == "table" then
				self:print_error("%q::%q has not been translated into %q", text, sublevel, locale)
				--return Locale.error
				return text
			else
				self:print_error("Translation for %q::%q does not exist", text, sublevel)
				--return Locale.error
				return text
			end
		end
		local translation = t[sublevel]
		if type(translation) ~= "string" then
			if type(self.baseTranslations[text]) == "table" then
				if type(self.baseTranslations[text][sublevel]) == "string" then
					self:print_error("%q::%q has not been translated into %q", text, sublevel, locale)
					--return Locale.error
				return text
				else
					self:print_error("Translation for %q::%q does not exist", text, sublevel)
					--return Locale.error
					return text
				end
			else
				self:print_error("Translation for %q::%q does not exist", text, sublevel)
				--return Locale.error
				return text
			end
		end
		return translation
	end
	local translation = self.translations[text]
	if type(translation) ~= "string" then
		if type(self.baseTranslations[text]) == "string" then
			self:print_error("%q has not been translated into %q", text, locale)
			--return Locale.error
			return text
		else
			self:print_error("Translation for %q does not exist", text)
			--return Locale.error
			return text
		end
	end
	return translation
end

function Locale.prototype:GetTranslation(text, sublevel)
	if(not enable_locale) then
		return text;
	end
	if(not self.translations) then
		self:print_error("Translation tables does not exist for %s", text)
		return text;
	end
	if sublevel then
		local t = self.translations[text]
		if type(t) == "table" then
			local translation = t[sublevel]
			if type(translation) == "string" then
				return translation
			else
				t = self.baseTranslations[text]
				if type(t) ~= "table" then
					self:print_error("Translation table %q does not exist", text)
					--return Locale.error
					return text
				end
				translation = t[sublevel]
				if type(translation) ~= "string" then
					self:print_error("Translation for %q::%q does not exist", text, sublevel)
					--return Locale.error
					return text
				end
				return translation
			end
		else
			t = self.baseTranslations[text]
			if type(t) ~= "table" then
				self:print_error("Translation table %q does not exist", text)
				--return Locale.error
				return text
			end
			local translation = t[sublevel]
			if type(translation) ~= "string" then
				self:print_error("Translation for %q::%q does not exist", text, sublevel)
				--return Locale.error
				return text
			end
			return translation
		end
	end
	local translation = self.translations[text]
	if type(translation) == "string" then
		return translation
	else
		translation = self.baseTranslations[text]
		if type(translation) ~= "string" then
			self:print_error("Translation for %q does not exist", text)
			--return Locale.error
			return text
		end
		return translation
	end
end

local function initReverse(self)
	self.reverseTranslations = {}
	local alpha = self.translations
	local bravo = self.reverseTranslations
	for base, localized in pairs(alpha) do
		bravo[localized] = base
	end
end

function Locale.prototype:GetReverseTranslation(text)
	if not self.reverseTranslations then
		initReverse(self)
	end
	local translation = self.reverseTranslations[text]
	if type(translation) ~= "string" then
		self:print_error("Reverse translation for %q does not exist", text)
		--return Locale.error
		return text
	end
	return translation
end

function Locale.prototype:GetIterator()
	Locale.assert(self, self.translations, "No translations registered")
	return pairs(self.translations)
end

function Locale.prototype:GetReverseIterator()
	Locale.assert(self, self.translations, "No translations registered")
	if not self.reverseTranslations then
		initReverse(self)
	end
	return pairs(self.reverseTranslations)
end

function Locale.prototype:HasTranslation(text, sublevel)
	if(self.translations) then 
		if sublevel then
			return type(self.translations[text]) == "table" and self.translations[text][sublevel] and true
		end
		return self.translations[text] and true	
	end
end

function Locale.prototype:HasReverseTranslation(text)
	if not self.reverseTranslations then
		initReverse(self)
	end
	return self.reverseTranslations[text] and true
end

function Locale.prototype:GetTableStrict(key, key2)
	if key2 then
		local t = self.translations[key]
		if type(t) ~= "table" then
			if type(self.baseTranslations[key]) == "table" then
				self:print_error("%q::%q has not been translated into %q", key, key2, locale)
				return
			else
				self:print_error("Translation table %q::%q does not exist", key, key2)
				return
			end
		end
		local translation = t[key2]
		if type(translation) ~= "table" then
			if type(self.baseTranslations[key]) == "table" then
				if type(self.baseTranslations[key][key2]) == "table" then
					self:print_error("%q::%q has not been translated into %q", key, key2, locale)
					return
				else
					self:print_error("Translation table %q::%q does not exist", key, key2)
					return
				end
			else
				self:print_error("Translation table %q::%q does not exist", key, key2)
				return
			end
		end
		return translation
	end
	local translation = self.translations[key]
	if type(translation) ~= "table" then
		if type(self.baseTranslations[key]) == "table" then
			self:print_error("%q has not been translated into %q", key, locale)
			return
		else
			self:print_error("Translation table %q does not exist", key)
			return
		end
	end
	return translation
end

function Locale.prototype:GetTable(key, key2)
	if key2 then
		local t = self.translations[key]
		if type(t) == "table" then
			local translation = t[key2]
			if type(translation) == "table" then
				return translation
			else
				t = self.baseTranslations[key]
				if type(t) ~= "table" then
					self:print_error("Translation table %q does not exist", key)
					return
				end
				translation = t[key2]
				if type(translation) ~= "table" then
					self:print_error("Translation table %q::%q does not exist", key, key2)
					return
				end
				return translation
			end
		else
			t = self.baseTranslations[key]
			if type(t) ~= "table" then
				self:print_error("Translation table %q does not exist", key)
				return
			end
			local translation = t[key2]
			if type(translation) ~= "table" then
				self:print_error("Translation table %q::%q does not exist", key, key2)
				return
			end
			return translation
		end
	end
	local translation = self.translations[key]
	if type(translation) == "table" then
		return translation
	else
		translation = self.baseTranslations[key]
		if type(translation) ~= "table" then
			self:print_error("Translation table %q does not exist", key)
			return
		end
		return translation
	end
end

function Locale.prototype:Debug()
	if not self.debugging then
		return
	end
	local words = {}
	local locales = {"enUS", "deDE", "frFR", "zhCN", "zhTW", "koKR"}
	local localizations = {}
	log("--- Locale Debug ---")
	for _,locale in ipairs(locales) do
		if not self.translationTables[locale] then
			log(string.format("Locale %q not found", locale))
		else
			localizations[locale] = self.translationTables[locale]
		end
	end
	local localeDebug = {}
	for locale, localization in pairs(localizations) do
		localeDebug[locale] = {}
		for word in pairs(localization) do
			if type(localization[word]) == "table" then
				if type(words[word]) ~= "table" then
					words[word] = {}
				end
				for bit in pairs(localization[word]) do
					if type(localization[word][bit]) == "string" then
						words[word][bit] = true
					end
				end
			elseif type(localization[word]) == "string" then
				words[word] = true
			end
		end
	end
	for word in pairs(words) do
		if type(words[word]) == "table" then
			for bit in pairs(words[word]) do
				for locale, localization in pairs(localizations) do
					if not localization[word] or not localization[word][bit] then
						localeDebug[locale][word .. "::" .. bit] = true
					end
				end
			end
		else
			for locale, localization in pairs(localizations) do
				if not localization[word] then
					localeDebug[locale][word] = true
				end
			end
		end
	end
	for locale, t in pairs(localeDebug) do
		if not next(t) then
			log(string.format("Locale %q complete", locale))
		else
			log(string.format("Locale %q missing:", locale))
			for word in pairs(t) do
				log(string.format("    %q", word))
			end
		end
	end
	log("--- End Locale Debug ---")
end

-- set global
L = CommonCtrl.Locale("IDE");