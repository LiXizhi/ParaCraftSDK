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
	public class GameObject : IBindableObject
	{
	   	public GameObject() {}
	public GameObject(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,string _obj_id,XmlElement _position,double _facing,double _scaling,double _gsid,XmlElement _rotation,bool _isalwaysshowheadontext,XmlElement _replaceabletextures_model,bool _isshownifown,double _physics_group,double _copies,XmlElement _positions,XmlElement _facings,XmlElement _scalings,string _assetfile_char,string _assetfile_model,bool _skiprender_char,bool _skiprender_mesh,double _scaling_char,double _scale_model,string _page_url,string _gameobj_type,double _pick_count,string _onpick_msg,bool _isdeleteafterpick,double _PickDist,double _respawn_interval) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._obj_id = _obj_id;
this._position = _position;
this._facing = _facing;
this._scaling = _scaling;
this._gsid = _gsid;
this._rotation = _rotation;
this._isalwaysshowheadontext = _isalwaysshowheadontext;
this._replaceabletextures_model = _replaceabletextures_model;
this._isshownifown = _isshownifown;
this._physics_group = _physics_group;
this._copies = _copies;
this._positions = _positions;
this._facings = _facings;
this._scalings = _scalings;
this._assetfile_char = _assetfile_char;
this._assetfile_model = _assetfile_model;
this._skiprender_char = _skiprender_char;
this._skiprender_mesh = _skiprender_mesh;
this._scaling_char = _scaling_char;
this._scale_model = _scale_model;
this._page_url = _page_url;
this._gameobj_type = _gameobj_type;
this._pick_count = _pick_count;
this._onpick_msg = _onpick_msg;
this._isdeleteafterpick = _isdeleteafterpick;
this._PickDist = _PickDist;
this._respawn_interval = _respawn_interval;
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
				[Description("display name of GameObject")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private string _obj_id;
				[Category("display")]
				[Description("GameObject id in the game")]
				
				
				
				public string obj_id
				{
					get { return _obj_id; }
					set
					{
						_obj_id = value;
						OnPropertyChanged(new PropertyChangedEventArgs("obj_id"));
					}
				}			private XmlElement _position;
				[Category("display")]
				[Description("position of the GameObject")]
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement position
				{
					get { return _position; }
					set
					{
						_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("position"));
					}
				}			private double _facing;
				[Category("display")]
				[Description("GameObject facing around the y axis")]
				
				
				
				public double facing
				{
					get { return _facing; }
					set
					{
						_facing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("facing"));
					}
				}			private double _scaling;
				[Category("display")]
				[Description("scaling of GameObject")]
				
				
				
				public double scaling
				{
					get { return _scaling; }
					set
					{
						_scaling = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scaling"));
					}
				}			private double _gsid;
				[Category("display")]
				[Description("global store id")]
				
				
				
				public double gsid
				{
					get { return _gsid; }
					set
					{
						_gsid = value;
						OnPropertyChanged(new PropertyChangedEventArgs("gsid"));
					}
				}			private XmlElement _rotation;
				[Category("display_extended")]
				[Description("3d rotation(rarely used)")]
				
				
				
				public XmlElement rotation
				{
					get { return _rotation; }
					set
					{
						_rotation = value;
						OnPropertyChanged(new PropertyChangedEventArgs("rotation"));
					}
				}			private bool _isalwaysshowheadontext;
				[Category("display_extended")]
				
				
				
				
				public bool isalwaysshowheadontext
				{
					get { return _isalwaysshowheadontext; }
					set
					{
						_isalwaysshowheadontext = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isalwaysshowheadontext"));
					}
				}			private XmlElement _replaceabletextures_model;
				[Category("display_extended")]
				
				
				
				
				public XmlElement replaceabletextures_model
				{
					get { return _replaceabletextures_model; }
					set
					{
						_replaceabletextures_model = value;
						OnPropertyChanged(new PropertyChangedEventArgs("replaceabletextures_model"));
					}
				}			private bool _isshownifown;
				[Category("display_extended")]
				
				
				
				
				public bool isshownifown
				{
					get { return _isshownifown; }
					set
					{
						_isshownifown = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isshownifown"));
					}
				}			private double _physics_group;
				[Category("display_extended")]
				[Description("0 no camera collision; 1 camera has collision; 2 camera has collision but character does not")]
				
				
				
				public double physics_group
				{
					get { return _physics_group; }
					set
					{
						_physics_group = value;
						OnPropertyChanged(new PropertyChangedEventArgs("physics_group"));
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
				}			private XmlElement _scalings;
				[Category("instances")]
				[Description("scalings of instances")]
				
				
				
				public XmlElement scalings
				{
					get { return _scalings; }
					set
					{
						_scalings = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scalings"));
					}
				}			private string _assetfile_char;
				[Category("display_ex")]
				[Description("character asset")]
				[FileSelector(InitialDirectory="character/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string assetfile_char
				{
					get { return _assetfile_char; }
					set
					{
						_assetfile_char = value;
						OnPropertyChanged(new PropertyChangedEventArgs("assetfile_char"));
					}
				}			private string _assetfile_model;
				[Category("display_ex")]
				[Description("model asset")]
				[FileSelector(InitialDirectory="model/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string assetfile_model
				{
					get { return _assetfile_model; }
					set
					{
						_assetfile_model = value;
						OnPropertyChanged(new PropertyChangedEventArgs("assetfile_model"));
					}
				}			private bool _skiprender_char;
				[Category("display_ex")]
				[Description("whether to skip character rendering")]
				
				
				
				public bool skiprender_char
				{
					get { return _skiprender_char; }
					set
					{
						_skiprender_char = value;
						OnPropertyChanged(new PropertyChangedEventArgs("skiprender_char"));
					}
				}			private bool _skiprender_mesh;
				[Category("display_ex")]
				[Description("whether to skip model rendering")]
				
				
				
				public bool skiprender_mesh
				{
					get { return _skiprender_mesh; }
					set
					{
						_skiprender_mesh = value;
						OnPropertyChanged(new PropertyChangedEventArgs("skiprender_mesh"));
					}
				}			private double _scaling_char;
				[Category("display_ex")]
				
				
				
				
				public double scaling_char
				{
					get { return _scaling_char; }
					set
					{
						_scaling_char = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scaling_char"));
					}
				}			private double _scale_model;
				[Category("display_ex")]
				
				
				
				
				public double scale_model
				{
					get { return _scale_model; }
					set
					{
						_scale_model = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scale_model"));
					}
				}			private string _page_url;
				[Category("interact")]
				
				
				
				
				public string page_url
				{
					get { return _page_url; }
					set
					{
						_page_url = value;
						OnPropertyChanged(new PropertyChangedEventArgs("page_url"));
					}
				}			private string _gameobj_type;
				[Category("interact")]
				
				
				
				
				public string gameobj_type
				{
					get { return _gameobj_type; }
					set
					{
						_gameobj_type = value;
						OnPropertyChanged(new PropertyChangedEventArgs("gameobj_type"));
					}
				}			private double _pick_count;
				[Category("interact")]
				
				
				
				
				public double pick_count
				{
					get { return _pick_count; }
					set
					{
						_pick_count = value;
						OnPropertyChanged(new PropertyChangedEventArgs("pick_count"));
					}
				}			private string _onpick_msg;
				[Category("interact")]
				
				
				
				
				public string onpick_msg
				{
					get { return _onpick_msg; }
					set
					{
						_onpick_msg = value;
						OnPropertyChanged(new PropertyChangedEventArgs("onpick_msg"));
					}
				}			private bool _isdeleteafterpick;
				[Category("interact")]
				
				
				
				
				public bool isdeleteafterpick
				{
					get { return _isdeleteafterpick; }
					set
					{
						_isdeleteafterpick = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isdeleteafterpick"));
					}
				}			private double _PickDist;
				[Category("interact")]
				
				
				
				
				public double PickDist
				{
					get { return _PickDist; }
					set
					{
						_PickDist = value;
						OnPropertyChanged(new PropertyChangedEventArgs("PickDist"));
					}
				}			private double _respawn_interval;
				[Category("interact")]
				[Description("milliseconds interval to respawn. 0 to disable respawning")]
				
				
				
				public double respawn_interval
				{
					get { return _respawn_interval; }
					set
					{
						_respawn_interval = value;
						OnPropertyChanged(new PropertyChangedEventArgs("respawn_interval"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				GameObject obj = _obj as GameObject;
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
		
		if(this._obj_id != obj.obj_id)
		{
			this._obj_id = obj.obj_id;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("obj_id"));
		}
		
		if(this._position != obj.position)
		{
			this._position = obj.position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("position"));
		}
		
		if(this._facing != obj.facing)
		{
			this._facing = obj.facing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("facing"));
		}
		
		if(this._scaling != obj.scaling)
		{
			this._scaling = obj.scaling;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scaling"));
		}
		
		if(this._gsid != obj.gsid)
		{
			this._gsid = obj.gsid;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("gsid"));
		}
		
		if(this._rotation != obj.rotation)
		{
			this._rotation = obj.rotation;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("rotation"));
		}
		
		if(this._isalwaysshowheadontext != obj.isalwaysshowheadontext)
		{
			this._isalwaysshowheadontext = obj.isalwaysshowheadontext;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isalwaysshowheadontext"));
		}
		
		if(this._replaceabletextures_model != obj.replaceabletextures_model)
		{
			this._replaceabletextures_model = obj.replaceabletextures_model;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("replaceabletextures_model"));
		}
		
		if(this._isshownifown != obj.isshownifown)
		{
			this._isshownifown = obj.isshownifown;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isshownifown"));
		}
		
		if(this._physics_group != obj.physics_group)
		{
			this._physics_group = obj.physics_group;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("physics_group"));
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
		
		if(this._scalings != obj.scalings)
		{
			this._scalings = obj.scalings;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scalings"));
		}
		
		if(this._assetfile_char != obj.assetfile_char)
		{
			this._assetfile_char = obj.assetfile_char;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("assetfile_char"));
		}
		
		if(this._assetfile_model != obj.assetfile_model)
		{
			this._assetfile_model = obj.assetfile_model;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("assetfile_model"));
		}
		
		if(this._skiprender_char != obj.skiprender_char)
		{
			this._skiprender_char = obj.skiprender_char;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("skiprender_char"));
		}
		
		if(this._skiprender_mesh != obj.skiprender_mesh)
		{
			this._skiprender_mesh = obj.skiprender_mesh;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("skiprender_mesh"));
		}
		
		if(this._scaling_char != obj.scaling_char)
		{
			this._scaling_char = obj.scaling_char;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scaling_char"));
		}
		
		if(this._scale_model != obj.scale_model)
		{
			this._scale_model = obj.scale_model;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scale_model"));
		}
		
		if(this._page_url != obj.page_url)
		{
			this._page_url = obj.page_url;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("page_url"));
		}
		
		if(this._gameobj_type != obj.gameobj_type)
		{
			this._gameobj_type = obj.gameobj_type;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("gameobj_type"));
		}
		
		if(this._pick_count != obj.pick_count)
		{
			this._pick_count = obj.pick_count;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("pick_count"));
		}
		
		if(this._onpick_msg != obj.onpick_msg)
		{
			this._onpick_msg = obj.onpick_msg;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("onpick_msg"));
		}
		
		if(this._isdeleteafterpick != obj.isdeleteafterpick)
		{
			this._isdeleteafterpick = obj.isdeleteafterpick;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isdeleteafterpick"));
		}
		
		if(this._PickDist != obj.PickDist)
		{
			this._PickDist = obj.PickDist;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PickDist"));
		}
		
		if(this._respawn_interval != obj.respawn_interval)
		{
			this._respawn_interval = obj.respawn_interval;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("respawn_interval"));
		}
		
			}
	
	}
}
		