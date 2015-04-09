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
	public class Sky : IBindableObject
	{
	   	public Sky() {}
	public Sky(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,double _facing,double _width,double _height,double _depth,double _radius,XmlElement _position,double _render_tech,double _progress,string _homezone,bool _showboundingbox,double _PhysicsGroup,double _SelectGroupIndex,string _On_AssetLoaded,double _RenderImportance,double _AnimID,double _AnimFrame,bool _UseGlobalTime,string _SkyMeshFile,XmlElement _SkyColor,double _SkyFogAngleFrom,double _SkyFogAngleTo,bool _SimulatedSky,bool _IsAutoDayTime,string _SunGlowTexture,string _CloudTexture,XmlElement _SunColor,XmlElement _LightSkyColor,XmlElement _DarkSkyColor,XmlElement _CloudColor) {
	
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
this._SkyMeshFile = _SkyMeshFile;
this._SkyColor = _SkyColor;
this._SkyFogAngleFrom = _SkyFogAngleFrom;
this._SkyFogAngleTo = _SkyFogAngleTo;
this._SimulatedSky = _SimulatedSky;
this._IsAutoDayTime = _IsAutoDayTime;
this._SunGlowTexture = _SunGlowTexture;
this._CloudTexture = _CloudTexture;
this._SunColor = _SunColor;
this._LightSkyColor = _LightSkyColor;
this._DarkSkyColor = _DarkSkyColor;
this._CloudColor = _CloudColor;
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
				}			private string _SkyMeshFile;
				
				
				
				
				public string SkyMeshFile
				{
					get { return _SkyMeshFile; }
					set
					{
						_SkyMeshFile = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SkyMeshFile"));
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
				}			private string _SunGlowTexture;
				
				
				
				
				public string SunGlowTexture
				{
					get { return _SunGlowTexture; }
					set
					{
						_SunGlowTexture = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SunGlowTexture"));
					}
				}			private string _CloudTexture;
				
				
				
				
				public string CloudTexture
				{
					get { return _CloudTexture; }
					set
					{
						_CloudTexture = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CloudTexture"));
					}
				}			private XmlElement _SunColor;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement SunColor
				{
					get { return _SunColor; }
					set
					{
						_SunColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SunColor"));
					}
				}			private XmlElement _LightSkyColor;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement LightSkyColor
				{
					get { return _LightSkyColor; }
					set
					{
						_LightSkyColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("LightSkyColor"));
					}
				}			private XmlElement _DarkSkyColor;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement DarkSkyColor
				{
					get { return _DarkSkyColor; }
					set
					{
						_DarkSkyColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("DarkSkyColor"));
					}
				}			private XmlElement _CloudColor;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement CloudColor
				{
					get { return _CloudColor; }
					set
					{
						_CloudColor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CloudColor"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Sky obj = _obj as Sky;
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
		
		if(this._SkyMeshFile != obj.SkyMeshFile)
		{
			this._SkyMeshFile = obj.SkyMeshFile;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SkyMeshFile"));
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
		
		if(this._SunGlowTexture != obj.SunGlowTexture)
		{
			this._SunGlowTexture = obj.SunGlowTexture;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SunGlowTexture"));
		}
		
		if(this._CloudTexture != obj.CloudTexture)
		{
			this._CloudTexture = obj.CloudTexture;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CloudTexture"));
		}
		
		if(this._SunColor != obj.SunColor)
		{
			this._SunColor = obj.SunColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SunColor"));
		}
		
		if(this._LightSkyColor != obj.LightSkyColor)
		{
			this._LightSkyColor = obj.LightSkyColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("LightSkyColor"));
		}
		
		if(this._DarkSkyColor != obj.DarkSkyColor)
		{
			this._DarkSkyColor = obj.DarkSkyColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("DarkSkyColor"));
		}
		
		if(this._CloudColor != obj.CloudColor)
		{
			this._CloudColor = obj.CloudColor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CloudColor"));
		}
		
			}
	
	}
}
		