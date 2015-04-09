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

namespace PETools.EntityTemplates.Aries
{
	[NPLCommand("goto", func_name="goto")]
	public class Arena : IBindableObject
	{
	   	public Arena() {}
	public Arena(string _uid,string _worldfilter,string _codefile,string _template_file,string _id,XmlElement _position,double _respawn_interval,double _facing,string _ai_module,string _mob1,string _mob2,string _mob3,string _mob4) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._id = _id;
this._position = _position;
this._respawn_interval = _respawn_interval;
this._facing = _facing;
this._ai_module = _ai_module;
this._mob1 = _mob1;
this._mob2 = _mob2;
this._mob3 = _mob3;
this._mob4 = _mob4;
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
				}			private string _id;
				[Category("display")]
				[Description("arena id, must be a unique string, usually it is number string.")]
				
				
				
				public string id
				{
					get { return _id; }
					set
					{
						_id = value;
						OnPropertyChanged(new PropertyChangedEventArgs("id"));
					}
				}			private XmlElement _position;
				[Category("display")]
				[Description("Center of the Arena")]
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement position
				{
					get { return _position; }
					set
					{
						_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("position"));
					}
				}			private double _respawn_interval;
				[Category("display")]
				[Description("mob appear interval")]
				
				
				
				public double respawn_interval
				{
					get { return _respawn_interval; }
					set
					{
						_respawn_interval = value;
						OnPropertyChanged(new PropertyChangedEventArgs("respawn_interval"));
					}
				}			private double _facing;
				[Category("display")]
				[Description("arena facing around the y axis")]
				
				
				
				public double facing
				{
					get { return _facing; }
					set
					{
						_facing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("facing"));
					}
				}			private string _ai_module;
				[Category("display")]
				[Description("AI module file path")]
				
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string ai_module
				{
					get { return _ai_module; }
					set
					{
						_ai_module = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ai_module"));
					}
				}			private string _mob1;
				[Category("mob")]
				[Description("mob_template file path used at pos 1. ")]
				[FileSelector(InitialDirectory="config/Aries/Mob/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string mob1
				{
					get { return _mob1; }
					set
					{
						_mob1 = value;
						OnPropertyChanged(new PropertyChangedEventArgs("mob1"));
					}
				}			private string _mob2;
				[Category("mob")]
				[Description("mob_template file path used at pos 2. If empty, no mob is at this location")]
				[FileSelector(InitialDirectory="config/Aries/Mob/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string mob2
				{
					get { return _mob2; }
					set
					{
						_mob2 = value;
						OnPropertyChanged(new PropertyChangedEventArgs("mob2"));
					}
				}			private string _mob3;
				[Category("mob")]
				[Description("mob_template file path used at pos 3. If empty, no mob is at this location")]
				[FileSelector(InitialDirectory="config/Aries/Mob/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string mob3
				{
					get { return _mob3; }
					set
					{
						_mob3 = value;
						OnPropertyChanged(new PropertyChangedEventArgs("mob3"));
					}
				}			private string _mob4;
				[Category("mob")]
				[Description("mob_template file path used at pos 4. If empty, no mob is at this location")]
				[FileSelector(InitialDirectory="config/Aries/Mob/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string mob4
				{
					get { return _mob4; }
					set
					{
						_mob4 = value;
						OnPropertyChanged(new PropertyChangedEventArgs("mob4"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Arena obj = _obj as Arena;
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
		
		if(this._id != obj.id)
		{
			this._id = obj.id;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("id"));
		}
		
		if(this._position != obj.position)
		{
			this._position = obj.position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("position"));
		}
		
		if(this._respawn_interval != obj.respawn_interval)
		{
			this._respawn_interval = obj.respawn_interval;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("respawn_interval"));
		}
		
		if(this._facing != obj.facing)
		{
			this._facing = obj.facing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("facing"));
		}
		
		if(this._ai_module != obj.ai_module)
		{
			this._ai_module = obj.ai_module;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ai_module"));
		}
		
		if(this._mob1 != obj.mob1)
		{
			this._mob1 = obj.mob1;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("mob1"));
		}
		
		if(this._mob2 != obj.mob2)
		{
			this._mob2 = obj.mob2;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("mob2"));
		}
		
		if(this._mob3 != obj.mob3)
		{
			this._mob3 = obj.mob3;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("mob3"));
		}
		
		if(this._mob4 != obj.mob4)
		{
			this._mob4 = obj.mob4;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("mob4"));
		}
		
			}
	
	}
}
		