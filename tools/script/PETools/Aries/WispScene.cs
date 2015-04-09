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
	public class WispScene : IBindableObject
	{
	   	public WispScene() {}
	public WispScene(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,XmlElement _position,double _wisp_begin,double _wisp_end,double _update_count,double _update_interval,double _clear_afterupdate,double _copies,XmlElement _positions,XmlElement _facings) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._position = _position;
this._wisp_begin = _wisp_begin;
this._wisp_end = _wisp_end;
this._update_count = _update_count;
this._update_interval = _update_interval;
this._clear_afterupdate = _clear_afterupdate;
this._copies = _copies;
this._positions = _positions;
this._facings = _facings;
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
				[Category("display")]
				[Description("wisp scene name")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private XmlElement _position;
				[Category("display")]
				[Description("a dummy position only for editing")]
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement position
				{
					get { return _position; }
					set
					{
						_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("position"));
					}
				}			private double _wisp_begin;
				[Category("display")]
				[Description("wisp id from")]
				
				
				
				public double wisp_begin
				{
					get { return _wisp_begin; }
					set
					{
						_wisp_begin = value;
						OnPropertyChanged(new PropertyChangedEventArgs("wisp_begin"));
					}
				}			private double _wisp_end;
				[Category("display")]
				[Description("wisp id end")]
				
				
				
				public double wisp_end
				{
					get { return _wisp_end; }
					set
					{
						_wisp_end = value;
						OnPropertyChanged(new PropertyChangedEventArgs("wisp_end"));
					}
				}			private double _update_count;
				[Category("display")]
				[Description("wisp id end")]
				
				
				
				public double update_count
				{
					get { return _update_count; }
					set
					{
						_update_count = value;
						OnPropertyChanged(new PropertyChangedEventArgs("update_count"));
					}
				}			private double _update_interval;
				[Category("display")]
				[Description("wisp id end")]
				
				
				
				public double update_interval
				{
					get { return _update_interval; }
					set
					{
						_update_interval = value;
						OnPropertyChanged(new PropertyChangedEventArgs("update_interval"));
					}
				}			private double _clear_afterupdate;
				[Category("display")]
				[Description("wisp id end")]
				
				
				
				public double clear_afterupdate
				{
					get { return _clear_afterupdate; }
					set
					{
						_clear_afterupdate = value;
						OnPropertyChanged(new PropertyChangedEventArgs("clear_afterupdate"));
					}
				}			private double _copies;
				[Category("instances")]
				[Description("number of instance copies")]
				
				
				
				public double copies
				{
					get { return _copies; }
					set
					{
						_copies = value;
						OnPropertyChanged(new PropertyChangedEventArgs("copies"));
					}
				}			private XmlElement _positions;
				[Category("instances")]
				[Description("instance positions, such as {{0,1,2},{0,1,2},}")]
				
				
				
				public XmlElement positions
				{
					get { return _positions; }
					set
					{
						_positions = value;
						OnPropertyChanged(new PropertyChangedEventArgs("positions"));
					}
				}			private XmlElement _facings;
				[Category("instances")]
				[Description("facings of instances")]
				
				
				
				public XmlElement facings
				{
					get { return _facings; }
					set
					{
						_facings = value;
						OnPropertyChanged(new PropertyChangedEventArgs("facings"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				WispScene obj = _obj as WispScene;
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
		
		if(this._position != obj.position)
		{
			this._position = obj.position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("position"));
		}
		
		if(this._wisp_begin != obj.wisp_begin)
		{
			this._wisp_begin = obj.wisp_begin;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("wisp_begin"));
		}
		
		if(this._wisp_end != obj.wisp_end)
		{
			this._wisp_end = obj.wisp_end;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("wisp_end"));
		}
		
		if(this._update_count != obj.update_count)
		{
			this._update_count = obj.update_count;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("update_count"));
		}
		
		if(this._update_interval != obj.update_interval)
		{
			this._update_interval = obj.update_interval;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("update_interval"));
		}
		
		if(this._clear_afterupdate != obj.clear_afterupdate)
		{
			this._clear_afterupdate = obj.clear_afterupdate;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("clear_afterupdate"));
		}
		
		if(this._copies != obj.copies)
		{
			this._copies = obj.copies;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("copies"));
		}
		
		if(this._positions != obj.positions)
		{
			this._positions = obj.positions;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("positions"));
		}
		
		if(this._facings != obj.facings)
		{
			this._facings = obj.facings;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("facings"));
		}
		
			}
	
	}
}
		