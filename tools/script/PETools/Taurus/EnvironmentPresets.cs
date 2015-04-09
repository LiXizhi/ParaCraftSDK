using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.ComponentModel;
using System.Xml;
using System.Xml.Serialization;
using System.Collections;
using System.Drawing.Design;

using PETools.World.TypeConverter;
using PETools.EntityTemplates.Buildin;

namespace PETools.EntityTemplates.Taurus
{
	[NPLCommand("goto", func_name="goto")]
	public class EnvPresets : IBindableObject
	{
	   	public EnvPresets() {}
	public EnvPresets(string _uid,string _worldfilter,string _codefile,string _template_file,bool _DrawOcean,double _WaterLevel,XmlElement _OceanColor,double _WindSpeed,double _WindDirection,double _RenderTechnique,bool _EnableTerrainReflection,bool _EnableMeshReflection,bool _EnablePlayerReflection,bool _EnableCharacterReflection,XmlElement _SkyColor,double _SkyFogAngleFrom,double _SkyFogAngleTo,bool _SimulatedSky,bool _IsAutoDayTime,double _NearPlane,double _FarPlane,double _FieldOfView,double _AspectRatio,bool _FullScreenGlow,double _GlowIntensity,double _GlowFactor,XmlElement _Glowness,bool _EnableSunLight,bool _EnableLight,bool _ShowLights,double _MaxLightsNum,bool _SetShadow,double _MaxNumShadowCaster,double _MaxNumShadowReceiver,double _MaxCharTriangles,XmlElement _BackgroundColor,bool _EnableFog,XmlElement _FogColor,double _FogStart,double _FogEnd,double _FogDensity,double _MinPopUpDistance,bool _ShowSky,bool _ShowBoundingBox,bool _ShowPortalSystem,bool _EnablePortalZone,bool _GenerateReport,bool _AutoPlayerRipple,bool _ShowHeadOnDisplay,bool _UseWireFrame,double _PhysicsDebugDrawMode) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._DrawOcean = _DrawOcean;
this._WaterLevel = _WaterLevel;
this._OceanColor = _OceanColor;
this._WindSpeed = _WindSpeed;
this._WindDirection = _WindDirection;
this._RenderTechnique = _RenderTechnique;
this._EnableTerrainReflection = _EnableTerrainReflection;
this._EnableMeshReflection = _EnableMeshReflection;
this._EnablePlayerReflection = _EnablePlayerReflection;
this._EnableCharacterReflection = _EnableCharacterReflection;
this._SkyColor = _SkyColor;
this._SkyFogAngleFrom = _SkyFogAngleFrom;
this._SkyFogAngleTo = _SkyFogAngleTo;
this._SimulatedSky = _SimulatedSky;
this._IsAutoDayTime = _IsAutoDayTime;
this._NearPlane = _NearPlane;
this._FarPlane = _FarPlane;
this._FieldOfView = _FieldOfView;
this._AspectRatio = _AspectRatio;
this._FullScreenGlow = _FullScreenGlow;
this._GlowIntensity = _GlowIntensity;
this._GlowFactor = _GlowFactor;
this._Glowness = _Glowness;
this._EnableSunLight = _EnableSunLight;
this._EnableLight = _EnableLight;
this._ShowLights = _ShowLights;
this._MaxLightsNum = _MaxLightsNum;
this._SetShadow = _SetShadow;
this._MaxNumShadowCaster = _MaxNumShadowCaster;
this._MaxNumShadowReceiver = _MaxNumShadowReceiver;
this._MaxCharTriangles = _MaxCharTriangles;
this._BackgroundColor = _BackgroundColor;
this._EnableFog = _EnableFog;
this._FogColor = _FogColor;
this._FogStart = _FogStart;
this._FogEnd = _FogEnd;
this._FogDensity = _FogDensity;
this._MinPopUpDistance = _MinPopUpDistance;
this._ShowSky = _ShowSky;
this._ShowBoundingBox = _ShowBoundingBox;
this._ShowPortalSystem = _ShowPortalSystem;
this._EnablePortalZone = _EnablePortalZone;
this._GenerateReport = _GenerateReport;
this._AutoPlayerRipple = _AutoPlayerRipple;
this._ShowHeadOnDisplay = _ShowHeadOnDisplay;
this._UseWireFrame = _UseWireFrame;
this._PhysicsDebugDrawMode = _PhysicsDebugDrawMode;
	}
	
