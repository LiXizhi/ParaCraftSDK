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

namespace PETools.EntityTemplates.Buildin
{
	
	public class Terrain : IBindableObject
	{
	   	public Terrain() {}
	public Terrain(string _uid,string _worldfilter,string _codefile,string _template_file,double _TextureMaskWidth,bool _RenderTerrain) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._TextureMaskWidth = _TextureMaskWidth;
this._RenderTerrain = _RenderTerrain;
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
				}			private double _TextureMaskWidth;
				
				[Description("max terrain mask texture size. such as 64,128,or 256. ")]
				
				
				
				public double TextureMaskWidth
				{
					get { return _TextureMaskWidth; }
					set
					{
						_TextureMaskWidth = value;
						OnPropertyChanged(new PropertyChangedEventArgs("TextureMaskWidth"));
					}
				}			private bool _RenderTerrain;
				
				
				
				
				
				public bool RenderTerrain
				{
					get { return _RenderTerrain; }
					set
					{
						_RenderTerrain = value;
						OnPropertyChanged(new PropertyChangedEventArgs("RenderTerrain"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Terrain obj = _obj as Terrain;
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
		
		if(this._TextureMaskWidth != obj.TextureMaskWidth)
		{
			this._TextureMaskWidth = obj.TextureMaskWidth;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("TextureMaskWidth"));
		}
		
		if(this._RenderTerrain != obj.RenderTerrain)
		{
			this._RenderTerrain = obj.RenderTerrain;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("RenderTerrain"));
		}
		
			}
	
	}
}
		