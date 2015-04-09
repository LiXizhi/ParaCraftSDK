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
	public class GlobalSettings : IBindableObject
	{
	   	public GlobalSettings() {}
	public GlobalSettings(string _uid,string _worldfilter,string _codefile,string _template_file,string _script_editor,XmlElement _Ctor_Color,double _Ctor_Height,double _Ctor_Speed,XmlElement _Selection_Color,bool _Is_Editing,double _Effect_Level,double _TextureLOD,string _Locale,bool _IsMouseInverse,string _WindowText,bool _IgnoreWindowSizeChange,bool _HasNewConfig,bool _IsWindowClosingAllowed,bool _IsFullScreenMode,double _MultiSampleType,double _MultiSampleQuality,bool _ShowMenu,bool _EnableProfiling,bool _Enable3DRendering,double _RefreshTimer,double _ConsoleTextAttribute,double _CoreUsage) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._script_editor = _script_editor;
this._Ctor_Color = _Ctor_Color;
this._Ctor_Height = _Ctor_Height;
this._Ctor_Speed = _Ctor_Speed;
this._Selection_Color = _Selection_Color;
this._Is_Editing = _Is_Editing;
this._Effect_Level = _Effect_Level;
this._TextureLOD = _TextureLOD;
this._Locale = _Locale;
this._IsMouseInverse = _IsMouseInverse;
this._WindowText = _WindowText;
this._IgnoreWindowSizeChange = _IgnoreWindowSizeChange;
this._HasNewConfig = _HasNewConfig;
this._IsWindowClosingAllowed = _IsWindowClosingAllowed;
this._IsFullScreenMode = _IsFullScreenMode;
this._MultiSampleType = _MultiSampleType;
this._MultiSampleQuality = _MultiSampleQuality;
this._ShowMenu = _ShowMenu;
this._EnableProfiling = _EnableProfiling;
this._Enable3DRendering = _Enable3DRendering;
this._RefreshTimer = _RefreshTimer;
this._ConsoleTextAttribute = _ConsoleTextAttribute;
this._CoreUsage = _CoreUsage;
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
				}			private string _script_editor;
				
				
				
				
				public string script_editor
				{
					get { return _script_editor; }
					set
					{
						_script_editor = value;
						OnPropertyChanged(new PropertyChangedEventArgs("script_editor"));
					}
				}			private XmlElement _Ctor_Color;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement Ctor_Color
				{
					get { return _Ctor_Color; }
					set
					{
						_Ctor_Color = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Ctor_Color"));
					}
				}			private double _Ctor_Height;
				
				
				
				
				public double Ctor_Height
				{
					get { return _Ctor_Height; }
					set
					{
						_Ctor_Height = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Ctor_Height"));
					}
				}			private double _Ctor_Speed;
				
				
				
				
				public double Ctor_Speed
				{
					get { return _Ctor_Speed; }
					set
					{
						_Ctor_Speed = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Ctor_Speed"));
					}
				}			private XmlElement _Selection_Color;
				
				
				
				[TypeConverter(typeof(PETools.World.TypeConverter.NumberArrayListConverter))]
				public XmlElement Selection_Color
				{
					get { return _Selection_Color; }
					set
					{
						_Selection_Color = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Selection_Color"));
					}
				}			private bool _Is_Editing;
				
				
				
				
				public bool Is_Editing
				{
					get { return _Is_Editing; }
					set
					{
						_Is_Editing = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Is_Editing"));
					}
				}			private double _Effect_Level;
				
				
				
				
				public double Effect_Level
				{
					get { return _Effect_Level; }
					set
					{
						_Effect_Level = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Effect_Level"));
					}
				}			private double _TextureLOD;
				
				
				
				
				public double TextureLOD
				{
					get { return _TextureLOD; }
					set
					{
						_TextureLOD = value;
						OnPropertyChanged(new PropertyChangedEventArgs("TextureLOD"));
					}
				}			private string _Locale;
				
				
				
				
				public string Locale
				{
					get { return _Locale; }
					set
					{
						_Locale = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Locale"));
					}
				}			private bool _IsMouseInverse;
				
				
				
				
				public bool IsMouseInverse
				{
					get { return _IsMouseInverse; }
					set
					{
						_IsMouseInverse = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsMouseInverse"));
					}
				}			private string _WindowText;
				
				
				
				
				public string WindowText
				{
					get { return _WindowText; }
					set
					{
						_WindowText = value;
						OnPropertyChanged(new PropertyChangedEventArgs("WindowText"));
					}
				}			private bool _IgnoreWindowSizeChange;
				
				
				
				
				public bool IgnoreWindowSizeChange
				{
					get { return _IgnoreWindowSizeChange; }
					set
					{
						_IgnoreWindowSizeChange = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IgnoreWindowSizeChange"));
					}
				}			private bool _HasNewConfig;
				
				
				
				
				public bool HasNewConfig
				{
					get { return _HasNewConfig; }
					set
					{
						_HasNewConfig = value;
						OnPropertyChanged(new PropertyChangedEventArgs("HasNewConfig"));
					}
				}			private bool _IsWindowClosingAllowed;
				
				
				
				
				public bool IsWindowClosingAllowed
				{
					get { return _IsWindowClosingAllowed; }
					set
					{
						_IsWindowClosingAllowed = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsWindowClosingAllowed"));
					}
				}			private bool _IsFullScreenMode;
				
				
				
				
				public bool IsFullScreenMode
				{
					get { return _IsFullScreenMode; }
					set
					{
						_IsFullScreenMode = value;
						OnPropertyChanged(new PropertyChangedEventArgs("IsFullScreenMode"));
					}
				}			private double _MultiSampleType;
				
				
				
				
				public double MultiSampleType
				{
					get { return _MultiSampleType; }
					set
					{
						_MultiSampleType = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MultiSampleType"));
					}
				}			private double _MultiSampleQuality;
				
				
				
				
				public double MultiSampleQuality
				{
					get { return _MultiSampleQuality; }
					set
					{
						_MultiSampleQuality = value;
						OnPropertyChanged(new PropertyChangedEventArgs("MultiSampleQuality"));
					}
				}			private bool _ShowMenu;
				
				
				
				
				public bool ShowMenu
				{
					get { return _ShowMenu; }
					set
					{
						_ShowMenu = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ShowMenu"));
					}
				}			private bool _EnableProfiling;
				
				
				
				
				public bool EnableProfiling
				{
					get { return _EnableProfiling; }
					set
					{
						_EnableProfiling = value;
						OnPropertyChanged(new PropertyChangedEventArgs("EnableProfiling"));
					}
				}			private bool _Enable3DRendering;
				
				
				
				
				public bool Enable3DRendering
				{
					get { return _Enable3DRendering; }
					set
					{
						_Enable3DRendering = value;
						OnPropertyChanged(new PropertyChangedEventArgs("Enable3DRendering"));
					}
				}			private double _RefreshTimer;
				
				
				
				
				public double RefreshTimer
				{
					get { return _RefreshTimer; }
					set
					{
						_RefreshTimer = value;
						OnPropertyChanged(new PropertyChangedEventArgs("RefreshTimer"));
					}
				}			private double _ConsoleTextAttribute;
				
				
				
				
				public double ConsoleTextAttribute
				{
					get { return _ConsoleTextAttribute; }
					set
					{
						_ConsoleTextAttribute = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ConsoleTextAttribute"));
					}
				}			private double _CoreUsage;
				
				
				
				
				public double CoreUsage
				{
					get { return _CoreUsage; }
					set
					{
						_CoreUsage = value;
						OnPropertyChanged(new PropertyChangedEventArgs("CoreUsage"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				GlobalSettings obj = _obj as GlobalSettings;
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
		
		if(this._script_editor != obj.script_editor)
		{
			this._script_editor = obj.script_editor;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("script_editor"));
		}
		
		if(this._Ctor_Color != obj.Ctor_Color)
		{
			this._Ctor_Color = obj.Ctor_Color;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Ctor_Color"));
		}
		
		if(this._Ctor_Height != obj.Ctor_Height)
		{
			this._Ctor_Height = obj.Ctor_Height;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Ctor_Height"));
		}
		
		if(this._Ctor_Speed != obj.Ctor_Speed)
		{
			this._Ctor_Speed = obj.Ctor_Speed;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Ctor_Speed"));
		}
		
		if(this._Selection_Color != obj.Selection_Color)
		{
			this._Selection_Color = obj.Selection_Color;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Selection_Color"));
		}
		
		if(this._Is_Editing != obj.Is_Editing)
		{
			this._Is_Editing = obj.Is_Editing;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Is_Editing"));
		}
		
		if(this._Effect_Level != obj.Effect_Level)
		{
			this._Effect_Level = obj.Effect_Level;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Effect_Level"));
		}
		
		if(this._TextureLOD != obj.TextureLOD)
		{
			this._TextureLOD = obj.TextureLOD;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("TextureLOD"));
		}
		
		if(this._Locale != obj.Locale)
		{
			this._Locale = obj.Locale;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Locale"));
		}
		
		if(this._IsMouseInverse != obj.IsMouseInverse)
		{
			this._IsMouseInverse = obj.IsMouseInverse;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsMouseInverse"));
		}
		
		if(this._WindowText != obj.WindowText)
		{
			this._WindowText = obj.WindowText;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("WindowText"));
		}
		
		if(this._IgnoreWindowSizeChange != obj.IgnoreWindowSizeChange)
		{
			this._IgnoreWindowSizeChange = obj.IgnoreWindowSizeChange;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IgnoreWindowSizeChange"));
		}
		
		if(this._HasNewConfig != obj.HasNewConfig)
		{
			this._HasNewConfig = obj.HasNewConfig;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("HasNewConfig"));
		}
		
		if(this._IsWindowClosingAllowed != obj.IsWindowClosingAllowed)
		{
			this._IsWindowClosingAllowed = obj.IsWindowClosingAllowed;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsWindowClosingAllowed"));
		}
		
		if(this._IsFullScreenMode != obj.IsFullScreenMode)
		{
			this._IsFullScreenMode = obj.IsFullScreenMode;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("IsFullScreenMode"));
		}
		
		if(this._MultiSampleType != obj.MultiSampleType)
		{
			this._MultiSampleType = obj.MultiSampleType;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MultiSampleType"));
		}
		
		if(this._MultiSampleQuality != obj.MultiSampleQuality)
		{
			this._MultiSampleQuality = obj.MultiSampleQuality;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("MultiSampleQuality"));
		}
		
		if(this._ShowMenu != obj.ShowMenu)
		{
			this._ShowMenu = obj.ShowMenu;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ShowMenu"));
		}
		
		if(this._EnableProfiling != obj.EnableProfiling)
		{
			this._EnableProfiling = obj.EnableProfiling;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("EnableProfiling"));
		}
		
		if(this._Enable3DRendering != obj.Enable3DRendering)
		{
			this._Enable3DRendering = obj.Enable3DRendering;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("Enable3DRendering"));
		}
		
		if(this._RefreshTimer != obj.RefreshTimer)
		{
			this._RefreshTimer = obj.RefreshTimer;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("RefreshTimer"));
		}
		
		if(this._ConsoleTextAttribute != obj.ConsoleTextAttribute)
		{
			this._ConsoleTextAttribute = obj.ConsoleTextAttribute;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ConsoleTextAttribute"));
		}
		
		if(this._CoreUsage != obj.CoreUsage)
		{
			this._CoreUsage = obj.CoreUsage;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("CoreUsage"));
		}
		
			}
	
	}
}
		