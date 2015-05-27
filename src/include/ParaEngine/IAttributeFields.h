#pragma once
#include "AttributeClassIDTable.h"
#include <map>
#include <list>
#include <vector>
#include <string>

/** @def get the offset of a data member(x) from a class(cls) */
#define Member_Offset(x, cls) (int)&(((cls *)0)->x)

#define ATTRIBUTE_DEFINE_CLASS(clsName) \
	virtual int GetAttributeClassID(){return IAttributeFields::GetAttributeClassID();}\
	virtual const char* GetAttributeClassName(){ static const char name[] = #clsName; return name; }

/** @def define a property on class
* e.g. PROPERTY_FIELD(Test, IAttributeFields, m_nTest, int) defines SetTest and GetTest on IAttributeFields
*/
#define PROPERTY_FIELD(name, cls, member, datatype) \
	static void Set##name(cls* c, datatype v) {c->member = v;};\
	static datatype Get##name(cls* c) {return c->member;};

#define ATTRIBUTE_METHOD(clsName, name) static HRESULT name(clsName* cls)
#define ATTRIBUTE_METHOD1(clsName, name, dataType) static HRESULT name(clsName* cls, dataType p1)
#define ATTRIBUTE_METHOD2(clsName, name, dataType) static HRESULT name(clsName* cls, dataType p1,dataType p2)
#define ATTRIBUTE_METHOD3(clsName, name, dataType) static HRESULT name(clsName* cls, dataType p1,dataType p2,dataType p3)
#define ATTRIBUTE_METHOD4(clsName, name, dataType) static HRESULT name(clsName* cls, dataType p1,dataType p2,dataType p3,dataType p4)

/** @def define this to support factory object instantiation from attribute class. By default CAttributeClass::Create() does not support instantiation.
ATTRIBUTE_SUPPORT_CREATE_FACTORY(classname)
*/
#define ATTRIBUTE_SUPPORT_CREATE_FACTORY(classname)  \
	virtual CAttributeClass* CreateAttributeClass(){ \
		return new CAttributeClassImp<classname>(GetAttributeClassID(), GetAttributeClassName(), GetAttributeClassDescription()); \
	};\
	static classname * Create() { \
		classname * pObj = new classname(); \
		pObj->AddToAutoReleasePool();\
		return pObj;\
	};

namespace ParaEngine
{
	using namespace std;
	
	/** a list of all attribute type*/
	enum ATTRIBUTE_FIELDTYPE
	{
		// get(), set()
		FieldType_void, 
		// get(int*) set(int)
		FieldType_Int,	
		// get(bool*) set(bool)
		FieldType_Bool,
		// get(float*) set(float)
		FieldType_Float,
		// get(float*,float* ) set(float, float)
		FieldType_Float_Float,
		// get(float*,float*,float*) set(float, float, float)
		FieldType_Float_Float_Float,
		// get(int*) set(int)
		FieldType_Enum,
		// get(double*) set(double)
		FieldType_Double,
		// get(Vector2*) set(Vector2)
		FieldType_Vector2,
		// get(Vector3*) set(Vector3)
		FieldType_Vector3,
		// get(Vector4*) set(Vector4)
		FieldType_Vector4,
		// get(const char**) set(const char*)
		FieldType_String,
		// get(DWORD*) set(DWORD)
		FieldType_DWORD,
		// get(DVector3*) set(DVector3), double precision vector3
		FieldType_DVector3,
		FieldType_Deprecated = 0xffffffff
	};

	/** for a dynamic attribute field. dynamic attribute of an object at runtime at will. This is different from CAttributeField 
	* it is either double or string. 
	*/
	class CDynamicAttributeField
	{
	public:
		/** type of this field */
		ATTRIBUTE_FIELDTYPE m_type;

		double m_dValue;
		string m_sValue;
	public:
		CDynamicAttributeField(){m_type=FieldType_void;m_dValue=0;};
		~CDynamicAttributeField(){};

		operator int();
		operator bool();
		operator DWORD();
		operator const char*();
		operator const string&();
		operator double();
		operator float();

		CDynamicAttributeField& operator =(const int& value) {m_dValue = value; m_type=FieldType_Int;return (*this);};
		CDynamicAttributeField& operator =(const DWORD& value) {m_dValue = value; m_type=FieldType_DWORD;return (*this);};
		CDynamicAttributeField& operator =(const bool& value){m_dValue = value?1:0; m_type=FieldType_Bool;return (*this);};
		CDynamicAttributeField& operator =(const double&value){m_dValue = value; m_type=FieldType_Double;return (*this);};
		CDynamicAttributeField& operator =(const float&value){m_dValue = value; m_type=FieldType_Float;return (*this);};
		CDynamicAttributeField& operator =(const char*value){m_sValue = value; m_type=FieldType_String;return (*this);};
		CDynamicAttributeField& operator =(const string& value){m_sValue = value; m_type=FieldType_String;return (*this);};

		bool IsNil(){return m_type==FieldType_void;}
		bool IsStringType() {return m_type==FieldType_String;}
		/**
		* In case of nil, it is "nil", in case of string, it is in quatation mark.  
		* @param output: it will append result to output
		*/
		void ToNPLString(string& output);
	};


	/** for a single attribute field */
	class CAttributeField
	{
	public:
		CAttributeField();
		~CAttributeField();
	public:
		union any_offset{
			void* ptr_fun;
			int offset_data;
		};
		any_offset m_offsetSetFunc;
		any_offset m_offsetGetFunc;

		/** field name: e.g. "base.position" */
		string		m_sFieldname;
		/** see ATTRIBUTE_FIELDTYPE */
		DWORD		m_type; 

		/** additional schematics for describing the display format of the data. Different attribute type have different schematics.
		@see GetSimpleSchema() */
		string		m_sSchematics;
		/** a help string.*/
		string		m_sHelpString;
	public:
		/**
		* get the field type as string
		* @return one of the following type may be returned 
		* "void" "bool" "string" "int" "float" "float_float" "float_float_float" "double" "vector2" "vector3" "vector4" "enum" "deprecated" ""
		*/
		const char* GetTypeAsString();

		inline HRESULT Call(void* obj)
		{
			if(m_offsetSetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj))m_offsetSetFunc.ptr_fun)(obj);
			else if(m_offsetGetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj))m_offsetSetFunc.ptr_fun)(obj);
			else
				return E_FAIL;
		};
		inline HRESULT Get(void* obj)
		{
			if(m_offsetGetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj))m_offsetSetFunc.ptr_fun)(obj);
			else
				return E_FAIL;
		};
		/* attention should be paid: alway explicitly pass the parameter type to the function. e.g. Set(obj, (bool)bValue)*/
		template <class datatype>
		inline HRESULT Set(void* obj, datatype p1)
		{
			if(m_offsetSetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype p1))m_offsetSetFunc.ptr_fun)(obj, p1);
			else
				return E_FAIL;
		};
		template <class datatype>
		inline HRESULT Set(void* obj, datatype p1, datatype p2)
		{
			if(m_offsetSetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype p1, datatype p2))m_offsetSetFunc.ptr_fun)(obj, p1, p2);
			else
				return E_FAIL;
		};
		template <class datatype>
		inline HRESULT Set(void* obj, datatype p1, datatype p2, datatype p3)
		{
			if(m_offsetSetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype p1, datatype p2, datatype p3))m_offsetSetFunc.ptr_fun)(obj, p1, p2, p3);
			else
				return E_FAIL;
		};
		template <class datatype>
		inline HRESULT Get(void* obj, datatype* p1)
		{
			if(m_offsetGetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype* p1))m_offsetGetFunc.ptr_fun)(obj, p1);
			else
				return E_FAIL;
		};
		template <class datatype>
		inline HRESULT Get(void* obj, datatype* p1, datatype* p2)
		{
			if(m_offsetGetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype* p1, datatype* p2))m_offsetGetFunc.ptr_fun)(obj, p1, p2);
			else
				return E_FAIL;
		};
		template <class datatype>
		inline HRESULT Get(void* obj, datatype* p1, datatype* p2, datatype* p3)
		{
			if(m_offsetGetFunc.ptr_fun!=0)
				return ((HRESULT (*)(void* obj, datatype* p1, datatype* p2, datatype* p3))m_offsetGetFunc.ptr_fun)(obj, p1, p2, p3);
			else
				return E_FAIL;
		};
	public:
		enum SIMPLE_SCHEMA
		{
			SCHEMA_RGB = 0, 
			SCHEMA_FILE,
			SCHEMA_SCRIPT,
			SCHEMA_INTEGER,
		};
		/**
		* attribute schematics:  All simple schematics start with ':', they are mostly used in script.
		color3	":rgb" 
		file	":file" 
		script	":script"
		integer	":int{min, max}"
		float	":float{min, max}"
		* @param schema 
		* @return 
		*/
		static const char* GetSimpleSchema(SIMPLE_SCHEMA schema);
		static const char* GetSimpleSchemaOfRGB(){return GetSimpleSchema(SCHEMA_RGB);};
		static const char* GetSimpleSchemaOfFile(){return GetSimpleSchema(SCHEMA_FILE);};
		static const char* GetSimpleSchemaOfScript(){return GetSimpleSchema(SCHEMA_SCRIPT);};
		static const char* GetSimpleSchemaOfInt(int nMin, int nMax);
		static const char* GetSimpleSchemaOfFloat(float nMin, float nMax);

		/**
		* parse the schema type from the schema string.
		* @return : simple schema type. it may be any of the following value. 
			unspecified: ""
			color3	":rgb" 
			file	":file" 
			script	":script"
			integer	":int"
			float	":float"
		*/
		const char* GetSchematicsType();
		
		/**
		* parse the schema min max value from the schema string.
		* @param fMin : [out]if the schema does not contain a min value, the default value which is smallest float.
		* @param fMax : [out]if the schema does not contain a max value, the default value which is largest float.
		* @return true if found min max.
		*/
		bool GetSchematicsMinMax(float& fMin, float& fMax);

	};

	/** an attribute class is a collection of attribute fields. */
	class CAttributeClass
	{
	public:
		CAttributeClass(int nClassID, const char* sClassName, const char* sClassDescription);
		virtual ~CAttributeClass(){}
		enum Field_Order
		{
			Sort_ByName,
			Sort_ByCategory,
			Sort_ByInstallOrder,
		};
	public:
		/** add a new field.
		@param sFieldname: field name
		@param Type: the field type. it may be one of the ATTRIBUTE_FIELDTYPE.
		@param offsetSetFunc: must be __stdcall function pointer or NULL. The function prototype should match that of the Type.
		@param offsetGetFunc: must be __stdcall function pointer or NULL. The function prototype should match that of the Type.
		@param sSchematics: a string or NULL. The string pattern should match that of the Type.
		@param sHelpString: a help string or NULL. 
		@param bOverride: true to override existing field if any. This is usually set to true, so that inherited class can 
			override the fields installed previously by the base class. 
		*/
		void AddField(const char*  sFieldname,DWORD Type, void* offsetSetFunc,void* offsetGetFunc, const char* sSchematics, const char* sHelpString,bool bOverride);
		/** use of deprecated field takes no effect and will output warning in the log. */
		void AddField_Deprecated(const char *fieldName,bool bOverride=true);
		/** remove a field, return true if moved. false if field not found. */
		bool RemoveField(const char* sFieldname);
		void RemoveAllFields();

		/** class ID */
		int  GetClassID() const;
		/** class name */
		const char* GetClassName() const;
		/** class description */
		const char* GetClassDescription() const;

		/** Set which order fields are saved. */
		void SetOrder(Field_Order order);
		/** get which order fields are saved. */
		Field_Order GetOrder();

		/** get the total number of field. */
		int GetFieldNum();
		/** get field at the specified index. NULL will be returned if index is out of range. */
		CAttributeField* GetField(int nIndex);

		/**
		* get field index of a given field name. -1 will be returned if name not found. 
		* @param sFieldname 
		* @return 
		*/
		int GetFieldIndex(const char*  sFieldname);

		/** return NULL, if the field does not exists */
		CAttributeField* GetField(const char*  sFieldname);

		/** create an instance of this class object */
		virtual IAttributeFields* Create();
	protected:
		int m_nClassID;
		const char* m_sClassName;
		const char* m_sClassDescription;
		vector<CAttributeField> m_attributes;
		Field_Order m_nCurrentOrder;
	private:
		/** insert a new field. return true if succeeded.
		@param bOverride: true to override existing field if any. This is usually set to true, so that inherited class can 
		override the fields installed previously by the base class. 
		*/
		bool InsertField(CAttributeField& item, bool bOverride);
	};

	/** derived attribute class. 
	* Class T should add following macro to its header in order to use this factory class
	* ATTRIBUTE_SUPPORT_CREATE_FACTORY(CWeatherEffect);
	* or T should have Create() method manually defined.
	*/
	template<typename T>
	class CAttributeClassImp : public CAttributeClass
	{
	public:
		typedef T classType;
		CAttributeClassImp(int nClassID, const char* sClassName, const char* sClassDescription)
			: CAttributeClass(nClassID, sClassName, sClassDescription) {};
		virtual ~CAttributeClassImp(){};

		/** see class reference if classType::Create is not defined. */
		virtual IAttributeFields* Create()
		{
			return classType::Create();
		}
	};

	/** A common interface for all classes implementing IAttributeFields
	By implementing this class's virtual functions, it enables a class to easily expose attributes
	to the NPL scripting interface. All standard attribute types are supported by the property dialog UI, which
	makes displaying and editing object attributes an automatic process.

	This class has only one data member, hence there are little space penalties for implementing this class.
	The attribute information for each class is kept centrally in a global table.
	An example of using this class can be found at	AttributesManager.h and CAttributesManager::PrintManual()
	most objects in ParaEngine implement this class, such as CBaseObject, etc.
	The following virtual functions must be implemented: GetAttributeClassID(), GetAttributeClassName(), InstallFields()
	*/
	class IAttributeFields : public IObject
	{
	public:
		typedef ParaEngine::weak_ptr<IObject, IAttributeFields> WeakPtr_type;
		IAttributeFields(void);
		virtual ~IAttributeFields(void);

	public:
		//////////////////////////////////////////////////////////////////////////
		// implementation of IAttributeFields

		/** attribute class ID should be identical, unless one knows how overriding rules work.*/
		virtual int GetAttributeClassID();
		/** a static string, describing the attribute class object's name */
		virtual const char* GetAttributeClassName(){ static const char name[] = "Unknown"; return name; }
		/** a static string, describing the attribute class object */
		virtual const char* GetAttributeClassDescription(){ static const char desc[] = ""; return desc; }
		/** this class should be implemented if one wants to add new attribute. This function is always called internally.*/
		virtual int InstallFields(CAttributeClass* pClass, bool bOverride);

		ATTRIBUTE_METHOD1(IAttributeFields, GetName_s, const char**)	{ *p1 = cls->GetIdentifier().c_str(); return S_OK; }
		ATTRIBUTE_METHOD1(IAttributeFields, SetName_s, const char*)	{ cls->SetIdentifier(p1); return S_OK; }
		ATTRIBUTE_METHOD(IAttributeFields, PrintObject_s){ cls->PrintObject(); return S_OK; }
		ATTRIBUTE_METHOD(IAttributeFields, AddRef_s){ cls->addref(); return S_OK; }
		ATTRIBUTE_METHOD1(IAttributeFields, GetRefCount_s, int*)	{ *p1 = cls->GetRefCount(); return S_OK; }
		ATTRIBUTE_METHOD(IAttributeFields, Release_s){ cls->Release(); return S_OK; }

		//////////////////////////////////////////////////////////////////////////
		//
		// implementation of the following virtual functions are optional
		//
		//////////////////////////////////////////////////////////////////////////

		virtual const std::string& GetIdentifier() const;
		virtual void SetIdentifier(const std::string& sID);

		/** whether some of the fields are modified.It is up to the implementation class to provide this functionality if necessary. */
		virtual bool IsModified(){ return false; };
		/** set whether any field has been modified. */
		virtual void SetModified(bool bModified){};

		/** validate all fields and return true if validation passed. */
		virtual bool ValidateFields(){ return true; };
		/** get the recent validation message due to the most recent call to ValidateFields() */
		virtual string GetValidationMessage(){ return ""; };

		/**
		* Reset the field to its initial or default value.
		* @param nFieldID : field ID
		* @return true if value is set; false if value not set.
		*/
		virtual bool ResetField(int nFieldID){ return false; };

		/**
		* Invoke an (external) editor for a given field. This is usually for NPL script field
		* @param nFieldID : field ID
		* @param sParameters : the parameter passed to the editor
		* @return true if editor is invoked, false if failed or field has no editor.
		*/
		virtual bool InvokeEditor(int nFieldID, const std::string& sParameters){ return false; };

		/** get attribute by child object. used to iterate across the attribute field hierarchy. */
		virtual IAttributeFields* GetChildAttributeObject(const std::string& sName);
		/** get the number of child objects (row count) in the given column. please note different columns can have different row count. */
		virtual int GetChildAttributeObjectCount(int nColumnIndex = 0);
		/** we support multi-dimensional child object. by default objects have only one column. */
		virtual int GetChildAttributeColumnCount();
		virtual IAttributeFields* GetChildAttributeObject(int nRowIndex, int nColumnIndex = 0);
		
		//////////////////////////////////////////////////////////////////////////
		//
		// Dynamic field method
		//
		//////////////////////////////////////////////////////////////////////////

		/**
		* Get a dynamic field with a given name.
		* @param sName: name of the field to set
		* @return: return the field or NULL if does not exist
		*/
		CDynamicAttributeField* GetDynamicField(const char* sName);

		/**
		* Get a dynamic field with a given index.
		* @param sName: name of the field to set
		* @return: return the field or NULL if does not exist
		*/
		CDynamicAttributeField* GetDynamicField(int nIndex);

		/** get field name by index */
		const char* GetDynamicFieldNameByIndex(int nIndex);

		/** how many dynamic field this object currently have. */
		int GetDynamicFieldCount();

		/**
		* set a dynamic field with a given name.
		* @param sName: name of the field to set
		* @value: the value to add. if NULL, field will be removed.
		*/
		void SetDynamicField(const char* sName, const CDynamicAttributeField* value);

		/** remove all dynamic fields*/
		void RemoveAllDynamicFields();

		/** save only text dynamic fields to fieldname = value text strings. one on each line. line seperator is \n.
		* @return the number of fields saved. or -1 if failed.
		*/
		int SaveDynamicFieldsToString(string& output);

		/** load only text dynamic fields from string
		* @return the number of fields loaded.
		*/
		int LoadDynamicFieldsFromString(const string& input);
	public:
		/** get the main attribute class object. */
		CAttributeClass* GetAttributeClass();
		/** print the content of this object to a text file at temp/doc/[ClassName].txt.
		This is usually used for dumping and testing object attributes.*/
		void PrintObject();

		static HRESULT GetAttributeClassID_s(IAttributeFields* cls, int* p1) { *p1 = cls->GetAttributeClassID(); return S_OK; }
		static HRESULT GetAttributeClassName_s(IAttributeFields* cls, const char** p1) { *p1 = cls->GetAttributeClassName(); return S_OK; }

		/**
		* Open a given file with the default registered editor in the game engine.
		* @param sFileName: file name to be opened by the default editor.
		* @param bWaitOnReturn: if false, the function returns immediately; otherwise it will wait for the editor to return.
		* @return true if opened.
		*/
		static bool OpenWithDefaultEditor(const char* sFilename, bool bWaitOnReturn = false);

	protected:
		/** initialize fields */
		virtual CAttributeClass* CreateAttributeClass();

	private:
		map<string, CDynamicAttributeField> m_dynamicFields;
	};
}
