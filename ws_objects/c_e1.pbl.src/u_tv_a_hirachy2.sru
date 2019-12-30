$PBExportHeader$u_tv_a_hirachy2.sru
$PBExportComments$(csh) Ancestor of Hirachical Treeview( from u_tv_base )
forward
global type u_tv_a_hirachy2 from u_tv_base
end type
end forward

global type u_tv_a_hirachy2 from u_tv_base
integer width = 905
string facename = "Arial"
string picturename[] = {"Custom066!","Custom093!","D:\Project\1.파빌\7.0\Class\tv_menu1.bmp","DataWindow!","Preferences!","Custom048!","Custom040!","UserObject!","Query!","ArrangeIcons!","Report5!"}
string statepicturename[] = {"NotFound!"}
long statepicturemaskcolor = 553648127
event ue_consist ( )
event type integer ue_retrieve ( ref datastore adw_source )
end type
global u_tv_a_hirachy2 u_tv_a_hirachy2

type variables
datastore ids_source
Long il_tot_item
string is_root_parent
boolean ib_expand = false
end variables

forward prototypes
private function string uf_get_data (long al_handle)
private function long uf_get_level (long al_handle)
public function integer uf_init (string as_dwobject, string as_root_parent, boolean ab_expand)
private function long uf_add_item (string as_data, string as_label, long al_parent, long al_level)
end prototypes

event ue_consist;call super::ue_consist;dec{0} lc_level, lc_handle
string ls_code , ls_code_name, ls_parent
long ll_count, ll_i

ids_source.setfilter( " code = '"+ is_root_parent + "' " )
ids_source.filter()
if ids_source.RowCount() = 0 Then return
ls_code = ids_source.object.code[1] 
ls_code_name = ids_source.object.code_name[1] 

uf_add_item( ls_code, ls_code_name,  0, 1 )

If ib_expand Then
	expandall( 1 )
End If

end event

private function string uf_get_data (long al_handle);Long				ll_level
string 			ls_data
TreeViewItem	ltvi_item



getitem(  al_handle , ltvi_item )
ls_data = ltvi_item.data




return ls_data

end function

private function long uf_get_level (long al_handle);Long				ll_level
TreeViewItem	ltvi_item



getitem(  al_handle , ltvi_item )
ll_level = ltvi_item.level




return ll_level

end function

public function integer uf_init (string as_dwobject, string as_root_parent, boolean ab_expand);
ids_source = Create datastore
ids_source.dataobject = as_dwobject

if ids_source.settransobject( sqlca ) <> 1 then	return -1

il_tot_item = trigger event ue_retrieve( ids_source )
if il_tot_item < 0 then	return -1

is_root_parent = as_root_parent
ib_expand = ab_expand

POST event ue_consist()

Return 1
end function

private function long uf_add_item (string as_data, string as_label, long al_parent, long al_level);Long				ll_handle
TreeViewItem	ltvi_item

// Add the child item
// al_parent = parent , ll_handle(return) = current inserted item
ltvi_item.data = as_data
ltvi_item.Label = as_label
ltvi_item.PictureIndex = al_level + 1
ltvi_item.SelectedPictureIndex = 1
ltvi_item.Children = true

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
				ids_source.object.code_name[ ll_i ] ,  handle, ll_level )
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

on u_tv_a_hirachy2.create
end on

on u_tv_a_hirachy2.destroy
end on

