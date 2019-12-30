$PBExportHeader$b1w_reg_svc_actprc_batch_cv.srw
$PBExportComments$[chooys] 서비스개통처리(일괄)
forward
global type b1w_reg_svc_actprc_batch_cv from w_a_reg_m
end type
type dw_ext from datawindow within b1w_reg_svc_actprc_batch_cv
end type
end forward

global type b1w_reg_svc_actprc_batch_cv from w_a_reg_m
integer width = 3173
dw_ext dw_ext
end type
global b1w_reg_svc_actprc_batch_cv b1w_reg_svc_actprc_batch_cv

type variables
String is_priceplan	//Price Plan Code

//String is_termstatus[]
String is_termenable[]
String is_term_where

String is_reqterm	//해지 신청 코드
String is_term	 	//해지 코드
String is_requestactive //개통 신청 상태 코드
String is_termstatus //고객 해지 상태
end variables

on b1w_reg_svc_actprc_batch_cv.create
int iCurrent
call super::create
this.dw_ext=create dw_ext
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_ext
end on

on b1w_reg_svc_actprc_batch_cv.destroy
call super::destroy
destroy(this.dw_ext)
end on

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_location, ls_where, ls_orderdt, ls_requestdt, ls_temp, ls_result[]
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno
Date ld_orderdt, ld_requestdt
Long ll_row, ll_cur_row, ll_detail_row
Int li_i

ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_orderdt = String(ld_orderdt, 'yyyymmdd')
ls_requestdt = String(ld_requestdt, 'yyyymmdd')
ls_location = dw_cond.object.location[1]

//Null Check
If IsNull(ls_location) Then ls_location = ""
If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""

If ls_location <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "customerm.location ='" + ls_location + "' " 
End if

If ls_orderdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(svcorder.orderdt, 'YYYYMMDD') <='" + ls_orderdt + "' " 
End if

If ls_requestdt <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "( to_char(svcorder.requestdt, 'YYYYMMDD') <='" + ls_requestdt + "' Or svcorder.requestdt is null )" 
End if

//개통요청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P220", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_where_1 = ""
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then ls_where_1 += " Or "
	ls_where_1 += "svcorder.status = '" + ls_result[li_i] + "'"
Next

If ls_where <> "" Then
	If ls_where_1 <> "" Then ls_where = ls_where + " And ( " + ls_where_1 + " ) "  
Else
	ls_where = ls_where_1
End if
	
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

IF ls_requestdt <> "" THEN
//	dw_ext.object.activedt[1] = dw_cond.object.requestdt[1]
//	dw_ext.object.bil_fromdt[1] = dw_cond.object.requestdt[1]
END IF
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actprc_batch_cv
	Desc.	: 	서비스 일괄개통처리
	Ver.	:	1.0
	Date	: 	2003.07.11
	Programer : Choo Youn Shik(neo)
-------------------------------------------------------------------------*/
Date ld_sysdate
String ls_partner, ls_partnernm

ld_sysdate = Date(fdt_get_dbserver_now())

dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate
dw_detail.SetRowFocusIndicator(Off!)

//Show External Window
dw_ext.SetTransObject(SQLCA)
dw_ext.insertrow(0)
dw_ext.object.activedt[1] = fdt_get_dbserver_now()
dw_ext.object.bil_fromdt[1] = relativedate(ld_sysdate,0)
end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
String ls_activedt, ls_bil_fromdt, ls_sysdt
Boolean lb_check
Long ll_rows , ll_rc
b1u_dbmgr2 lu_dbmgr2

dw_detail.AcceptText()

ls_activedt = string(dw_ext.object.activedt[1],'yyyymmdd')
ls_bil_fromdt = string(dw_ext.object.bil_fromdt[1],'yyyymmdd')
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')

If IsNull(ls_activedt) Then ls_activedt = ""
If ls_activedt = "" Then
	f_msg_usr_err(200, Title, "개통일자")
	dw_ext.SetFocus()
	dw_ext.SetColumn("activedt")
	Return -2
