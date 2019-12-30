$PBExportHeader$b1w_validkey_update_popup_3_1.srw
$PBExportComments$[ceusee] 인증 Key 해지(X1)
forward
global type b1w_validkey_update_popup_3_1 from w_base
end type
type p_save from u_p_save within b1w_validkey_update_popup_3_1
end type
type p_close from u_p_close within b1w_validkey_update_popup_3_1
end type
type dw_detail from u_d_sort within b1w_validkey_update_popup_3_1
end type
type ln_2 from line within b1w_validkey_update_popup_3_1
end type
end forward

global type b1w_validkey_update_popup_3_1 from w_base
integer width = 3145
integer height = 1124
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
global b1w_validkey_update_popup_3_1 b1w_validkey_update_popup_3_1

type variables
String is_validkey, is_pgm_id, is_fromdt, is_contractseq, is_svctype
int ii_validkeytype_cnt
end variables

event ue_ok();Long ll_row 
String ls_where
//조회

ls_where = " v.validkey = '" + is_validkey + "' AND  to_char(v.fromdt,'yyyymmdd') = '" + is_fromdt + "'" + &
		   " AND to_char(v.contractseq) = '" + is_contractseq + "' and v.svctype = '" + is_svctype + "' " 
	 
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If


dw_detail.Object.todt[1] = RelativeDate(date(fdt_get_dbserver_now()),1)

end event

event ue_close;Close(This)
end event

event type integer ue_save();String ls_todt , ls_ref_cont, ls_status, ls_name[], ls_term
String ls_sysdt, ls_fromdt
Integer li_rc
u_cust_db_app   iu_cust_db_app

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

iu_cust_db_app = Create u_cust_db_app

ls_sysdt = String(fdt_get_dbserver_now(), 'yyyymmdd')
//해지신청 상태코드 가져오기
ls_status = fs_get_control("B0", "P221", ls_ref_cont)
fi_cut_string(ls_status, ";", ls_name[])		
ls_term	 = ls_name[2]

ls_todt = String(dw_detail.object.todt[1], 'yyyymmdd')
ls_fromdt = String(dw_detail.object.fromdt[1], 'yyyymmdd')
If IsNull(ls_todt) Then ls_todt = ""
If ls_todt = "" Then
	f_msg_usr_err(210, title, "적용종료일")
	dw_detail.Setfocus()
	dw_detail.SetColumn("todt")
	Return -1
End If

If ls_todt <= ls_fromdt Then
	f_msg_usr_err(210, Title, "적용종료일은 적용시작일보다 커야합니다.")								 								 								 
	dw_detail.Setfocus()
	dw_detail.SetColumn("todt")
	Return -1
End If

//오늘 날짜 이상부터 해지가 가능하다.
If ls_todt <= ls_sysdt Then
	f_msg_usr_err(210, Title, "적용종료일은 오늘날짜보다 커야합니다.")								 
	dw_detail.Setfocus()
	dw_detail.SetColumn("todt")
	Return -1
End If

dw_detail.object.status[1] = ls_term
dw_detail.object.use_yn[1] = 'N'

IF ii_validkeytype_cnt > 0 Then

    b1u_dbmgr4 	lu_dbmgr
	//저장
	lu_dbmgr = Create b1u_dbmgr4
	lu_dbmgr.is_caller = "b1w_validkey_update_popup_3_1%ue_save"
	lu_dbmgr.is_title = Title
	lu_dbmgr.idw_data[1] = dw_detail
	lu_dbmgr.is_data[1]  = ls_todt
	lu_dbmgr.is_data[2]  = is_pgm_id
	lu_dbmgr.ii_data[1] = ii_validkeytype_cnt 

	lu_dbmgr.uf_prc_db_05()
	li_rc = lu_dbmgr.ii_rc

	If li_rc = -1 Then
		Destroy lu_dbmgr
		Return -1
	End If

	Destroy lu_dbmgr

End IF

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If

	f_msg_info(3010,This.Title,"Save")
	Return -1
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	
	f_msg_info(3000,This.Title,"Save")
End If

Destroy iu_cust_db_app

P_save.TriggerEvent("ue_disable")
dw_detail.enabled = False

Return 0
end event

on b1w_validkey_update_popup_3_1.create
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

on b1w_validkey_update_popup_3_1.destroy
call super::destroy
destroy(this.p_save)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_3
	Desc	: 인증KEY 해지
	Ver	: 	1.0
	Date	: 	2003.09.25
	Programer : ceusee
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]

f_center_window(b1w_validkey_update_popup_3_1)
is_validkey = ""
is_fromdt = ""

//iu_cust_msg.is_data[1] = ls_validkey	     //validkey
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = is_fromdt           //fromdt

iu_cust_msg = Message.PowerObjectParm
is_validkey = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]
is_contractseq = iu_cust_msg.is_data[4]
is_svctype = iu_cust_msg.is_data[5]

If is_validkey <> "" Then
	Post Event ue_ok()
End If
end event

type p_save from u_p_save within b1w_validkey_update_popup_3_1
integer x = 2510
integer y = 916
boolean originalsize = false
end type

type p_close from u_p_close within b1w_validkey_update_popup_3_1
integer x = 2811
integer y = 916
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_validkey_update_popup_3_1
integer x = 23
integer y = 44
integer width = 3077
integer height = 844
integer taborder = 10
string dataobject = "b1dw_validkey_update_popup_3_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

event retrieveend;call super::retrieveend;String ls_priceplan

dw_detail.object.todt[1] = fd_date_next(Date(fdt_get_dbserver_now()), + 1)

ls_priceplan= This.Object.priceplan[1]
IF IsNull(ls_priceplan) Then ls_priceplan = ""

//validkeytype에 존재 check 
IF b1fi_validkeytype_check(parent.title,ls_priceplan, ii_validkeytype_cnt) > 0 Then
End IF

//인증KEY관리 할당 모듈 사용시 validkeymst Help에 partner조건 추가위함.
//IF is_req_yn= "Y" Then
//	This.is_data[3] = This.Object.contractmst_reg_partner[1]
//Else
//	This.is_data[3] = ''
//End IF

Return 0
end event

type ln_2 from line within b1w_validkey_update_popup_3_1
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

