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
namespace PETools.EntityTemplates.Buildin
{
	public class Scene : IBindableObject
	{
	   	public Scene() {}
	public Scene(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,double _facing,double _width,double _height,double _depth,double _radius,XmlElement _position,double _render_tech,double _progress,string _homezone,bool _showboundingbox,double _PhysicsGroup,double _SelectGroupIndex,string _On_AssetLoaded,double _RenderImportance,double _AnimID,double _AnimFrame,bool _UseGlobalTime,bool _IsModified,bool _FullScreenGlow,double _GlowIntensity,double _GlowFactor,XmlElement _Glowness,bool _EnableSunLight,bool _EnableLight,bool _ShowLights,double _MaxLightsNum,bool _SetShadow,double _MaxNumShadowCaster,double _MaxNumShadowReceiver,double _MaxCharTriangles,XmlElement _BackgroundColor,bool _EnableFog,XmlElement _FogColor,double _FogStart,double _FogEnd,double _FogDensity,double _MinPopUpDistance,double _OnClickDistance,bool _ShowSky,bool _PasueScene,bool _EnableScene,bool _ShowBoundingBox,bool _ShowPortalSystem,bool _EnablePortalZone,bool _GenerateReport,bool _AutoPlayerRipple,bool _ShowHeadOnDisplay,bool _UseWireFrame,bool _ForceExportPhysics,double _MaxHeadOnDisplayDistance,bool _UseInstancing,bool _persistent,double _PhysicsDebugDrawMode,bool _BlockInput) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._facing = _facing;
this._width = _width;
this._height = _height;
this._depth = _depth;
this._radius = _radius;
this._position = _position;
this._render_tech = _render_tech;
this._progress = _progress;
this._homezone = _homezone;
this._showboundingbox = _showboundingbox;
this._PhysicsGroup = _PhysicsGroup;
this._SelectGroupIndex = _SelectGroupIndex;
this._On_AssetLoaded = _On_AssetLoaded;
this._RenderImportance = _RenderImportance;
this._AnimID = _AnimID;
this._AnimFrame = _AnimFrame;
this._UseGlobalTime = _UseGlobalTime;
this._IsModified = _IsModified;
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
this._OnClickDistance = _OnClickDistance;
this._ShowSky = _ShowSky;
this._PasueScene = _PasueScene;
this._EnableScene = _EnableScene;
this._ShowBoundingBox = _ShowBoundingBox;
this._ShowPortalSystem = _ShowPortalSystem;
this._EnablePortalZone = _EnablePortalZone;
this._GenerateReport = _GenerateReport;
this._AutoPlayerRipple = _AutoPlayerRipple;
this._ShowHeadOnDisplay = _ShowHeadOnDisplay;
this._UseWireFrame = _UseWireFrame;
this._ForceExportPhysics = _ForceExportPhysics;
this._MaxHeadOnDisplayDistance = _MaxHeadOnDisplayDistance;
this._UseInstancing = _UseInstancing;
this._persistent = _persistent;
this._PhysicsDebugDrawMode = _PhysicsDebugDrawMode;
this._BlockInput = _BlockInput;
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
				}			private string _name;
				
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private double _facing;
				
				
				
				
				public double facing
				{
					get { return _facing; }
					set
					{
						_facing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("facing"));
					}
				}			private double _width;
				
				
				
				
				public double width
				{
					get { return _width; }
					set
					{
						_width = value;
						OnPropertyChanged(new PropertyChangedEventArgs("width"));
					}
				}			private double _height;
				
				
				
				
				public double height
				{
					get { return _height; }
					set
					{
						_height = value;
						OnPropertyChanged(new PropertyChangedEventArgs("height"));
					}
				}			private double _depth;
				
				
				
				
				public double depth
				{
					get { return _depth; }
					set
					{
						_depth = value;
						OnPropertyChanged(new PropertyChangedEventArgs("depth"));
					}
				}			private double _radius;
				
				
				
				
				public double radius
				{
					get { return _radius; }
					set
					{
						_radius = value;
						OnPropertyChanged(new PropertyChangedEventArgs("radius"));
					}
				}			private XmlElement _position;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement position
				{
					get { return _position; }
					set
					{
						_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("position"));
					}
				}			private double _render_tech;
				
				
				
				
				public double render_tech
				{
					get { return _render_tech; }
					set
					{
						_render_tech = value;
						OnPropertyChanged(new PropertyChangedEventArgs("render_tech"));
					}
				}			private double _progress;
				
				
				
				
				public double progress
				{
					get { return _progress; }
					set
					{
						_progress = value;
						OnPropertyChanged(new PropertyChangedEventArgs("progress"));
					}
				}			private string _homezone;
				
				
				
				
				public string homezone
				{
					get { return _homezone; }
					set
					{
						_homezone = value;
						OnPropertyChanged(new PropertyChangedEventArgs("homezone"));
					}
				}			private bool _showboundingbox;
				
				
				
				
				public bool showboundingbox
				{
					get { return _showboundingbox; }
					set
					{
						_showboundingbox = value;
						OnPropertyChanged(new PropertyChangedEventArgs("showboundingbox"));
					}
				}			private double _PhysicsGroup;
				
				
				
				
				public double PhysicsGroup
				{
					get { return _PhysicsGroup; }
					set
					{
						_PhysicsGroup = value;
						OnPropertyChanged(new PropertyChangedEventArgs("PhysicsGroup"));
					}
				}			private double _SelectGroupIndex;
				
				
				
				
				public double SelectGroupIndex
				{
					get { return _SelectGroupIndex; }
					set
					{
						_SelectGroupIndex = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SelectGroupIndex"));
					}
				}			private string _On_AssetLoaded;
				
				
				
				
				public string On_AssetLoaded
				{
					get { return _On_AssetLoaded; }
					set
					{
						_On_AssetLoaded = value;
						OnPropertyChanged(new PropertyChangedEventArgs("On_AssetLoaded"));
					}
				}			private double _RenderImportance;
				
				
				
				
				public double RenderImportance
				{
					get { return _RenderImportance; }
					set
					{
						_RenderImportance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("RenderImportance"));
					}
				}			private double _AnimID;
				
				
				
				
				public double AnimID
				{
					get { return _AnimID; }
					set
					{
						_AnimID = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AnimID"));
					}
				}			private double _AnimFrame;
				
				
				
				
				public double AnimFrame
				{
					get { return _AnimFrame; }
					set
					{
						_AnimFrame = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AnimFrame"));
					}
				}			private bool _UseGlobalTime;
				
				
				
				
				public bool UseGlobalTime
				{
					get { return _UseGlobalTime; }
					set
					{
						_UseGlobalTime = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseGlobalTime"));
					}
				}			private bool _IsModified;
				
				
				
				
				public bool IsModified
				{
					get { return _IsModified; }
					set
					{
						_IsModified = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsModified"));
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
				}			private double _OnClickDistance;
				
				
				
				
				public double OnClickDistance
				{
					get { return _OnClickDistance; }
					set
					{
						_OnClickDistance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("OnClickDistance"));
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
				}			private bool _PasueScene;
				
				
				
				
				public bool PasueScene
				{
					get { return _PasueScene; }
					set
					{
						_PasueScene = value;
						OnPropertyChanged(new PropertyChangedEventArgs("PasueScene"));
					}
				}			private bool _EnableScene;
				
				
				
				
				public bool EnableScene
				{
					get { return _EnableScene; }
					set
					{
						_EnableScene = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableScene"));
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
				}			private bool _ForceExportPhysics;
				
				
				
				
				public bool ForceExportPhysics
				{
					get { return _ForceExportPhysics; }
					set
					{
						_ForceExportPhysics = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ForceExportPhysics"));
					}
				}			private double _MaxHeadOnDisplayDistance;
				
				
				
				
				public double MaxHeadOnDisplayDistance
				{
					get { return _MaxHeadOnDisplayDistance; }
					set
					{
						_MaxHeadOnDisplayDistance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MaxHeadOnDisplayDistance"));
					}
				}			private bool _UseInstancing;
				
				
				
				
				public bool UseInstancing
				{
					get { return _UseInstancing; }
					set
					{
						_UseInstancing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseInstancing"));
					}
				}			private bool _persistent;
				
				
				
				
				public bool persistent
				{
					get { return _persistent; }
					set
					{
						_persistent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("persistent"));
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
				}			private bool _BlockInput;
				
				
				
				
				public bool BlockInput
				{
					get { return _BlockInput; }
					set
					{
						_BlockInput = value;
						OnPropertyChanged(new PropertyChangedEventArgs("BlockInput"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Scene obj = _obj as Scene;
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
		
		if(this._name != obj.name)
		{
			this._name = obj.name;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("name"));
		}
		
		if(this._facing != obj.facing)
		{
			this._facing = obj.facing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("facing"));
		}
		
		if(this._width != obj.width)
		{
			this._width = obj.width;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("width"));
		}
		
		if(this._height != obj.height)
		{
			this._height = obj.height;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("height"));
		}
		
		if(this._depth != obj.depth)
		{
			this._depth = obj.depth;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("depth"));
		}
		
		if(this._radius != obj.radius)
		{
			this._radius = obj.radius;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("radius"));
		}
		
		if(this._position != obj.position)
		{
			this._position = obj.position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("position"));
		}
		
		if(this._render_tech != obj.render_tech)
		{
			this._render_tech = obj.render_tech;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("render_tech"));
		}
		
		if(this._progress != obj.progress)
		{
			this._progress = obj.progress;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("progress"));
		}
		
		if(this._homezone != obj.homezone)
		{
			this._homezone = obj.homezone;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("homezone"));
		}
		
		if(this._showboundingbox != obj.showboundingbox)
		{
			this._showboundingbox = obj.showboundingbox;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("showboundingbox"));
		}
		
		if(this._PhysicsGroup != obj.PhysicsGroup)
		{
			this._PhysicsGroup = obj.PhysicsGroup;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PhysicsGroup"));
		}
		
		if(this._SelectGroupIndex != obj.SelectGroupIndex)
		{
			this._SelectGroupIndex = obj.SelectGroupIndex;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SelectGroupIndex"));
		}
		
		if(this._On_AssetLoaded != obj.On_AssetLoaded)
		{
			this._On_AssetLoaded = obj.On_AssetLoaded;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("On_AssetLoaded"));
		}
		
		if(this._RenderImportance != obj.RenderImportance)
		{
			this._RenderImportance = obj.RenderImportance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("RenderImportance"));
		}
		
		if(this._AnimID != obj.AnimID)
		{
			this._AnimID = obj.AnimID;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AnimID"));
		}
		
		if(this._AnimFrame != obj.AnimFrame)
		{
			this._AnimFrame = obj.AnimFrame;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AnimFrame"));
		}
		
		if(this._UseGlobalTime != obj.UseGlobalTime)
		{
			this._UseGlobalTime = obj.UseGlobalTime;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseGlobalTime"));
		}
		
		if(this._IsModified != obj.IsModified)
		{
			this._IsModified = obj.IsModified;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsModified"));
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
		
		if(this._OnClickDistance != obj.OnClickDistance)
		{
			this._OnClickDistance = obj.OnClickDistance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("OnClickDistance"));
		}
		
		if(this._ShowSky != obj.ShowSky)
		{
			this._ShowSky = obj.ShowSky;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowSky"));
		}
		
		if(this._PasueScene != obj.PasueScene)
		{
			this._PasueScene = obj.PasueScene;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PasueScene"));
		}
		
		if(this._EnableScene != obj.EnableScene)
		{
			this._EnableScene = obj.EnableScene;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableScene"));
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
		
		if(this._ForceExportPhysics != obj.ForceExportPhysics)
		{
			this._ForceExportPhysics = obj.ForceExportPhysics;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ForceExportPhysics"));
		}
		
		if(this._MaxHeadOnDisplayDistance != obj.MaxHeadOnDisplayDistance)
		{
			this._MaxHeadOnDisplayDistance = obj.MaxHeadOnDisplayDistance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MaxHeadOnDisplayDistance"));
		}
		
		if(this._UseInstancing != obj.UseInstancing)
		{
			this._UseInstancing = obj.UseInstancing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseInstancing"));
		}
		
		if(this._persistent != obj.persistent)
		{
			this._persistent = obj.persistent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("persistent"));
		}
		
		if(this._PhysicsDebugDrawMode != obj.PhysicsDebugDrawMode)
		{
			this._PhysicsDebugDrawMode = obj.PhysicsDebugDrawMode;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PhysicsDebugDrawMode"));
		}
		
		if(this._BlockInput != obj.BlockInput)
		{
			this._BlockInput = obj.BlockInput;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("BlockInput"));
		}
		
			}
	
	}
}
		