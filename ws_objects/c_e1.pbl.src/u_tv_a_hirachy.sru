$PBExportHeader$u_tv_a_hirachy.sru
$PBExportComments$(csh) Ancestor of Hirachical Treeview( from u_tv_base )
forward
global type u_tv_a_hirachy from u_tv_base
end type
end forward

global type u_tv_a_hirachy from u_tv_base
integer width = 914
integer height = 1204
integer textsize = -9
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string picturename[] = {"tv_menuopen.gif","tv_menu.gif","tv_submenu.gif","tv_reg.gif","tv_view.gif","tv_print.gif","tv_prc.gif"}
string statepicturename[] = {"NotFound!"}
event ue_consist ( )
end type
global u_tv_a_hirachy u_tv_a_hirachy

type variables
datastore ids_source
Long il_tot_item
string is_root_parent
boolean ib_expand = false
end variables

forward prototypes
public function integer uf_init (string as_dwobject, string as_root_parent, boolean ab_expand)
protected function string uf_get_data (long al_handle)
protected function long uf_get_level (long al_handle)
protected function long uf_add_item (string as_data, string as_label, long al_parent, long al_level, string as_type)
protected function long uf_add_item (string as_data, string as_label, long al_parent, long al_level, boolean ab_is_children, string as_type)
end prototypes

event ue_consist();dec{0} lc_level, lc_handle
string ls_code , ls_code_name, ls_parent, ls_type
long ll_count, ll_i

ids_source.setfilter( " code = '"+ is_root_parent + "' " )
ids_source.filter()
ls_code      = ids_source.object.code[1] 
ls_code_name = ids_source.object.code_name[1] 
ls_type      = ids_source.Object.pgm_type[1]
uf_add_item( ls_code, ls_code_name, 0, 1, ls_type)

if ib_expand then
	expandall( 1 )
end if	


//PictureWidth = 1
//StatePictureWidth = 1
//PictureHeight = 1
//StatePictureHeight = 1
//HasLines = False
//
//HasButtons = False
end event

public function integer uf_init (string as_dwobject, string as_root_parent, boolean ab_expand);
ids_source = Create datastore
ids_source.DataObject = as_dwobject

if ids_source.SetTransObject( Sqlca ) <> 1 then	return -1

il_tot_item = ids_source.retrieve() 
if il_tot_item < 0 then	return -1

is_root_parent = as_root_parent
ib_expand = ab_expand

POST Event ue_consist()

Return 1
end function

protected function string uf_get_data (long al_handle);Long				ll_level
string 			ls_data
TreeViewItem	ltvi_item



getitem(  al_handle , ltvi_item )
ls_data = ltvi_item.data




return ls_data

end function

protected function long uf_get_level (long al_handle);Long				ll_level
TreeViewItem	ltvi_item



getitem(  al_handle , ltvi_item )
ll_level = ltvi_item.level

return ll_level

end function

protected function long uf_add_item (string as_data, string as_label, long al_parent, long al_level, string as_type);Return uf_add_item(as_data, as_label, al_parent, al_level, True, as_type)
end function

protected function long uf_add_item (string as_data, string as_label, long al_parent, long al_level, boolean ab_is_children, string as_type);Long				ll_handle
TreeViewItem	ltvi_item

// Add the child item
// al_parent = parent , ll_handle(return) = current inserted item
ltvi_item.data = as_data
ltvi_item.Label = as_label
ltvi_item.PictureIndex = al_level + 1
//ltvi_item.PictureIndex = 0
ltvi_item.SelectedPictureIndex = 1
//ltvi_item.SelectedPictureIndex = 0
ltvi_item.Children = ab_is_children

//MessageBox("프로그램 타입",as_type)

Choose case as_type
	case 'R' 
		      ltvi_item.PictureIndex = 4
	case 'I'						
		      ltvi_item.PictureIndex = 5
	case 'P'			
		      ltvi_item.PictureIndex = 6
	case 'D'			
		      ltvi_item.PictureIndex = 7
End Choose				

ll_handle = InsertItemLast( al_parent , ltvi_item)

return ll_handle


//atv_1.SelectItem(ll_handle)

end function

event itempopulate;call super::itempopulate;long ll_level, ll_handle
string ls_group_id, ls_group_name, ls_parent, ls_data
long ll_frow, ll_i, ll_ins_handle

ll_level = uf_get_level(  handle ) + 1
ls_data	= uf_get_data(  handle )

ids_source.setfilter( " p_code = '"+ ls_data + "' " )
ids_source.filter()
ids_source.SetSort( " code_seq asc " ) 
ids_source.Sort()

ll_frow = ids_source.rowcount()
FOR ll_i = 1 TO ll_frow 
	ll_ins_handle = uf_add_item(  ids_source.object.code[ ll_i ] , &
				ids_source.object.code_name[ ll_i ] ,  handle, ll_level,ids_source.Object.pgm_type[ll_i] )
//	ids_source.object.item_handle[ ll_i ] 	= ll_ins_handle 					
NEXT
end event

event constructor;call super::constructor;// Tree View Object Using

// call -> tv_?.uf_init( string dataobject, string root's parent, boolean expand )
// making datawindow column -> code, p_code, code_name, code_seq


// datawindow sql sample

//  SELECT CODE,   
//         CODE_NAME,   
//         LEVEL,   
//         CODE_SEQ,   
//         P_CODE   
//FROM CSH_GROUP   
//START WITH CODE = 'G00' /* G00 MEAN ROOT CODE
//CONNECT BY PRIOR CODE = P_CODE
//ORDER BY LEVEL, CODE_SEQ 

end event

event destructor;call super::destructor;destroy ids_source
end event

on u_tv_a_hirachy.create
end on

on u_tv_a_hirachy.destroy
end on

