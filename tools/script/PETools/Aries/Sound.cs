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
	
	public class Sound : IBindableObject
	{
	   	public Sound() {}
	public Sound(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,string _stream,string _loop,string _inmemory,string _delayload,string _AudioSources) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._stream = _stream;
this._loop = _loop;
this._inmemory = _inmemory;
this._delayload = _delayload;
this._AudioSources = _AudioSources;
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
				[Description("sound name")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private string _stream;
				[Category("display")]
				[Description("true to stream content from file, false to load to memory at one time.")]
				[StringList("true,false", AllowCustomEdit=false)]
				
				[TypeConverter(typeof(PETools.World.TypeConverter.StringListConverter))]
				public string stream
				{
					get { return _stream; }
					set
					{
						_stream = value;
						OnPropertyChanged(new PropertyChangedEventArgs("stream"));
					}
				}			private string _loop;
				[Category("display")]
				[Description("true to loop play by default.")]
				[StringList("true,false", AllowCustomEdit=false)]
				
				[TypeConverter(typeof(PETools.World.TypeConverter.StringListConverter))]
				public string loop
				{
					get { return _loop; }
					set
					{
						_loop = value;
						OnPropertyChanged(new PropertyChangedEventArgs("loop"));
					}
				}			private string _inmemory;
				[Category("display")]
				[Description("if true, the audio will still be in memory after stopped or out of range. So the next time, it can be played fast.")]
				[StringList("true,false", AllowCustomEdit=false)]
				
				[TypeConverter(typeof(PETools.World.TypeConverter.StringListConverter))]
				public string inmemory
				{
					get { return _inmemory; }
					set
					{
						_inmemory = value;
						OnPropertyChanged(new PropertyChangedEventArgs("inmemory"));
					}
				}			private string _delayload;
				[Category("display")]
				[Description("if true, we will not preload to memory for non-streaming sound. instead, we will load on first use. ")]
				[StringList("true,false", AllowCustomEdit=false)]
				
				[TypeConverter(typeof(PETools.World.TypeConverter.StringListConverter))]
				public string delayload
				{
					get { return _delayload; }
					set
					{
						_delayload = value;
						OnPropertyChanged(new PropertyChangedEventArgs("delayload"));
					}
				}			private string _AudioSources;
				[Category("display")]
				[Description("AudioSources file path used. ")]
				[FileSelector(InitialDirectory="config/Aries/Sound/",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string AudioSources
				{
					get { return _AudioSources; }
					set
					{
						_AudioSources = value;
						OnPropertyChanged(new PropertyChangedEventArgs("AudioSources"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Sound obj = _obj as Sound;
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
		
		if(this._stream != obj.stream)
		{
			this._stream = obj.stream;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("stream"));
		}
		
		if(this._loop != obj.loop)
		{
			this._loop = obj.loop;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("loop"));
		}
		
		if(this._inmemory != obj.inmemory)
		{
			this._inmemory = obj.inmemory;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("inmemory"));
		}
		
		if(this._delayload != obj.delayload)
		{
			this._delayload = obj.delayload;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("delayload"));
		}
		
		if(this._AudioSources != obj.AudioSources)
		{
			this._AudioSources = obj.AudioSources;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("AudioSources"));
		}
		
			}
	
	}
}
		