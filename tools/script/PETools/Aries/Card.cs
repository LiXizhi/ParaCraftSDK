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
	
	public class Card : IBindableObject
	{
	   	public Card() {}
	public Card(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,string _spell_effect,string _battle_comment,string _basics_type,double _pipcost,double _accuracy,string _spell_school,double _damage_min,double _damage_max,string _damage_school) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._spell_effect = _spell_effect;
this._battle_comment = _battle_comment;
this._basics_type = _basics_type;
this._pipcost = _pipcost;
this._accuracy = _accuracy;
this._spell_school = _spell_school;
this._damage_min = _damage_min;
this._damage_max = _damage_max;
this._damage_school = _damage_school;
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
				[Description("magic card name")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private string _spell_effect;
				[Category("display")]
				[Description("art spell effect file")]
				
				
				
				public string spell_effect
				{
					get { return _spell_effect; }
					set
					{
						_spell_effect = value;
						OnPropertyChanged(new PropertyChangedEventArgs("spell_effect"));
					}
				}			private string _battle_comment;
				[Category("display")]
				[Description("battle comment file")]
				
				
				
				public string battle_comment
				{
					get { return _battle_comment; }
					set
					{
						_battle_comment = value;
						OnPropertyChanged(new PropertyChangedEventArgs("battle_comment"));
					}
				}			private string _basics_type;
				[Category("basics")]
				[Description("AreaAttack")]
				
				
				
				public string basics_type
				{
					get { return _basics_type; }
					set
					{
						_basics_type = value;
						OnPropertyChanged(new PropertyChangedEventArgs("basics_type"));
					}
				}			private double _pipcost;
				[Category("basics")]
				[Description("pips count in order to cast this spell")]
				
				
				
				public double pipcost
				{
					get { return _pipcost; }
					set
					{
						_pipcost = value;
						OnPropertyChanged(new PropertyChangedEventArgs("pipcost"));
					}
				}			private double _accuracy;
				[Category("basics")]
				[Description("percentage value in range [0-100]")]
				
				
				
				public double accuracy
				{
					get { return _accuracy; }
					set
					{
						_accuracy = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy"));
					}
				}			private string _spell_school;
				[Category("basics")]
				[Description("one of five elemental spell school")]
				
				
				
				public string spell_school
				{
					get { return _spell_school; }
					set
					{
						_spell_school = value;
						OnPropertyChanged(new PropertyChangedEventArgs("spell_school"));
					}
				}			private double _damage_min;
				[Category("params")]
				[Description("minimum damage count")]
				
				
				
				public double damage_min
				{
					get { return _damage_min; }
					set
					{
						_damage_min = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_min"));
					}
				}			private double _damage_max;
				[Category("params")]
				[Description("maximum damage count")]
				
				
				
				public double damage_max
				{
					get { return _damage_max; }
					set
					{
						_damage_max = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_max"));
					}
				}			private string _damage_school;
				[Category("params")]
				[Description("one of five elemental spell school")]
				
				
				
				public string damage_school
				{
					get { return _damage_school; }
					set
					{
						_damage_school = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_school"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				Card obj = _obj as Card;
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
		
		if(this._spell_effect != obj.spell_effect)
		{
			this._spell_effect = obj.spell_effect;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("spell_effect"));
		}
		
		if(this._battle_comment != obj.battle_comment)
		{
			this._battle_comment = obj.battle_comment;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("battle_comment"));
		}
		
		if(this._basics_type != obj.basics_type)
		{
			this._basics_type = obj.basics_type;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("basics_type"));
		}
		
		if(this._pipcost != obj.pipcost)
		{
			this._pipcost = obj.pipcost;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("pipcost"));
		}
		
		if(this._accuracy != obj.accuracy)
		{
			this._accuracy = obj.accuracy;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy"));
		}
		
		if(this._spell_school != obj.spell_school)
		{
			this._spell_school = obj.spell_school;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("spell_school"));
		}
		
		if(this._damage_min != obj.damage_min)
		{
			this._damage_min = obj.damage_min;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_min"));
		}
		
		if(this._damage_max != obj.damage_max)
		{
			this._damage_max = obj.damage_max;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_max"));
		}
		
		if(this._damage_school != obj.damage_school)
		{
			this._damage_school = obj.damage_school;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_school"));
		}
		
			}
	
	}
}
		