$PBExportHeader$u_registry.sru
$PBExportComments$[ceusee] 레지스트 읽어오는 Object
forward
global type u_registry from nonvisualobject
end type
end forward

global type u_registry from nonvisualobject
end type
global u_registry u_registry

type variables
String is_init_reg
end variables

forward prototypes
public function boolean del (string as_key, string as_value_name)
public function string get (string as_key, string as_value_name)
public function boolean set (string as_key, string as_value_name, string as_value)
public subroutine set_app ()
end prototypes

public function boolean del (string as_key, string as_value_name);Integer li_result
String  ls_key

If Trim(as_key) <> '' Then
	ls_key = as_key
Else
	ls_key = is_init_reg
End If

//Delete
li_result = RegistryDelete(ls_key, as_value_name)
If li_result <> 1 Then Return false

//Sucess 
Return true
end function

public function string get (string as_key, string as_value_name);String ls_value, ls_key

If Trim(as_key) <> '' Then
	ls_key = as_key
Else
	ls_key = is_init_reg
End If

//Get
RegistryGet(ls_key, as_value_name, ls_value)
If IsNull(ls_value) Then ls_value = ""

Return ls_value
end function

public function boolean set (string as_key, string as_value_name, string as_value);Integer li_result
String ls_key

If Trim(as_key) <> '' Then
	ls_key = as_key
Else
	ls_key = is_init_reg
End If

//Set
li_result = RegistrySet(ls_key, as_value_name, as_value)
If li_result <> 1 Then Return false

Return true
end function

public subroutine set_app ();String ls_app_name, ls_app_path
ulong lu_buf

//Get app_path
lu_buf = 144
ls_app_path = space(144)
GetCurrentDirectoryA(lu_buf, ls_app_path)


end subroutine

on u_registry.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_registry.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

