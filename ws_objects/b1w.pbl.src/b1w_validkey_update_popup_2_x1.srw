$PBExportHeader$b1w_validkey_update_popup_2_x1.srw
$PBExportComments$[parkkh] 선불인증 Key 변경(제너)
forward
global type b1w_validkey_update_popup_2_x1 from w_base
end type
type p_save from u_p_save within b1w_validkey_update_popup_2_x1
end type
type p_close from u_p_close within b1w_validkey_update_popup_2_x1
end type
type dw_detail from u_d_sort within b1w_validkey_update_popup_2_x1
end type
type ln_2 from line within b1w_validkey_update_popup_2_x1
end type
end forward

global type b1w_validkey_update_popup_2_x1 from w_base
integer width = 2706
integer height = 1188
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
global b1w_validkey_update_popup_2_x1 b1w_validkey_update_popup_2_x1

type variables
String  is_pgm_id, is_contractseq, is_itemcod, is_svctype, is_status
String is_svccod, is_Xener_svccod[], is_xener_svc
String is_svctype_post, is_svctype_pre

end variables

event ue_ok();Long ll_row 
String ls_where
//조회

ls_where = " to_char(con.contractseq) = '" + is_contractseq + "'"

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(is_xener_svc)
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_detail.Object.new_fromdt[1] = date(fdt_get_dbserver_now())
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
lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_x1%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = is_itemcod
lu_dbmgr.is_data[2]  = is_contractseq
lu_dbmgr.is_data[3]  = is_svctype
lu_dbmgr.is_data[4]  = is_pgm_id
lu_dbmgr.is_data[5]  = is_xener_svc   	 //제너서비스여부('Y'/'N')
lu_dbmgr.is_data[6]  = is_status

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

on b1w_validkey_update_popup_2_x1.create
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

on b1w_validkey_update_popup_2_x1.destroy
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
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
Long ll_i

f_center_window(b1w_validkey_update_popup_2_x1)

//iu_cust_msg.is_data[1] = ls_itemcod	     //itemcod
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = ls_contractseq      //계약SEQ
//iu_cust_msg.is_data[4] = ls_svctype      //서비스타입
//iu_cust_msg.is_data[5] = is_status       //개통상태 코드
//iu_cust_msg.is_data[6] = ls_svccod       //서비스코드

iu_cust_msg = Message.PowerObjectParm
is_itemcod = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_contractseq = iu_cust_msg.is_data[3]
is_svctype = iu_cust_msg.is_data[4]
is_status = iu_cust_msg.is_data[5]
is_svccod = iu_cust_msg.is_data[6]

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)    //선불서비스타입

is_xener_svc = 'N'
For ll_i = 1  to UpperBound(is_Xener_svccod)
	IF is_svccod = is_Xener_svccod[ll_i] Then
		is_xener_svc = 'Y'
		Exit
	End IF
NEXT	

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	Return
End If

IF is_svctype = is_svctype_post Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_2_x1"
	dw_detail.SetTransObject(SQLCA)
Elseif is_svctype = is_svctype_pre Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_2_pre_x1"
	dw_detail.SetTransObject(SQLCA)	
End If

If is_contractseq <> "" Then
	Post Event ue_ok()
End If
end event

type p_save from u_p_save within b1w_validkey_update_popup_2_x1
integer x = 2007
integer y = 984
boolean originalsize = false
end type

type p_close from u_p_close within b1w_validkey_update_popup_2_x1
integer x = 2350
integer y = 984
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_validkey_update_popup_2_x1
integer x = 23
integer y = 44
integer width = 2610
integer height = 892
integer taborder = 10
string dataobject = "b1dw_validkey_update_popup_2_x1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

event retrieveend;call super::retrieveend;String ls_gkid, ls_auth_method, ls_ip_address, ls_h323id, ls_validkey_loc

Select gkid, auth_method, validitem2, validitem3, validkey_loc
  Into :ls_gkid, :ls_auth_method, :ls_ip_address, :ls_h323id, :ls_validkey_loc
  From validinfo
Where validkey = ( select min(validkey) from validinfo 
					where to_char(contractseq) = :is_contractseq
					  and status = :is_status );

this.object.new_gkid[1] = ls_gkid
this.object.new_authmethod[1] = ls_auth_method
this.object.new_ipaddress[1] = ls_ip_address
this.object.new_h323id[1] = ls_h323id
this.object.new_validkey_loc[1] = ls_validkey_loc

end event

event itemchanged;call super::itemchanged;If dwo.name = "new_validkey" Then
	This.object.new_vpassword[row] = data
End If
end event

type ln_2 from line within b1w_validkey_update_popup_2_x1
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