	   			private string _uid;
				
				[Description("unique id")]
				
				
				public override string uid
				{
				
					get { return _uid; }
					set
					{
						_uid = value;
						OnPropertyChanged(new PropertyChangedEventArgs("uid"));
					}
				}			private string _worldfilter;
				
				[Description("if empty, it means the current world. if .*, it means global.")]
				
				
				public override string worldfilter
				{
				
					get { return _worldfilter; }
					set
					{
						_worldfilter = value;
						OnPropertyChanged(new PropertyChangedEventArgs("worldfilter"));
					}
				}			private string _codefile;
				
				[Description("code behind file")]
				
				
				
				public string codefile
				{
					get { return _codefile; }
					set
					{
						_codefile = value;
						OnPropertyChanged(new PropertyChangedEventArgs("codefile"));
					}
				}			private string _template_file;
				
				[Description("the template file used for creating the object")]
				
				
				public override string template_file
				{
				
					get { return _template_file; }
					set
					{
						_template_file = value;
						OnPropertyChanged(new PropertyChangedEventArgs("template_file"));
					}
				}			private bool _DrawOcean;
				
				
				
				
				
				public bool DrawOcean
				{
					get { return _DrawOcean; }
					set
					{
						_DrawOcean = value;
						OnPropertyChanged(new PropertyChangedEventArgs("DrawOcean"));
					}
				}			private double _WaterLevel;
				
				
				
				
				
