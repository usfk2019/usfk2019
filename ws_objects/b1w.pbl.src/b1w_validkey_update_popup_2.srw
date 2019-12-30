$PBExportHeader$b1w_validkey_update_popup_2.srw
$PBExportComments$[parkkh] 후불인증 Key 추가
forward
global type b1w_validkey_update_popup_2 from w_base
end type
type p_save from u_p_save within b1w_validkey_update_popup_2
end type
type p_close from u_p_close within b1w_validkey_update_popup_2
end type
type dw_detail from u_d_sort within b1w_validkey_update_popup_2
end type
type ln_2 from line within b1w_validkey_update_popup_2
end type
end forward

global type b1w_validkey_update_popup_2 from w_base
integer width = 2670
integer height = 1092
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event type integer ue_save ( )
p_save p_save
p_close p_close
dw_detail dw_detail
ln_2 ln_2
end type
global b1w_validkey_update_popup_2 b1w_validkey_update_popup_2

type variables
String  is_pgm_id, is_contractseq, is_itemcod, is_svctype, is_status
String is_svctype_post, is_svctype_pre

end variables

event ue_ok();Long ll_row 
String ls_where
//조회

ls_where = " to_char(con.contractseq) = '" + is_contractseq + "'"


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_detail.Object.new_fromdt[1] =date(fdt_get_dbserver_now())
end event

event ue_close;Close(This)
end event

event type integer ue_save();Long ll_row
Integer li_rc
b1u_dbmgr4 	lu_dbmgr

ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0


//저장
lu_dbmgr = Create b1u_dbmgr4
lu_dbmgr.is_caller = "b1w_validkey_update_popup_2%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = is_itemcod
lu_dbmgr.is_data[2]  = is_contractseq
lu_dbmgr.is_data[3]  = is_svctype
lu_dbmgr.is_data[4]  = is_pgm_id
lu_dbmgr.is_data[5]  = is_status

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	Return -1
End If

Destroy lu_dbmgr

P_save.TriggerEvent("ue_disable")
dw_detail.enabled = False

Return 0
end event

on b1w_validkey_update_popup_2.create
int iCurrent
call super::create
this.p_save=create p_save
this.p_close=create p_close
this.dw_detail=create dw_detail
this.ln_2=create ln_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_save
this.Control[iCurrent+2]=this.p_close
this.Control[iCurrent+3]=this.dw_detail
this.Control[iCurrent+4]=this.ln_2
end on

on b1w_validkey_update_popup_2.destroy
call super::destroy
destroy(this.p_save)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_2
	Desc	: 인증KEY 추가
	Ver	: 	1.0
	Date	: 	2003.02.05
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc

f_center_window(b1w_validkey_update_popup_2)

//iu_cust_msg.is_data[1] = ls_itemcod	     //itemcod
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = ls_contractseq      //계약SEQ
//iu_cust_msg.is_data[4] = ls_svctype      //서비스타입
//iu_cust_msg.is_data[5] = is_status       //개통상태 코드

iu_cust_msg = Message.PowerObjectParm
is_itemcod = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_contractseq = iu_cust_msg.is_data[3]
is_svctype = iu_cust_msg.is_data[4]
is_status = iu_cust_msg.is_data[5]

is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)    //선불서비스타입

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	Return
End If

IF is_svctype = is_svctype_post Then
	dw_detail.dataObject = "b1dw_validkey_update_pop2"
	dw_detail.SetTransObject(SQLCA)
Elseif is_svctype = is_svctype_pre Then
	dw_detail.dataObject = "b1dw_validkey_update_pop2_pre"
	dw_detail.SetTransObject(SQLCA)	
End If

If is_contractseq <> "" Then
	Post Event ue_ok()
End If
end event

type p_save from u_p_save within b1w_validkey_update_popup_2
integer x = 2030
integer y = 880
boolean originalsize = false
end type

type p_close from u_p_close within b1w_validkey_update_popup_2
integer x = 2336
integer y = 880
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_validkey_update_popup_2
integer x = 23
integer y = 24
integer width = 2619
integer height = 824
integer taborder = 10
string dataobject = "b1dw_validkey_update_pop2"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

event itemchanged;call super::itemchanged;If dwo.name = "new_validkey" Then
	This.object.new_vpassword[row] = data
End If
end event

type ln_2 from line within b1w_validkey_update_popup_2
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