End If

If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If ls_bil_fromdt = "" Then
	f_msg_usr_err(200, Title, "과금시작일")
	dw_ext.SetFocus()
	dw_ext.SetColumn("bil_fromdt")
	Return -2
End If

////// 날짜 체크
If ls_activedt <> "" Then 
	lb_check = fb_chk_stringdate(ls_activedt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'개통일자의 날짜 포맷 오류입니다.")
		dw_ext.SetFocus()
		dw_ext.SetColumn("activedt")
		Return -2
	End If
	
	If ls_activedt < ls_sysdt Then
		f_msg_usr_err(210, Title, "'개통일자는 오늘날짜 이상이여야 합니다.")
		dw_ext.SetFocus()
		dw_ext.SetColumn("activedt")
		Return -1
	End If		
End if

If ls_bil_fromdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_bil_fromdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'과금시작일의 날짜 포맷 오류입니다.")
		dw_ext.SetFocus()
		dw_ext.SetColumn("bil_fromdt")
		Return -2
	End If
	
	If ls_bil_fromdt < ls_activedt Then
		f_msg_usr_err(210, Title, "'과금시작일은 개통일보다 크거나 같아야 합니다.")
		dw_ext.SetFocus()
		dw_ext.SetColumn("bil_fromdt")
		Return -2
	End If		
End if

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_actprc_batch_cv%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = dw_detail
lu_dbmgr2.is_data[1] = ls_activedt
lu_dbmgr2.is_data[2] = ls_bil_fromdt

lu_dbmgr2.uf_prc_db()
ll_rc = lu_dbmgr2.ii_rc

If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy lu_dbmgr2
	Return ll_rc
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy lu_dbmgr2

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
String ls_activedt, ls_bil_fromdt, ls_contractno, ls_contractseq
Long ll_row, i
Int li_rc

Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

li_rc = This.Trigger Event ue_extra_save()

If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"서비스개통처리")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"서비스개통처리")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

ll_row = dw_detail.RowCount()

FOR i=1 TO ll_row
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
NEXT

//재정의
String ls_location
Date ld_orderdt, ld_requestdt

ld_orderdt = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_location = Trim(dw_cond.object.location[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.location[1] = ls_location
Trigger Event ue_ok()


Return 0
end event

event type integer ue_reset();call super::ue_reset;Date ld_sysdate

ld_sysdate = Date(fdt_get_dbserver_now())

dw_cond.object.orderdt[1] = ld_sysdate
dw_cond.object.requestdt[1] = ld_sysdate

dw_ext.object.activedt[1] = ld_sysdate
dw_ext.object.bil_fromdt[1] = relativedate(ld_sysdate,0)

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_svc_actprc_batch_cv
integer y = 40
integer width = 1605
integer height = 204
string dataobject = "b1dw_cnd_reg_svc_actprc_batch"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_svc_actprc_batch_cv
integer x = 1742
end type

type p_close from w_a_reg_m`p_close within b1w_reg_svc_actprc_batch_cv
integer x = 2048
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_svc_actprc_batch_cv
integer x = 27
integer width = 1650
integer height = 256
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_svc_actprc_batch_cv
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_svc_actprc_batch_cv
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_svc_actprc_batch_cv
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_svc_actprc_batch_cv
integer y = 432
integer width = 3067
integer height = 1132
string dataobject = "b1dw_reg_svc_actprc_batch_cv"
end type

type p_reset from w_a_reg_m`p_reset within b1w_reg_svc_actprc_batch_cv
end type

type dw_ext from datawindow within b1w_reg_svc_actprc_batch_cv
integer x = 32
integer y = 280
integer width = 1632
integer height = 120
integer taborder = 11
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_ext_reg_svc_actprc_batch_cv"
boolean livescroll = true
end type

