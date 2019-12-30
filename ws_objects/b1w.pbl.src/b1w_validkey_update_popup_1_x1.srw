$PBExportHeader$b1w_validkey_update_popup_1_x1.srw
$PBExportComments$[parkkh] 후불인증 Key 변경(제너)
forward
global type b1w_validkey_update_popup_1_x1 from w_base
end type
type p_save from u_p_save within b1w_validkey_update_popup_1_x1
end type
type p_close from u_p_close within b1w_validkey_update_popup_1_x1
end type
type dw_detail from u_d_sort within b1w_validkey_update_popup_1_x1
end type
type ln_2 from line within b1w_validkey_update_popup_1_x1
end type
end forward

global type b1w_validkey_update_popup_1_x1 from w_base
integer width = 2834
integer height = 1700
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
global b1w_validkey_update_popup_1_x1 b1w_validkey_update_popup_1_x1

type variables
String is_validkey, is_pgm_id, is_fromdt
String is_svccod, is_Xener_svccod[], is_xener_svc
String is_svctype_post, is_svctype_pre, is_svctype
end variables

event ue_ok();Long ll_row 
String ls_where
//조회

ls_where = " validkey = '" + is_validkey + "' AND  to_char(fromdt,'yyyymmdd') = '" + is_fromdt + "' " + &
           " AND svctype = '" + is_svctype +"'"
	
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(is_xener_svc)
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
	
End If

dw_detail.Object.new_fromdt[1] = RelativeDate(date(fdt_get_dbserver_now()),1)
end event

event ue_close;Close(This)
end event

event type integer ue_save();Long ll_row
Integer li_rc
b1u_dbmgr4 	lu_dbmgr
String ls_contractseq  //2005.04.18 juede add 인증키 날짜 확인변경

ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0

ls_contractseq = String(dw_detail.object.contractseq[1]) //2005.04.18 juede add


//저장
lu_dbmgr = Create b1u_dbmgr4
lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_x1%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = is_fromdt
lu_dbmgr.is_data[2]  = is_validkey
lu_dbmgr.is_data[3]  = is_pgm_id
lu_dbmgr.is_data[4]  = is_xener_svc         //제너서비스여부
lu_dbmgr.is_data[5]  = ls_contractseq       //2005.04.18 juede add

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

on b1w_validkey_update_popup_1_x1.create
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

on b1w_validkey_update_popup_1_x1.destroy
call super::destroy
destroy(this.p_save)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_1
	Desc	: 인증KEY 추가
	Ver	: 	1.0
	Date	: 	2003.02.05
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
long ll_i

f_center_window(b1w_validkey_update_popup_1_x1)
is_validkey = ""
is_fromdt = ""

//iu_cust_msg.is_data[1] = ls_validkey	     //validkey
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = is_fromdt           //fromdt
//iu_cust_msg.is_data[4] = ls_svccod           //svccod
//iu_cust_msg.is_data[5] = ls_svctype          //svctype

iu_cust_msg = Message.PowerObjectParm
is_validkey = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]
is_svccod = iu_cust_msg.is_data[4]
is_svctype = iu_cust_msg.is_data[5]

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)    //선불서비스타입

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	Return
End If

IF is_svctype = is_svctype_post Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_1_x1"
	dw_detail.SetTransObject(SQLCA)
Elseif is_svctype = is_svctype_pre Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_1_pre_x1"
	dw_detail.SetTransObject(SQLCA)	
End If

is_xener_svc = 'N'
For ll_i = 1  to UpperBound(is_Xener_svccod)
	IF is_svccod = is_Xener_svccod[ll_i] Then
		is_xener_svc = 'Y'
		Exit
	End IF
NEXT	

If is_validkey <> "" Then
	Post Event ue_ok()
End If
end event

type p_save from u_p_save within b1w_validkey_update_popup_1_x1
integer x = 2190
integer y = 1408
boolean originalsize = false
end type

type p_close from u_p_close within b1w_validkey_update_popup_1_x1
integer x = 2501
integer y = 1408
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_validkey_update_popup_1_x1
integer x = 23
integer y = 28
integer width = 2766
integer height = 1328
integer taborder = 10
string dataobject = "b1dw_validkey_update_popup_1_x1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

event itemchanged;call super::itemchanged;If dwo.name = "new_validkey" Then
	This.object.new_vpassword[row] = data
End If
end event

type ln_2 from line within b1w_validkey_update_popup_1_x1
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

