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
	public class NPC : IBindableObject
	{
	   	public NPC() {}
	public NPC(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,string _npc_id,XmlElement _position,double _facing,double _scaling,XmlElement _rotation,bool _directscaling,bool _isalwaysshowheadontext,string _headonmark,double _physics_group,double _copies,XmlElement _positions,XmlElement _facings,XmlElement _scalings,string _assetfile_char,string _assetfile_model,bool _skiprender_char,bool _skiprender_mesh,double _scale_char,double _scaling_model,bool _isBigStaticMesh,bool _isdummy,double _talkdist,bool _autofacing,double _PerceptiveRadius,double _SentientRadius,bool _dialogstyle_antiindulgence,string _main_script,string _main_function,string _dialog_page,string _predialog_function,string _selected_page,string _AI_script,double _FrameMoveInterval,string _On_FrameMove,string _friend_npcs,bool _isglobaltimer,string _on_timer,double _timer_period) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._npc_id = _npc_id;
this._position = _position;
this._facing = _facing;
this._scaling = _scaling;
this._rotation = _rotation;
this._directscaling = _directscaling;
this._isalwaysshowheadontext = _isalwaysshowheadontext;
this._headonmark = _headonmark;
this._physics_group = _physics_group;
this._copies = _copies;
this._positions = _positions;
this._facings = _facings;
this._scalings = _scalings;
this._assetfile_char = _assetfile_char;
this._assetfile_model = _assetfile_model;
this._skiprender_char = _skiprender_char;
this._skiprender_mesh = _skiprender_mesh;
this._scale_char = _scale_char;
this._scaling_model = _scaling_model;
this._isBigStaticMesh = _isBigStaticMesh;
this._isdummy = _isdummy;
this._talkdist = _talkdist;
this._autofacing = _autofacing;
this._PerceptiveRadius = _PerceptiveRadius;
this._SentientRadius = _SentientRadius;
this._dialogstyle_antiindulgence = _dialogstyle_antiindulgence;
this._main_script = _main_script;
this._main_function = _main_function;
this._dialog_page = _dialog_page;
this._predialog_function = _predialog_function;
this._selected_page = _selected_page;
this._AI_script = _AI_script;
this._FrameMoveInterval = _FrameMoveInterval;
this._On_FrameMove = _On_FrameMove;
this._friend_npcs = _friend_npcs;
this._isglobaltimer = _isglobaltimer;
this._on_timer = _on_timer;
this._timer_period = _timer_period;
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
				[Description("display name of NPC")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private string _npc_id;
				[Category("display")]
				[Description("NPC id in the game")]
				
				
				
				public string npc_id
				{
					get { return _npc_id; }
					set
					{
						_npc_id = value;
						OnPropertyChanged(new PropertyChangedEventArgs("npc_id"));
					}
				}			private XmlElement _position;
				[Category("display")]
				[Description("position of the NPC")]
				
				
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
				[Description("NPC facing around the y axis")]
				
				
				
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
				[Description("scaling of NPC")]
				
				
				
				public double scaling
				{
					get { return _scaling; }
					set
					{
						_scaling = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scaling"));
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
				}			private bool _directscaling;
				[Category("display_extended")]
				[Description("if true, we will apply this.scaling to npcChar")]
				
				
				
				public bool directscaling
				{
					get { return _directscaling; }
					set
					{
						_directscaling = value;
						OnPropertyChanged(new PropertyChangedEventArgs("directscaling"));
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
				}			private string _headonmark;
				[Category("display_extended")]
				
				
				
				
				public string headonmark
				{
					get { return _headonmark; }
					set
					{
						_headonmark = value;
						OnPropertyChanged(new PropertyChangedEventArgs("headonmark"));
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
				}			private double _scale_char;
				[Category("display_ex")]
				
				
				
				
				public double scale_char
				{
					get { return _scale_char; }
					set
					{
						_scale_char = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scale_char"));
					}
				}			private double _scaling_model;
				[Category("display_ex")]
				
				
				
				
				public double scaling_model
				{
					get { return _scaling_model; }
					set
					{
						_scaling_model = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scaling_model"));
					}
				}			private bool _isBigStaticMesh;
				[Category("display_ex")]
				
				
				
				
				public bool isBigStaticMesh
				{
					get { return _isBigStaticMesh; }
					set
					{
						_isBigStaticMesh = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isBigStaticMesh"));
					}
				}			private bool _isdummy;
				[Category("interact")]
				
				
				
				
				public bool isdummy
				{
					get { return _isdummy; }
					set
					{
						_isdummy = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isdummy"));
					}
				}			private double _talkdist;
				[Category("interact")]
				[Description("on click talk distance")]
				
				
				
				public double talkdist
				{
					get { return _talkdist; }
					set
					{
						_talkdist = value;
						OnPropertyChanged(new PropertyChangedEventArgs("talkdist"));
					}
				}			private bool _autofacing;
				[Category("interact")]
				
				
				
				
				public bool autofacing
				{
					get { return _autofacing; }
					set
					{
						_autofacing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("autofacing"));
					}
				}			private double _PerceptiveRadius;
				[Category("interact")]
				
				
				
				
				public double PerceptiveRadius
				{
					get { return _PerceptiveRadius; }
					set
					{
						_PerceptiveRadius = value;
						OnPropertyChanged(new PropertyChangedEventArgs("PerceptiveRadius"));
					}
				}			private double _SentientRadius;
				[Category("interact")]
				
				
				
				
				public double SentientRadius
				{
					get { return _SentientRadius; }
					set
					{
						_SentientRadius = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SentientRadius"));
					}
				}			private bool _dialogstyle_antiindulgence;
				[Category("interact")]
				
				
				
				
				public bool dialogstyle_antiindulgence
				{
					get { return _dialogstyle_antiindulgence; }
					set
					{
						_dialogstyle_antiindulgence = value;
						OnPropertyChanged(new PropertyChangedEventArgs("dialogstyle_antiindulgence"));
					}
				}			private string _main_script;
				[Category("interact")]
				
				
				
				
				public string main_script
				{
					get { return _main_script; }
					set
					{
						_main_script = value;
						OnPropertyChanged(new PropertyChangedEventArgs("main_script"));
					}
				}			private string _main_function;
				[Category("interact")]
				
				
				
				
				public string main_function
				{
					get { return _main_function; }
					set
					{
						_main_function = value;
						OnPropertyChanged(new PropertyChangedEventArgs("main_function"));
					}
				}			private string _dialog_page;
				[Category("interact")]
				
				
				
				
				public string dialog_page
				{
					get { return _dialog_page; }
					set
					{
						_dialog_page = value;
						OnPropertyChanged(new PropertyChangedEventArgs("dialog_page"));
					}
				}			private string _predialog_function;
				[Category("interact")]
				
				
				
				
				public string predialog_function
				{
					get { return _predialog_function; }
					set
					{
						_predialog_function = value;
						OnPropertyChanged(new PropertyChangedEventArgs("predialog_function"));
					}
				}			private string _selected_page;
				[Category("interact")]
				
				
				
				
				public string selected_page
				{
					get { return _selected_page; }
					set
					{
						_selected_page = value;
						OnPropertyChanged(new PropertyChangedEventArgs("selected_page"));
					}
				}			private string _AI_script;
				[Category("interact")]
				
				
				
				
				public string AI_script
				{
					get { return _AI_script; }
					set
					{
						_AI_script = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AI_script"));
					}
				}			private double _FrameMoveInterval;
				[Category("interact")]
				
				
				
				
				public double FrameMoveInterval
				{
					get { return _FrameMoveInterval; }
					set
					{
						_FrameMoveInterval = value;
						OnPropertyChanged(new PropertyChangedEventArgs("FrameMoveInterval"));
					}
				}			private string _On_FrameMove;
				[Category("interact")]
				
				
				
				
				public string On_FrameMove
				{
					get { return _On_FrameMove; }
					set
					{
						_On_FrameMove = value;
						OnPropertyChanged(new PropertyChangedEventArgs("On_FrameMove"));
					}
				}			private string _friend_npcs;
				[Category("interact")]
				
				
				
				
				public string friend_npcs
				{
					get { return _friend_npcs; }
					set
					{
						_friend_npcs = value;
						OnPropertyChanged(new PropertyChangedEventArgs("friend_npcs"));
					}
				}			private bool _isglobaltimer;
				[Category("timer")]
				
				
				
				
				public bool isglobaltimer
				{
					get { return _isglobaltimer; }
					set
					{
						_isglobaltimer = value;
						OnPropertyChanged(new PropertyChangedEventArgs("isglobaltimer"));
					}
				}			private string _on_timer;
				[Category("timer")]
				
				
				
				
				public string on_timer
				{
					get { return _on_timer; }
					set
					{
						_on_timer = value;
						OnPropertyChanged(new PropertyChangedEventArgs("on_timer"));
					}
				}			private double _timer_period;
				[Category("timer")]
				
				
				
				
				public double timer_period
				{
					get { return _timer_period; }
					set
					{
						_timer_period = value;
						OnPropertyChanged(new PropertyChangedEventArgs("timer_period"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				NPC obj = _obj as NPC;
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
		
		if(this._npc_id != obj.npc_id)
		{
			this._npc_id = obj.npc_id;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("npc_id"));
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
		
		if(this._rotation != obj.rotation)
		{
			this._rotation = obj.rotation;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("rotation"));
		}
		
		if(this._directscaling != obj.directscaling)
		{
			this._directscaling = obj.directscaling;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("directscaling"));
		}
		
		if(this._isalwaysshowheadontext != obj.isalwaysshowheadontext)
		{
			this._isalwaysshowheadontext = obj.isalwaysshowheadontext;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isalwaysshowheadontext"));
		}
		
		if(this._headonmark != obj.headonmark)
		{
			this._headonmark = obj.headonmark;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("headonmark"));
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
		
		if(this._scale_char != obj.scale_char)
		{
			this._scale_char = obj.scale_char;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scale_char"));
		}
		
		if(this._scaling_model != obj.scaling_model)
		{
			this._scaling_model = obj.scaling_model;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scaling_model"));
		}
		
		if(this._isBigStaticMesh != obj.isBigStaticMesh)
		{
			this._isBigStaticMesh = obj.isBigStaticMesh;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isBigStaticMesh"));
		}
		
		if(this._isdummy != obj.isdummy)
		{
			this._isdummy = obj.isdummy;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isdummy"));
		}
		
		if(this._talkdist != obj.talkdist)
		{
			this._talkdist = obj.talkdist;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("talkdist"));
		}
		
		if(this._autofacing != obj.autofacing)
		{
			this._autofacing = obj.autofacing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("autofacing"));
		}
		
		if(this._PerceptiveRadius != obj.PerceptiveRadius)
		{
			this._PerceptiveRadius = obj.PerceptiveRadius;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("PerceptiveRadius"));
		}
		
		if(this._SentientRadius != obj.SentientRadius)
		{
			this._SentientRadius = obj.SentientRadius;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SentientRadius"));
		}
		
		if(this._dialogstyle_antiindulgence != obj.dialogstyle_antiindulgence)
		{
			this._dialogstyle_antiindulgence = obj.dialogstyle_antiindulgence;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("dialogstyle_antiindulgence"));
		}
		
		if(this._main_script != obj.main_script)
		{
			this._main_script = obj.main_script;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("main_script"));
		}
		
		if(this._main_function != obj.main_function)
		{
			this._main_function = obj.main_function;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("main_function"));
		}
		
		if(this._dialog_page != obj.dialog_page)
		{
			this._dialog_page = obj.dialog_page;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("dialog_page"));
		}
		
		if(this._predialog_function != obj.predialog_function)
		{
			this._predialog_function = obj.predialog_function;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("predialog_function"));
		}
		
		if(this._selected_page != obj.selected_page)
		{
			this._selected_page = obj.selected_page;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("selected_page"));
		}
		
		if(this._AI_script != obj.AI_script)
		{
			this._AI_script = obj.AI_script;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AI_script"));
		}
		
		if(this._FrameMoveInterval != obj.FrameMoveInterval)
		{
			this._FrameMoveInterval = obj.FrameMoveInterval;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("FrameMoveInterval"));
		}
		
		if(this._On_FrameMove != obj.On_FrameMove)
		{
			this._On_FrameMove = obj.On_FrameMove;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("On_FrameMove"));
		}
		
		if(this._friend_npcs != obj.friend_npcs)
		{
			this._friend_npcs = obj.friend_npcs;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("friend_npcs"));
		}
		
		if(this._isglobaltimer != obj.isglobaltimer)
		{
			this._isglobaltimer = obj.isglobaltimer;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("isglobaltimer"));
		}
		
		if(this._on_timer != obj.on_timer)
		{
			this._on_timer = obj.on_timer;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("on_timer"));
		}
		
		if(this._timer_period != obj.timer_period)
		{
			this._timer_period = obj.timer_period;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("timer_period"));
		}
		
			}
	
	}
}
		