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
	public class Ocean : IBindableObject
	{
	   	public Ocean() {}
	public Ocean(string _uid,string _worldfilter,string _codefile,string _template_file,bool _DrawOcean,double _WaterLevel,XmlElement _OceanColor,double _WindSpeed,double _WindDirection,double _RenderTechnique,bool _EnableTerrainReflection,bool _EnableMeshReflection,bool _EnablePlayerReflection,bool _EnableCharacterReflection) {
	
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
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Ocean obj = _obj as Ocean;
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
		
			}
	
	}
}
		