				public double WaterLevel
				{
					get { return _WaterLevel; }
					set
					{
						_WaterLevel = value;
						OnPropertyChanged(new PropertyChangedEventArgs("WaterLevel"));
					}
				}			private XmlElement _OceanColor;
				
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement OceanColor
				{
					get { return _OceanColor; }
					set
					{
						_OceanColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("OceanColor"));
					}
				}			private double _WindSpeed;
				
				
				
				
				
				public double WindSpeed
				{
					get { return _WindSpeed; }
					set
					{
						_WindSpeed = value;
						OnPropertyChanged(new PropertyChangedEventArgs("WindSpeed"));
					}
				}			private double _WindDirection;
				
				
				
				
				
				public double WindDirection
				{
					get { return _WindDirection; }
					set
					{
						_WindDirection = value;
						OnPropertyChanged(new PropertyChangedEventArgs("WindDirection"));
					}
				}			private double _RenderTechnique;
				
				
				
				
				
				public double RenderTechnique
				{
					get { return _RenderTechnique; }
					set
					{
						_RenderTechnique = value;
						OnPropertyChanged(new PropertyChangedEventArgs("RenderTechnique"));
					}
				}			private bool _EnableTerrainReflection;
				
				
				
				
				
				public bool EnableTerrainReflection
				{
					get { return _EnableTerrainReflection; }
					set
					{
						_EnableTerrainReflection = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableTerrainReflection"));
					}
				}			private bool _EnableMeshReflection;
				
				
				
				
				
				public bool EnableMeshReflection
				{
					get { return _EnableMeshReflection; }
					set
					{
						_EnableMeshReflection = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMeshReflection"));
					}
				}			private bool _EnablePlayerReflection;
				
				
				
				
				
				public bool EnablePlayerReflection
				{
					get { return _EnablePlayerReflection; }
					set
					{
						_EnablePlayerReflection = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnablePlayerReflection"));
					}
				}			private bool _EnableCharacterReflection;
				
				
				
				
				
				public bool EnableCharacterReflection
				{
					get { return _EnableCharacterReflection; }
					set
					{
						_EnableCharacterReflection = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableCharacterReflection"));
					}
				}			private XmlElement _SkyColor;
				
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement SkyColor
				{
					get { return _SkyColor; }
					set
					{
						_SkyColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SkyColor"));
					}
				}			private double _SkyFogAngleFrom;
				
				
				
				
				
				public double SkyFogAngleFrom
				{
					get { return _SkyFogAngleFrom; }
					set
					{
						_SkyFogAngleFrom = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SkyFogAngleFrom"));
					}
				}			private double _SkyFogAngleTo;
				
				
				
				
				
				public double SkyFogAngleTo
				{
					get { return _SkyFogAngleTo; }
					set
					{
						_SkyFogAngleTo = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SkyFogAngleTo"));
					}
				}			private bool _SimulatedSky;
				
				
				
				
				
				public bool SimulatedSky
				{
					get { return _SimulatedSky; }
					set
					{
						_SimulatedSky = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SimulatedSky"));
					}
				}			private bool _IsAutoDayTime;
				
				
				
				
				
				public bool IsAutoDayTime
				{
					get { return _IsAutoDayTime; }
					set
					{
						_IsAutoDayTime = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsAutoDayTime"));
					}
				}			private double _NearPlane;
				
				
				
				
				
				public double NearPlane
				{
					get { return _NearPlane; }
					set
					{
						_NearPlane = value;
						OnPropertyChanged(new PropertyChangedEventArgs("NearPlane"));
					}
				}			private double _FarPlane;
				
				
				
				
				
				public double FarPlane
				{
					get { return _FarPlane; }
					set
					{
						_FarPlane = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FarPlane"));
					}
				}			private double _FieldOfView;
				
				
				
				
				
				public double FieldOfView
				{
					get { return _FieldOfView; }
					set
					{
						_FieldOfView = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FieldOfView"));
					}
				}			private double _AspectRatio;
				
				
				
				
				
				public double AspectRatio
				{
					get { return _AspectRatio; }
					set
					{
						_AspectRatio = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AspectRatio"));
					}
				}			private bool _FullScreenGlow;
				
				
				
				
				
				public bool FullScreenGlow
				{
					get { return _FullScreenGlow; }
					set
					{
						_FullScreenGlow = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FullScreenGlow"));
					}
				}			private double _GlowIntensity;
				
				
				
				
				
				public double GlowIntensity
				{
					get { return _GlowIntensity; }
					set
					{
						_GlowIntensity = value;
						OnPropertyChanged(new PropertyChangedEventArgs("GlowIntensity"));
					}
				}			private double _GlowFactor;
				
				
				
				
				
				public double GlowFactor
				{
					get { return _GlowFactor; }
					set
					{
						_GlowFactor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("GlowFactor"));
					}
				}			private XmlElement _Glowness;
				
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement Glowness
				{
					get { return _Glowness; }
					set
					{
						_Glowness = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Glowness"));
					}
				}			private bool _EnableSunLight;
				
				
				
				
				
				public bool EnableSunLight
				{
					get { return _EnableSunLight; }
					set
					{
						_EnableSunLight = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableSunLight"));
					}
				}			private bool _EnableLight;
				
				
				
				
				
				public bool EnableLight
				{
					get { return _EnableLight; }
					set
					{
						_EnableLight = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableLight"));
					}
				}			private bool _ShowLights;
				
				
				
				
				
				public bool ShowLights
				{
					get { return _ShowLights; }
					set
					{
						_ShowLights = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowLights"));
					}
				}			private double _MaxLightsNum;
				
				
				
				
				
				public double MaxLightsNum
				{
					get { return _MaxLightsNum; }
					set
					{
						_MaxLightsNum = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MaxLightsNum"));
					}
				}			private bool _SetShadow;
				
				
				
				
				
				public bool SetShadow
				{
					get { return _SetShadow; }
					set
					{
						_SetShadow = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SetShadow"));
					}
				}			private double _MaxNumShadowCaster;
				
				
				
				
				
				public double MaxNumShadowCaster
				{
					get { return _MaxNumShadowCaster; }
					set
					{
						_MaxNumShadowCaster = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MaxNumShadowCaster"));
					}
				}			private double _MaxNumShadowReceiver;
				
				
				
				
				
				public double MaxNumShadowReceiver
				{
					get { return _MaxNumShadowReceiver; }
					set
					{
						_MaxNumShadowReceiver = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MaxNumShadowReceiver"));
					}
				}			private double _MaxCharTriangles;
				
				
				
				
				
				public double MaxCharTriangles
				{
					get { return _MaxCharTriangles; }
					set
					{
						_MaxCharTriangles = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MaxCharTriangles"));
					}
				}			private XmlElement _BackgroundColor;
				
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement BackgroundColor
				{
					get { return _BackgroundColor; }
					set
					{
						_BackgroundColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("BackgroundColor"));
					}
				}			private bool _EnableFog;
				
				
				
				
				
				public bool EnableFog
				{
					get { return _EnableFog; }
					set
					{
						_EnableFog = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableFog"));
					}
				}			private XmlElement _FogColor;
				
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement FogColor
				{
					get { return _FogColor; }
					set
					{
						_FogColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FogColor"));
					}
				}			private double _FogStart;
				
				
				
				
				
				public double FogStart
				{
					get { return _FogStart; }
					set
					{
						_FogStart = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FogStart"));
					}
				}			private double _FogEnd;
				
				
				
				
				
				public double FogEnd
				{
					get { return _FogEnd; }
					set
					{
						_FogEnd = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FogEnd"));
					}
				}			private double _FogDensity;
				
				
				
				
				
				public double FogDensity
				{
					get { return _FogDensity; }
					set
					{
						_FogDensity = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FogDensity"));
					}
				}			private double _MinPopUpDistance;
				
				
				
				
				
				public double MinPopUpDistance
				{
					get { return _MinPopUpDistance; }
					set
					{
						_MinPopUpDistance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MinPopUpDistance"));
					}
				}			private bool _ShowSky;
				
				
				
				
				
				public bool ShowSky
				{
					get { return _ShowSky; }
					set
					{
						_ShowSky = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowSky"));
					}
				}			private bool _ShowBoundingBox;
				
				
				
				
				
				public bool ShowBoundingBox
				{
					get { return _ShowBoundingBox; }
					set
					{
						_ShowBoundingBox = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowBoundingBox"));
					}
				}			private bool _ShowPortalSystem;
				
				
				
				
				
				public bool ShowPortalSystem
				{
					get { return _ShowPortalSystem; }
					set
					{
						_ShowPortalSystem = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowPortalSystem"));
					}
				}			private bool _EnablePortalZone;
				
				
				
				
				
				public bool EnablePortalZone
				{
					get { return _EnablePortalZone; }
					set
					{
						_EnablePortalZone = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnablePortalZone"));
					}
				}			private bool _GenerateReport;
				
				
				
				
				
				public bool GenerateReport
				{
					get { return _GenerateReport; }
					set
					{
						_GenerateReport = value;
						OnPropertyChanged(new PropertyChangedEventArgs("GenerateReport"));
					}
				}			private bool _AutoPlayerRipple;
				
				
				
				
				
				public bool AutoPlayerRipple
				{
					get { return _AutoPlayerRipple; }
					set
					{
						_AutoPlayerRipple = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AutoPlayerRipple"));
					}
				}			private bool _ShowHeadOnDisplay;
				
				
				
				
				
				public bool ShowHeadOnDisplay
				{
					get { return _ShowHeadOnDisplay; }
					set
					{
						_ShowHeadOnDisplay = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowHeadOnDisplay"));
					}
				}			private bool _UseWireFrame;
				
				
				
				
				
				public bool UseWireFrame
				{
					get { return _UseWireFrame; }
					set
					{
						_UseWireFrame = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseWireFrame"));
					}
				}			private double _PhysicsDebugDrawMode;
				
				
				
				
				
				public double PhysicsDebugDrawMode
				{
					get { return _PhysicsDebugDrawMode; }
					set
					{
						_PhysicsDebugDrawMode = value;
						OnPropertyChanged(new PropertyChangedEventArgs("PhysicsDebugDrawMode"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				EnvPresets obj = _obj as EnvPresets;
				if (obj == null)
				{
					return;
				}
			
		if(this._uid != obj.uid)
		{
			this._uid = obj.uid;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("uid"));
		}
		
		if(this._worldfilter != obj.worldfilter)
		{
			this._worldfilter = obj.worldfilter;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("worldfilter"));
		}
		
		if(this._codefile != obj.codefile)
		{
			this._codefile = obj.codefile;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("codefile"));
		}
		
		if(this._template_file != obj.template_file)
		{
			this._template_file = obj.template_file;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("template_file"));
		}
		
		if(this._DrawOcean != obj.DrawOcean)
		{
			this._DrawOcean = obj.DrawOcean;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("DrawOcean"));
		}
		
		if(this._WaterLevel != obj.WaterLevel)
		{
			this._WaterLevel = obj.WaterLevel;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("WaterLevel"));
		}
		
		if(this._OceanColor != obj.OceanColor)
		{
			this._OceanColor = obj.OceanColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("OceanColor"));
		}
		
		if(this._WindSpeed != obj.WindSpeed)
		{
			this._WindSpeed = obj.WindSpeed;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("WindSpeed"));
		}
		
		if(this._WindDirection != obj.WindDirection)
		{
			this._WindDirection = obj.WindDirection;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("WindDirection"));
		}
		
		if(this._RenderTechnique != obj.RenderTechnique)
		{
			this._RenderTechnique = obj.RenderTechnique;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("RenderTechnique"));
		}
		
		if(this._EnableTerrainReflection != obj.EnableTerrainReflection)
		{
			this._EnableTerrainReflection = obj.EnableTerrainReflection;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableTerrainReflection"));
		}
		
		if(this._EnableMeshReflection != obj.EnableMeshReflection)
		{
			this._EnableMeshReflection = obj.EnableMeshReflection;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMeshReflection"));
		}
		
		if(this._EnablePlayerReflection != obj.EnablePlayerReflection)
		{
			this._EnablePlayerReflection = obj.EnablePlayerReflection;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnablePlayerReflection"));
		}
		
		if(this._EnableCharacterReflection != obj.EnableCharacterReflection)
		{
			this._EnableCharacterReflection = obj.EnableCharacterReflection;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableCharacterReflection"));
		}
		
		if(this._SkyColor != obj.SkyColor)
		{
			this._SkyColor = obj.SkyColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SkyColor"));
		}
		
		if(this._SkyFogAngleFrom != obj.SkyFogAngleFrom)
		{
			this._SkyFogAngleFrom = obj.SkyFogAngleFrom;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SkyFogAngleFrom"));
		}
		
		if(this._SkyFogAngleTo != obj.SkyFogAngleTo)
		{
			this._SkyFogAngleTo = obj.SkyFogAngleTo;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SkyFogAngleTo"));
		}
		
		if(this._SimulatedSky != obj.SimulatedSky)
		{
			this._SimulatedSky = obj.SimulatedSky;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SimulatedSky"));
		}
		
		if(this._IsAutoDayTime != obj.IsAutoDayTime)
		{
			this._IsAutoDayTime = obj.IsAutoDayTime;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsAutoDayTime"));
		}
		
		if(this._NearPlane != obj.NearPlane)
		{
			this._NearPlane = obj.NearPlane;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("NearPlane"));
		}
		
		if(this._FarPlane != obj.FarPlane)
		{
			this._FarPlane = obj.FarPlane;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FarPlane"));
		}
		
		if(this._FieldOfView != obj.FieldOfView)
		{
			this._FieldOfView = obj.FieldOfView;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FieldOfView"));
		}
		
		if(this._AspectRatio != obj.AspectRatio)
		{
			this._AspectRatio = obj.AspectRatio;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AspectRatio"));
		}
		
		if(this._FullScreenGlow != obj.FullScreenGlow)
		{
			this._FullScreenGlow = obj.FullScreenGlow;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FullScreenGlow"));
		}
		
		if(this._GlowIntensity != obj.GlowIntensity)
		{
			this._GlowIntensity = obj.GlowIntensity;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("GlowIntensity"));
		}
		
		if(this._GlowFactor != obj.GlowFactor)
		{
			this._GlowFactor = obj.GlowFactor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("GlowFactor"));
		}
		
		if(this._Glowness != obj.Glowness)
		{
			this._Glowness = obj.Glowness;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Glowness"));
		}
		
		if(this._EnableSunLight != obj.EnableSunLight)
		{
			this._EnableSunLight = obj.EnableSunLight;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableSunLight"));
		}
		
		if(this._EnableLight != obj.EnableLight)
		{
			this._EnableLight = obj.EnableLight;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableLight"));
		}
		
		if(this._ShowLights != obj.ShowLights)
		{
			this._ShowLights = obj.ShowLights;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowLights"));
		}
		
		if(this._MaxLightsNum != obj.MaxLightsNum)
		{
			this._MaxLightsNum = obj.MaxLightsNum;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MaxLightsNum"));
		}
		
		if(this._SetShadow != obj.SetShadow)
		{
			this._SetShadow = obj.SetShadow;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SetShadow"));
		}
		
		if(this._MaxNumShadowCaster != obj.MaxNumShadowCaster)
		{
			this._MaxNumShadowCaster = obj.MaxNumShadowCaster;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MaxNumShadowCaster"));
		}
		
		if(this._MaxNumShadowReceiver != obj.MaxNumShadowReceiver)
		{
			this._MaxNumShadowReceiver = obj.MaxNumShadowReceiver;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MaxNumShadowReceiver"));
		}
		
		if(this._MaxCharTriangles != obj.MaxCharTriangles)
		{
			this._MaxCharTriangles = obj.MaxCharTriangles;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MaxCharTriangles"));
		}
		
		if(this._BackgroundColor != obj.BackgroundColor)
		{
			this._BackgroundColor = obj.BackgroundColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("BackgroundColor"));
		}
		
		if(this._EnableFog != obj.EnableFog)
		{
			this._EnableFog = obj.EnableFog;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableFog"));
		}
		
		if(this._FogColor != obj.FogColor)
		{
			this._FogColor = obj.FogColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FogColor"));
		}
		
		if(this._FogStart != obj.FogStart)
		{
			this._FogStart = obj.FogStart;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FogStart"));
		}
		
		if(this._FogEnd != obj.FogEnd)
		{
			this._FogEnd = obj.FogEnd;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FogEnd"));
		}
		
		if(this._FogDensity != obj.FogDensity)
		{
			this._FogDensity = obj.FogDensity;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FogDensity"));
		}
		
		if(this._MinPopUpDistance != obj.MinPopUpDistance)
		{
			this._MinPopUpDistance = obj.MinPopUpDistance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MinPopUpDistance"));
		}
		
		if(this._ShowSky != obj.ShowSky)
		{
			this._ShowSky = obj.ShowSky;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowSky"));
		}
		
		if(this._ShowBoundingBox != obj.ShowBoundingBox)
		{
			this._ShowBoundingBox = obj.ShowBoundingBox;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowBoundingBox"));
		}
		
		if(this._ShowPortalSystem != obj.ShowPortalSystem)
		{
			this._ShowPortalSystem = obj.ShowPortalSystem;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowPortalSystem"));
		}
		
		if(this._EnablePortalZone != obj.EnablePortalZone)
		{
			this._EnablePortalZone = obj.EnablePortalZone;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnablePortalZone"));
		}
		
		if(this._GenerateReport != obj.GenerateReport)
		{
			this._GenerateReport = obj.GenerateReport;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("GenerateReport"));
		}
		
		if(this._AutoPlayerRipple != obj.AutoPlayerRipple)
		{
			this._AutoPlayerRipple = obj.AutoPlayerRipple;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AutoPlayerRipple"));
		}
		
		if(this._ShowHeadOnDisplay != obj.ShowHeadOnDisplay)
		{
			this._ShowHeadOnDisplay = obj.ShowHeadOnDisplay;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowHeadOnDisplay"));
		}
		
		if(this._UseWireFrame != obj.UseWireFrame)
		{
			this._UseWireFrame = obj.UseWireFrame;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseWireFrame"));
		}
		
		if(this._PhysicsDebugDrawMode != obj.PhysicsDebugDrawMode)
		{
			this._PhysicsDebugDrawMode = obj.PhysicsDebugDrawMode;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PhysicsDebugDrawMode"));
		}
		
			}
	
	}
}
		