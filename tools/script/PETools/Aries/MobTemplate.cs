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
	
	public class MobTemplate : IBindableObject
	{
	   	public MobTemplate() {}
	public MobTemplate(string _uid,string _worldfilter,string _codefile,string _template_file,string _name,string _displayname,double _scale,string _asset,double _level,double _hp,string _phase,double _experience_pts,double _joybean_count,double _accuracy_storm_percent,double _accuracy_life_percent,double _accuracy_ice_percent,double _accuracy_fire_percent,double _accuracy_death_percent,double _guarding_range,double _guard_distance,double _random_walk_range,double _power_pip_percent,double _accuracy_penalty_percent,string _available_cards,string _ai_module,double _resist_storm,double _resist_life,double _resist_ice,double _resist_fire,double _resist_death,double _resist_storm_percent,double _resist_life_percent,double _resist_ice_percent,double _resist_fire_percent,double _resist_death_percent,double _damage_storm,double _damage_life,double _damage_ice,double _damage_fire,double _damage_death,double _damage_storm_percent,double _damage_life_percent,double _damage_ice_percent,double _damage_fire_percent,double _damage_death_percent) {
	
this._uid = _uid;
this._worldfilter = _worldfilter;
this._codefile = _codefile;
this._template_file = _template_file;
this._name = _name;
this._displayname = _displayname;
this._scale = _scale;
this._asset = _asset;
this._level = _level;
this._hp = _hp;
this._phase = _phase;
this._experience_pts = _experience_pts;
this._joybean_count = _joybean_count;
this._accuracy_storm_percent = _accuracy_storm_percent;
this._accuracy_life_percent = _accuracy_life_percent;
this._accuracy_ice_percent = _accuracy_ice_percent;
this._accuracy_fire_percent = _accuracy_fire_percent;
this._accuracy_death_percent = _accuracy_death_percent;
this._guarding_range = _guarding_range;
this._guard_distance = _guard_distance;
this._random_walk_range = _random_walk_range;
this._power_pip_percent = _power_pip_percent;
this._accuracy_penalty_percent = _accuracy_penalty_percent;
this._available_cards = _available_cards;
this._ai_module = _ai_module;
this._resist_storm = _resist_storm;
this._resist_life = _resist_life;
this._resist_ice = _resist_ice;
this._resist_fire = _resist_fire;
this._resist_death = _resist_death;
this._resist_storm_percent = _resist_storm_percent;
this._resist_life_percent = _resist_life_percent;
this._resist_ice_percent = _resist_ice_percent;
this._resist_fire_percent = _resist_fire_percent;
this._resist_death_percent = _resist_death_percent;
this._damage_storm = _damage_storm;
this._damage_life = _damage_life;
this._damage_ice = _damage_ice;
this._damage_fire = _damage_fire;
this._damage_death = _damage_death;
this._damage_storm_percent = _damage_storm_percent;
this._damage_life_percent = _damage_life_percent;
this._damage_ice_percent = _damage_ice_percent;
this._damage_fire_percent = _damage_fire_percent;
this._damage_death_percent = _damage_death_percent;
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
				[Category("1display")]
				[Description("mob's English name")]
				
				
				
				public string name
				{
					get { return _name; }
					set
					{
						_name = value;
						OnPropertyChanged(new PropertyChangedEventArgs("name"));
					}
				}			private string _displayname;
				[Category("1display")]
				[Description("Mob's headon display name")]
				
				
				
				public string displayname
				{
					get { return _displayname; }
					set
					{
						_displayname = value;
						OnPropertyChanged(new PropertyChangedEventArgs("displayname"));
					}
				}			private double _scale;
				[Category("1display")]
				[Description("Mob's scale value. default to 1.0")]
				
				
				
				public double scale
				{
					get { return _scale; }
					set
					{
						_scale = value;
						OnPropertyChanged(new PropertyChangedEventArgs("scale"));
					}
				}			private string _asset;
				[Category("1display")]
				[Description("Mob's character asset file path")]
				[FileSelector(InitialDirectory="character/v5/10mobs/HaqiTown/",Filter="ParaXFile(*.x)|*.x|All files (*.*)|*.*",UseQuickSearchDialog=false)]
				[Editor(typeof(PETools.World.Controls.FileSelectorUIEditor),typeof(System.Drawing.Design.UITypeEditor))]
				
				public string asset
				{
					get { return _asset; }
					set
					{
						_asset = value;
						OnPropertyChanged(new PropertyChangedEventArgs("asset"));
					}
				}			private double _level;
				[Category("0basics")]
				[Description("Mob's level value")]
				
				
				
				public double level
				{
					get { return _level; }
					set
					{
						_level = value;
						OnPropertyChanged(new PropertyChangedEventArgs("level"));
					}
				}			private double _hp;
				[Category("0basics")]
				[Description("Mob's health point value")]
				
				
				
				public double hp
				{
					get { return _hp; }
					set
					{
						_hp = value;
						OnPropertyChanged(new PropertyChangedEventArgs("hp"));
					}
				}			private string _phase;
				[Category("0basics")]
				[Description("Mob's phase one of the five element values")]
				[StringList("fire,ice,death,storm,life", AllowCustomEdit=false)]
				
				[TypeConverter(typeof(PETools.World.TypeConverter.StringListConverter))]
				public string phase
				{
					get { return _phase; }
					set
					{
						_phase = value;
						OnPropertyChanged(new PropertyChangedEventArgs("phase"));
					}
				}			private double _experience_pts;
				[Category("0basics")]
				[Description("experience to gain the user when this mob is killed")]
				
				
				
				public double experience_pts
				{
					get { return _experience_pts; }
					set
					{
						_experience_pts = value;
						OnPropertyChanged(new PropertyChangedEventArgs("experience_pts"));
					}
				}			private double _joybean_count;
				[Category("0basics")]
				[Description("奇豆掉落")]
				
				
				
				public double joybean_count
				{
					get { return _joybean_count; }
					set
					{
						_joybean_count = value;
						OnPropertyChanged(new PropertyChangedEventArgs("joybean_count"));
					}
				}			private double _accuracy_storm_percent;
				[Category("accuracy")]
				
				
				
				
				public double accuracy_storm_percent
				{
					get { return _accuracy_storm_percent; }
					set
					{
						_accuracy_storm_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_storm_percent"));
					}
				}			private double _accuracy_life_percent;
				[Category("accuracy")]
				
				
				
				
				public double accuracy_life_percent
				{
					get { return _accuracy_life_percent; }
					set
					{
						_accuracy_life_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_life_percent"));
					}
				}			private double _accuracy_ice_percent;
				[Category("accuracy")]
				
				
				
				
				public double accuracy_ice_percent
				{
					get { return _accuracy_ice_percent; }
					set
					{
						_accuracy_ice_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_ice_percent"));
					}
				}			private double _accuracy_fire_percent;
				[Category("accuracy")]
				
				
				
				
				public double accuracy_fire_percent
				{
					get { return _accuracy_fire_percent; }
					set
					{
						_accuracy_fire_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_fire_percent"));
					}
				}			private double _accuracy_death_percent;
				[Category("accuracy")]
				
				
				
				
				public double accuracy_death_percent
				{
					get { return _accuracy_death_percent; }
					set
					{
						_accuracy_death_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_death_percent"));
					}
				}			private double _guarding_range;
				[Category("basics")]
				[Description("guarding range in meters")]
				
				
				
				public double guarding_range
				{
					get { return _guarding_range; }
					set
					{
						_guarding_range = value;
						OnPropertyChanged(new PropertyChangedEventArgs("guarding_range"));
					}
				}			private double _guard_distance;
				[Category("basics")]
				[Description("guarding distance in meters")]
				
				
				
				public double guard_distance
				{
					get { return _guard_distance; }
					set
					{
						_guard_distance = value;
						OnPropertyChanged(new PropertyChangedEventArgs("guard_distance"));
					}
				}			private double _random_walk_range;
				[Category("basics")]
				[Description("radius of random walk range in meters")]
				
				
				
				public double random_walk_range
				{
					get { return _random_walk_range; }
					set
					{
						_random_walk_range = value;
						OnPropertyChanged(new PropertyChangedEventArgs("random_walk_range"));
					}
				}			private double _power_pip_percent;
				[Category("basics")]
				
				
				
				
				public double power_pip_percent
				{
					get { return _power_pip_percent; }
					set
					{
						_power_pip_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("power_pip_percent"));
					}
				}			private double _accuracy_penalty_percent;
				[Category("basics")]
				
				
				
				
				public double accuracy_penalty_percent
				{
					get { return _accuracy_penalty_percent; }
					set
					{
						_accuracy_penalty_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("accuracy_penalty_percent"));
					}
				}			private string _available_cards;
				[Category("basics")]
				[Description("card gsids owned by the mob, such as (22181,10)(22186,10)(22189,20)")]
				
				
				
				public string available_cards
				{
					get { return _available_cards; }
					set
					{
						_available_cards = value;
						OnPropertyChanged(new PropertyChangedEventArgs("available_cards"));
					}
				}			private string _ai_module;
				[Category("basics")]
				
				
				
				
				public string ai_module
				{
					get { return _ai_module; }
					set
					{
						_ai_module = value;
						OnPropertyChanged(new PropertyChangedEventArgs("ai_module"));
					}
				}			private double _resist_storm;
				[Category("resist")]
				
				
				
				
				public double resist_storm
				{
					get { return _resist_storm; }
					set
					{
						_resist_storm = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_storm"));
					}
				}			private double _resist_life;
				[Category("resist")]
				
				
				
				
				public double resist_life
				{
					get { return _resist_life; }
					set
					{
						_resist_life = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_life"));
					}
				}			private double _resist_ice;
				[Category("resist")]
				
				
				
				
				public double resist_ice
				{
					get { return _resist_ice; }
					set
					{
						_resist_ice = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_ice"));
					}
				}			private double _resist_fire;
				[Category("resist")]
				
				
				
				
				public double resist_fire
				{
					get { return _resist_fire; }
					set
					{
						_resist_fire = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_fire"));
					}
				}			private double _resist_death;
				[Category("resist")]
				
				
				
				
				public double resist_death
				{
					get { return _resist_death; }
					set
					{
						_resist_death = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_death"));
					}
				}			private double _resist_storm_percent;
				[Category("resist_percent")]
				
				
				
				
				public double resist_storm_percent
				{
					get { return _resist_storm_percent; }
					set
					{
						_resist_storm_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_storm_percent"));
					}
				}			private double _resist_life_percent;
				[Category("resist_percent")]
				
				
				
				
				public double resist_life_percent
				{
					get { return _resist_life_percent; }
					set
					{
						_resist_life_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_life_percent"));
					}
				}			private double _resist_ice_percent;
				[Category("resist_percent")]
				
				
				
				
				public double resist_ice_percent
				{
					get { return _resist_ice_percent; }
					set
					{
						_resist_ice_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_ice_percent"));
					}
				}			private double _resist_fire_percent;
				[Category("resist_percent")]
				
				
				
				
				public double resist_fire_percent
				{
					get { return _resist_fire_percent; }
					set
					{
						_resist_fire_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_fire_percent"));
					}
				}			private double _resist_death_percent;
				[Category("resist_percent")]
				
				
				
				
				public double resist_death_percent
				{
					get { return _resist_death_percent; }
					set
					{
						_resist_death_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("resist_death_percent"));
					}
				}			private double _damage_storm;
				[Category("damage")]
				
				
				
				
				public double damage_storm
				{
					get { return _damage_storm; }
					set
					{
						_damage_storm = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_storm"));
					}
				}			private double _damage_life;
				[Category("damage")]
				
				
				
				
				public double damage_life
				{
					get { return _damage_life; }
					set
					{
						_damage_life = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_life"));
					}
				}			private double _damage_ice;
				[Category("damage")]
				
				
				
				
				public double damage_ice
				{
					get { return _damage_ice; }
					set
					{
						_damage_ice = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_ice"));
					}
				}			private double _damage_fire;
				[Category("damage")]
				
				
				
				
				public double damage_fire
				{
					get { return _damage_fire; }
					set
					{
						_damage_fire = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_fire"));
					}
				}			private double _damage_death;
				[Category("damage")]
				
				
				
				
				public double damage_death
				{
					get { return _damage_death; }
					set
					{
						_damage_death = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_death"));
					}
				}			private double _damage_storm_percent;
				[Category("damage_percent")]
				
				
				
				
				public double damage_storm_percent
				{
					get { return _damage_storm_percent; }
					set
					{
						_damage_storm_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_storm_percent"));
					}
				}			private double _damage_life_percent;
				[Category("damage_percent")]
				
				
				
				
				public double damage_life_percent
				{
					get { return _damage_life_percent; }
					set
					{
						_damage_life_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_life_percent"));
					}
				}			private double _damage_ice_percent;
				[Category("damage_percent")]
				
				
				
				
				public double damage_ice_percent
				{
					get { return _damage_ice_percent; }
					set
					{
						_damage_ice_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_ice_percent"));
					}
				}			private double _damage_fire_percent;
				[Category("damage_percent")]
				
				
				
				
				public double damage_fire_percent
				{
					get { return _damage_fire_percent; }
					set
					{
						_damage_fire_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_fire_percent"));
					}
				}			private double _damage_death_percent;
				[Category("damage_percent")]
				
				
				
				
				public double damage_death_percent
				{
					get { return _damage_death_percent; }
					set
					{
						_damage_death_percent = value;
						OnPropertyChanged(new PropertyChangedEventArgs("damage_death_percent"));
					}
				}
	   	public override void UpdateValue(IBindableObject _obj)
			{
				MobTemplate obj = _obj as MobTemplate;
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
		
		if(this._displayname != obj.displayname)
		{
			this._displayname = obj.displayname;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("displayname"));
		}
		
		if(this._scale != obj.scale)
		{
			this._scale = obj.scale;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("scale"));
		}
		
		if(this._asset != obj.asset)
		{
			this._asset = obj.asset;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("asset"));
		}
		
		if(this._level != obj.level)
		{
			this._level = obj.level;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("level"));
		}
		
		if(this._hp != obj.hp)
		{
			this._hp = obj.hp;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("hp"));
		}
		
		if(this._phase != obj.phase)
		{
			this._phase = obj.phase;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("phase"));
		}
		
		if(this._experience_pts != obj.experience_pts)
		{
			this._experience_pts = obj.experience_pts;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("experience_pts"));
		}
		
		if(this._joybean_count != obj.joybean_count)
		{
			this._joybean_count = obj.joybean_count;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("joybean_count"));
		}
		
		if(this._accuracy_storm_percent != obj.accuracy_storm_percent)
		{
			this._accuracy_storm_percent = obj.accuracy_storm_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_storm_percent"));
		}
		
		if(this._accuracy_life_percent != obj.accuracy_life_percent)
		{
			this._accuracy_life_percent = obj.accuracy_life_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_life_percent"));
		}
		
		if(this._accuracy_ice_percent != obj.accuracy_ice_percent)
		{
			this._accuracy_ice_percent = obj.accuracy_ice_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_ice_percent"));
		}
		
		if(this._accuracy_fire_percent != obj.accuracy_fire_percent)
		{
			this._accuracy_fire_percent = obj.accuracy_fire_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_fire_percent"));
		}
		
		if(this._accuracy_death_percent != obj.accuracy_death_percent)
		{
			this._accuracy_death_percent = obj.accuracy_death_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_death_percent"));
		}
		
		if(this._guarding_range != obj.guarding_range)
		{
			this._guarding_range = obj.guarding_range;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("guarding_range"));
		}
		
		if(this._guard_distance != obj.guard_distance)
		{
			this._guard_distance = obj.guard_distance;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("guard_distance"));
		}
		
		if(this._random_walk_range != obj.random_walk_range)
		{
			this._random_walk_range = obj.random_walk_range;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("random_walk_range"));
		}
		
		if(this._power_pip_percent != obj.power_pip_percent)
		{
			this._power_pip_percent = obj.power_pip_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("power_pip_percent"));
		}
		
		if(this._accuracy_penalty_percent != obj.accuracy_penalty_percent)
		{
			this._accuracy_penalty_percent = obj.accuracy_penalty_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("accuracy_penalty_percent"));
		}
		
		if(this._available_cards != obj.available_cards)
		{
			this._available_cards = obj.available_cards;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("available_cards"));
		}
		
		if(this._ai_module != obj.ai_module)
		{
			this._ai_module = obj.ai_module;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("ai_module"));
		}
		
		if(this._resist_storm != obj.resist_storm)
		{
			this._resist_storm = obj.resist_storm;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_storm"));
		}
		
		if(this._resist_life != obj.resist_life)
		{
			this._resist_life = obj.resist_life;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_life"));
		}
		
		if(this._resist_ice != obj.resist_ice)
		{
			this._resist_ice = obj.resist_ice;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_ice"));
		}
		
		if(this._resist_fire != obj.resist_fire)
		{
			this._resist_fire = obj.resist_fire;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_fire"));
		}
		
		if(this._resist_death != obj.resist_death)
		{
			this._resist_death = obj.resist_death;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_death"));
		}
		
		if(this._resist_storm_percent != obj.resist_storm_percent)
		{
			this._resist_storm_percent = obj.resist_storm_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_storm_percent"));
		}
		
		if(this._resist_life_percent != obj.resist_life_percent)
		{
			this._resist_life_percent = obj.resist_life_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_life_percent"));
		}
		
		if(this._resist_ice_percent != obj.resist_ice_percent)
		{
			this._resist_ice_percent = obj.resist_ice_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_ice_percent"));
		}
		
		if(this._resist_fire_percent != obj.resist_fire_percent)
		{
			this._resist_fire_percent = obj.resist_fire_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_fire_percent"));
		}
		
		if(this._resist_death_percent != obj.resist_death_percent)
		{
			this._resist_death_percent = obj.resist_death_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("resist_death_percent"));
		}
		
		if(this._damage_storm != obj.damage_storm)
		{
			this._damage_storm = obj.damage_storm;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_storm"));
		}
		
		if(this._damage_life != obj.damage_life)
		{
			this._damage_life = obj.damage_life;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_life"));
		}
		
		if(this._damage_ice != obj.damage_ice)
		{
			this._damage_ice = obj.damage_ice;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_ice"));
		}
		
		if(this._damage_fire != obj.damage_fire)
		{
			this._damage_fire = obj.damage_fire;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_fire"));
		}
		
		if(this._damage_death != obj.damage_death)
		{
			this._damage_death = obj.damage_death;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_death"));
		}
		
		if(this._damage_storm_percent != obj.damage_storm_percent)
		{
			this._damage_storm_percent = obj.damage_storm_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_storm_percent"));
		}
		
		if(this._damage_life_percent != obj.damage_life_percent)
		{
			this._damage_life_percent = obj.damage_life_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_life_percent"));
		}
		
		if(this._damage_ice_percent != obj.damage_ice_percent)
		{
			this._damage_ice_percent = obj.damage_ice_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_ice_percent"));
		}
		
		if(this._damage_fire_percent != obj.damage_fire_percent)
		{
			this._damage_fire_percent = obj.damage_fire_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_fire_percent"));
		}
		
		if(this._damage_death_percent != obj.damage_death_percent)
		{
			this._damage_death_percent = obj.damage_death_percent;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("damage_death_percent"));
		}
		
			}
	
	}
}
		