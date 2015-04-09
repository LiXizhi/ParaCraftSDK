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
	public class Camera : IBindableObject
	{
	   	public Camera() {}
	public Camera(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,double _facing,double _width,double _height,double _depth,double _radius,XmlElement _position,double _render_tech,double _progress,string _homezone,bool _showboundingbox,double _PhysicsGroup,double _SelectGroupIndex,string _On_AssetLoaded,double _RenderImportance,double _AnimID,double _AnimFrame,bool _UseGlobalTime,double _NearPlane,double _FarPlane,double _FieldOfView,double _AspectRatio,bool _IsPerspectiveView,double _OrthoWidth,double _OrthoHeight,bool _InvertPitch,bool _MovementDrag,double _TotalDragTime,double _SmoothFramesNum,XmlElement _Eye_position,XmlElement _Lookat_position,double _KeyboardMovVelocity,double _KeyboardRotVelocity,bool _AlwaysRun,double _CameraMode,bool _CamAlwaysBehindObject,bool _UseRightButtonBipedFacing,double _CameraObjectDistance,double _CameraLiftupAngle,double _CameraRotY,double _LookAtShiftY,bool _EnableKeyboard,bool _EnableMouseLeftButton,bool _EnableMouseRightButton,bool _EnableMouseWheel,bool _BlockInput,bool _EnableMouseRightDrag,bool _EnableMouseLeftDrag,bool _UseCharacterLookup,bool _UseCharacterLookupWhenMounted) {
	
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
this._NearPlane = _NearPlane;
this._FarPlane = _FarPlane;
this._FieldOfView = _FieldOfView;
this._AspectRatio = _AspectRatio;
this._IsPerspectiveView = _IsPerspectiveView;
this._OrthoWidth = _OrthoWidth;
this._OrthoHeight = _OrthoHeight;
this._InvertPitch = _InvertPitch;
this._MovementDrag = _MovementDrag;
this._TotalDragTime = _TotalDragTime;
this._SmoothFramesNum = _SmoothFramesNum;
this._Eye_position = _Eye_position;
this._Lookat_position = _Lookat_position;
this._KeyboardMovVelocity = _KeyboardMovVelocity;
this._KeyboardRotVelocity = _KeyboardRotVelocity;
this._AlwaysRun = _AlwaysRun;
this._CameraMode = _CameraMode;
this._CamAlwaysBehindObject = _CamAlwaysBehindObject;
this._UseRightButtonBipedFacing = _UseRightButtonBipedFacing;
this._CameraObjectDistance = _CameraObjectDistance;
this._CameraLiftupAngle = _CameraLiftupAngle;
this._CameraRotY = _CameraRotY;
this._LookAtShiftY = _LookAtShiftY;
this._EnableKeyboard = _EnableKeyboard;
this._EnableMouseLeftButton = _EnableMouseLeftButton;
this._EnableMouseRightButton = _EnableMouseRightButton;
this._EnableMouseWheel = _EnableMouseWheel;
this._BlockInput = _BlockInput;
this._EnableMouseRightDrag = _EnableMouseRightDrag;
this._EnableMouseLeftDrag = _EnableMouseLeftDrag;
this._UseCharacterLookup = _UseCharacterLookup;
this._UseCharacterLookupWhenMounted = _UseCharacterLookupWhenMounted;
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
				}			private bool _IsPerspectiveView;
				
				
				
				
				public bool IsPerspectiveView
				{
					get { return _IsPerspectiveView; }
					set
					{
						_IsPerspectiveView = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsPerspectiveView"));
					}
				}			private double _OrthoWidth;
				
				
				
				
				public double OrthoWidth
				{
					get { return _OrthoWidth; }
					set
					{
						_OrthoWidth = value;
						OnPropertyChanged(new PropertyChangedEventArgs("OrthoWidth"));
					}
				}			private double _OrthoHeight;
				
				
				
				
				public double OrthoHeight
				{
					get { return _OrthoHeight; }
					set
					{
						_OrthoHeight = value;
						OnPropertyChanged(new PropertyChangedEventArgs("OrthoHeight"));
					}
				}			private bool _InvertPitch;
				
				
				
				
				public bool InvertPitch
				{
					get { return _InvertPitch; }
					set
					{
						_InvertPitch = value;
						OnPropertyChanged(new PropertyChangedEventArgs("InvertPitch"));
					}
				}			private bool _MovementDrag;
				
				
				
				
				public bool MovementDrag
				{
					get { return _MovementDrag; }
					set
					{
						_MovementDrag = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MovementDrag"));
					}
				}			private double _TotalDragTime;
				
				
				
				
				public double TotalDragTime
				{
					get { return _TotalDragTime; }
					set
					{
						_TotalDragTime = value;
						OnPropertyChanged(new PropertyChangedEventArgs("TotalDragTime"));
					}
				}			private double _SmoothFramesNum;
				
				
				
				
				public double SmoothFramesNum
				{
					get { return _SmoothFramesNum; }
					set
					{
						_SmoothFramesNum = value;
						OnPropertyChanged(new PropertyChangedEventArgs("SmoothFramesNum"));
					}
				}			private XmlElement _Eye_position;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement Eye_position
				{
					get { return _Eye_position; }
					set
					{
						_Eye_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Eye_position"));
					}
				}			private XmlElement _Lookat_position;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement Lookat_position
				{
					get { return _Lookat_position; }
					set
					{
						_Lookat_position = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Lookat_position"));
					}
				}			private double _KeyboardMovVelocity;
				
				
				
				
				public double KeyboardMovVelocity
				{
					get { return _KeyboardMovVelocity; }
					set
					{
						_KeyboardMovVelocity = value;
						OnPropertyChanged(new PropertyChangedEventArgs("KeyboardMovVelocity"));
					}
				}			private double _KeyboardRotVelocity;
				
				
				
				
				public double KeyboardRotVelocity
				{
					get { return _KeyboardRotVelocity; }
					set
					{
						_KeyboardRotVelocity = value;
						OnPropertyChanged(new PropertyChangedEventArgs("KeyboardRotVelocity"));
					}
				}			private bool _AlwaysRun;
				
				
				
				
				public bool AlwaysRun
				{
					get { return _AlwaysRun; }
					set
					{
						_AlwaysRun = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AlwaysRun"));
					}
				}			private double _CameraMode;
				
				
				
				
				public double CameraMode
				{
					get { return _CameraMode; }
					set
					{
						_CameraMode = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CameraMode"));
					}
				}			private bool _CamAlwaysBehindObject;
				
				
				
				
				public bool CamAlwaysBehindObject
				{
					get { return _CamAlwaysBehindObject; }
					set
					{
						_CamAlwaysBehindObject = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CamAlwaysBehindObject"));
					}
				}			private bool _UseRightButtonBipedFacing;
				
				
				
				
				public bool UseRightButtonBipedFacing
				{
					get { return _UseRightButtonBipedFacing; }
					set
					{
						_UseRightButtonBipedFacing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseRightButtonBipedFacing"));
					}
				}			private double _CameraObjectDistance;
				
				
				
				
				public double CameraObjectDistance
				{
					get { return _CameraObjectDistance; }
					set
					{
						_CameraObjectDistance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CameraObjectDistance"));
					}
				}			private double _CameraLiftupAngle;
				
				
				
				
				public double CameraLiftupAngle
				{
					get { return _CameraLiftupAngle; }
					set
					{
						_CameraLiftupAngle = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CameraLiftupAngle"));
					}
				}			private double _CameraRotY;
				
				
				
				
				public double CameraRotY
				{
					get { return _CameraRotY; }
					set
					{
						_CameraRotY = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CameraRotY"));
					}
				}			private double _LookAtShiftY;
				
				
				
				
				public double LookAtShiftY
				{
					get { return _LookAtShiftY; }
					set
					{
						_LookAtShiftY = value;
						OnPropertyChanged(new PropertyChangedEventArgs("LookAtShiftY"));
					}
				}			private bool _EnableKeyboard;
				
				
				
				
				public bool EnableKeyboard
				{
					get { return _EnableKeyboard; }
					set
					{
						_EnableKeyboard = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableKeyboard"));
					}
				}			private bool _EnableMouseLeftButton;
				
				
				
				
				public bool EnableMouseLeftButton
				{
					get { return _EnableMouseLeftButton; }
					set
					{
						_EnableMouseLeftButton = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMouseLeftButton"));
					}
				}			private bool _EnableMouseRightButton;
				
				
				
				
				public bool EnableMouseRightButton
				{
					get { return _EnableMouseRightButton; }
					set
					{
						_EnableMouseRightButton = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMouseRightButton"));
					}
				}			private bool _EnableMouseWheel;
				
				
				
				
				public bool EnableMouseWheel
				{
					get { return _EnableMouseWheel; }
					set
					{
						_EnableMouseWheel = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMouseWheel"));
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
				}			private bool _EnableMouseRightDrag;
				
				
				
				
				public bool EnableMouseRightDrag
				{
					get { return _EnableMouseRightDrag; }
					set
					{
						_EnableMouseRightDrag = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMouseRightDrag"));
					}
				}			private bool _EnableMouseLeftDrag;
				
				
				
				
				public bool EnableMouseLeftDrag
				{
					get { return _EnableMouseLeftDrag; }
					set
					{
						_EnableMouseLeftDrag = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableMouseLeftDrag"));
					}
				}			private bool _UseCharacterLookup;
				
				
				
				
				public bool UseCharacterLookup
				{
					get { return _UseCharacterLookup; }
					set
					{
						_UseCharacterLookup = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseCharacterLookup"));
					}
				}			private bool _UseCharacterLookupWhenMounted;
				
				
				
				
				public bool UseCharacterLookupWhenMounted
				{
					get { return _UseCharacterLookupWhenMounted; }
					set
					{
						_UseCharacterLookupWhenMounted = value;
						OnPropertyChanged(new PropertyChangedEventArgs("UseCharacterLookupWhenMounted"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Camera obj = _obj as Camera;
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
		
		if(this._IsPerspectiveView != obj.IsPerspectiveView)
		{
			this._IsPerspectiveView = obj.IsPerspectiveView;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsPerspectiveView"));
		}
		
		if(this._OrthoWidth != obj.OrthoWidth)
		{
			this._OrthoWidth = obj.OrthoWidth;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("OrthoWidth"));
		}
		
		if(this._OrthoHeight != obj.OrthoHeight)
		{
			this._OrthoHeight = obj.OrthoHeight;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("OrthoHeight"));
		}
		
		if(this._InvertPitch != obj.InvertPitch)
		{
			this._InvertPitch = obj.InvertPitch;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("InvertPitch"));
		}
		
		if(this._MovementDrag != obj.MovementDrag)
		{
			this._MovementDrag = obj.MovementDrag;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MovementDrag"));
		}
		
		if(this._TotalDragTime != obj.TotalDragTime)
		{
			this._TotalDragTime = obj.TotalDragTime;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("TotalDragTime"));
		}
		
		if(this._SmoothFramesNum != obj.SmoothFramesNum)
		{
			this._SmoothFramesNum = obj.SmoothFramesNum;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("SmoothFramesNum"));
		}
		
		if(this._Eye_position != obj.Eye_position)
		{
			this._Eye_position = obj.Eye_position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Eye_position"));
		}
		
		if(this._Lookat_position != obj.Lookat_position)
		{
			this._Lookat_position = obj.Lookat_position;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Lookat_position"));
		}
		
		if(this._KeyboardMovVelocity != obj.KeyboardMovVelocity)
		{
			this._KeyboardMovVelocity = obj.KeyboardMovVelocity;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("KeyboardMovVelocity"));
		}
		
		if(this._KeyboardRotVelocity != obj.KeyboardRotVelocity)
		{
			this._KeyboardRotVelocity = obj.KeyboardRotVelocity;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("KeyboardRotVelocity"));
		}
		
		if(this._AlwaysRun != obj.AlwaysRun)
		{
			this._AlwaysRun = obj.AlwaysRun;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AlwaysRun"));
		}
		
		if(this._CameraMode != obj.CameraMode)
		{
			this._CameraMode = obj.CameraMode;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CameraMode"));
		}
		
		if(this._CamAlwaysBehindObject != obj.CamAlwaysBehindObject)
		{
			this._CamAlwaysBehindObject = obj.CamAlwaysBehindObject;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CamAlwaysBehindObject"));
		}
		
		if(this._UseRightButtonBipedFacing != obj.UseRightButtonBipedFacing)
		{
			this._UseRightButtonBipedFacing = obj.UseRightButtonBipedFacing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseRightButtonBipedFacing"));
		}
		
		if(this._CameraObjectDistance != obj.CameraObjectDistance)
		{
			this._CameraObjectDistance = obj.CameraObjectDistance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CameraObjectDistance"));
		}
		
		if(this._CameraLiftupAngle != obj.CameraLiftupAngle)
		{
			this._CameraLiftupAngle = obj.CameraLiftupAngle;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CameraLiftupAngle"));
		}
		
		if(this._CameraRotY != obj.CameraRotY)
		{
			this._CameraRotY = obj.CameraRotY;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CameraRotY"));
		}
		
		if(this._LookAtShiftY != obj.LookAtShiftY)
		{
			this._LookAtShiftY = obj.LookAtShiftY;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("LookAtShiftY"));
		}
		
		if(this._EnableKeyboard != obj.EnableKeyboard)
		{
			this._EnableKeyboard = obj.EnableKeyboard;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableKeyboard"));
		}
		
		if(this._EnableMouseLeftButton != obj.EnableMouseLeftButton)
		{
			this._EnableMouseLeftButton = obj.EnableMouseLeftButton;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMouseLeftButton"));
		}
		
		if(this._EnableMouseRightButton != obj.EnableMouseRightButton)
		{
			this._EnableMouseRightButton = obj.EnableMouseRightButton;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMouseRightButton"));
		}
		
		if(this._EnableMouseWheel != obj.EnableMouseWheel)
		{
			this._EnableMouseWheel = obj.EnableMouseWheel;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMouseWheel"));
		}
		
		if(this._BlockInput != obj.BlockInput)
		{
			this._BlockInput = obj.BlockInput;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("BlockInput"));
		}
		
		if(this._EnableMouseRightDrag != obj.EnableMouseRightDrag)
		{
			this._EnableMouseRightDrag = obj.EnableMouseRightDrag;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMouseRightDrag"));
		}
		
		if(this._EnableMouseLeftDrag != obj.EnableMouseLeftDrag)
		{
			this._EnableMouseLeftDrag = obj.EnableMouseLeftDrag;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableMouseLeftDrag"));
		}
		
		if(this._UseCharacterLookup != obj.UseCharacterLookup)
		{
			this._UseCharacterLookup = obj.UseCharacterLookup;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseCharacterLookup"));
		}
		
		if(this._UseCharacterLookupWhenMounted != obj.UseCharacterLookupWhenMounted)
		{
			this._UseCharacterLookupWhenMounted = obj.UseCharacterLookupWhenMounted;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("UseCharacterLookupWhenMounted"));
		}
		
			}
	
	}
}
		