$PBExportHeader$b8w_req_sn_move.srw
$PBExportComments$[parkkh] 대리점 S/N 할당
forward
global type b8w_req_sn_move from w_a_reg_m_m
end type
end forward

global type b8w_req_sn_move from w_a_reg_m_m
integer width = 2917
integer height = 1712
end type
global b8w_req_sn_move b8w_req_sn_move

type variables
boolean ib_new

end variables

on b8w_req_sn_move.create
call super::create
end on

on b8w_req_sn_move.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b8w_reg_sn_move
	Desc.	: 	대리점S/N할당
	Ver.	:	1.0
	Date	: 	2002.11.29
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/
Date ld_sysdate
String ls_partner, ls_partnernm

ld_sysdate = Date(fdt_get_dbserver_now())

dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetFocus()
dw_cond.SetColumn("requestdt")

ib_new = FALSE

end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_where, ls_requestdt, ls_temp, ls_result[], ls_new
String ls_ref_desc, ls_where_1, ls_detail_where, ls_orderno, ls_move_request
Date ld_requestdt
Long ll_row, ll_cur_row, ll_detail_row
Int li_i

dw_cond.AcceptText()
ld_requestdt = dw_cond.object.requestdt[1]
ls_requestdt = String(ld_requestdt, 'yyyymmdd')
ls_new  = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then ib_new = True

//신규 등록 
If ib_new = True Then
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
   TriggerEvent("ue_insert")	
	Return
Else
	//Null Check
	If IsNull(ls_requestdt) Then ls_requestdt = ""
	
	If ls_requestdt = "" Then
		f_msg_usr_err(200, title, "S/N 요청일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("requestdt")
		Return 
	End If
	
	If ls_requestdt <> "" Then
	  If ls_where <> "" Then ls_where += " And "  
	  ls_where += "to_char(requestdt, 'YYYYMMDD') <='" + ls_requestdt + "'" 
	End if
	
	//이동요청 상태코드
	ls_ref_desc = ""
	ls_move_request = fs_get_control("E1","A520", ls_ref_desc)
	
	If ls_move_request <> "" Then
	  If ls_where <> "" Then ls_where += " And "  
	  ls_where += "reqstat = '" + ls_move_request + "'" 
	End if
	
	If ls_where <> "" Then ls_where += " And "  
	ls_where += "to_partner = '" + gs_user_group + "'"
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then 
		f_msg_info(1000, Title, "")
		Return
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		 Return
	End If
End if
end event

event type integer ue_reset();call super::ue_reset;//초기화
Date ld_sysdate

dw_cond.SetRedraw(false)
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
ib_new = False

ld_sysdate = Date(fdt_get_dbserver_now())
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetFocus()
dw_cond.SetColumn("requestdt")
dw_cond.SetRedraw(true)

Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_requestdt, ls_serialfrom, ls_serialto, ls_remark, ls_oqman
String ls_modelno, ls_fr_partner, ls_requestno
Boolean lb_check
Long ll_rows, ll_rc
b8u_dbmgr lu_dbmgr

dw_detail.AcceptText()

ls_requestdt = string(dw_detail.object.requestdt[1],'yyyymmdd')
ls_serialfrom = Trim(dw_detail.object.serialfrom[1])
ls_serialto = trim(dw_detail.object.serialto[1])
ls_remark = trim(dw_detail.object.remark[1])
ls_oqman = trim(dw_detail.object.oqman[1])
ls_modelno = trim(dw_detail.object.modelno[1])
ls_fr_partner = trim(dw_detail.object.fr_partner[1])

If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_serialfrom) Then ls_serialfrom = ""
If IsNull(ls_serialto) Then ls_serialto = ""
If IsNull(ls_remark) Then ls_remark = ""
If IsNull(ls_oqman) Then ls_oqman = ""
If IsNull(ls_modelno) Then ls_modelno = ""
If IsNull(ls_fr_partner) Then ls_fr_partner = ""

If ib_new = True Then		//신규
	If ls_modelno = "" Then
		f_msg_usr_err(200, Title, "모 델")
		dw_detail.SetFocus()
		dw_detail.SetColumn("modelno")
		Return -2
	End If
	
	If ls_fr_partner = "" Then
		f_msg_usr_err(200, Title, "S/N할당대리점")
		dw_detail.SetFocus()
		dw_detail.SetColumn("fr_partner")
		Return -2
	End If
Else
	ls_requestno = String(dw_detail.object.requestno[1])		
End if

If ls_requestdt = "" Then
	f_msg_usr_err(200, Title, "할당일자")
	dw_detail.SetFocus()
	dw_detail.SetColumn("requestdt")
	Return -2
End If

If ls_serialfrom = "" Then
	f_msg_usr_err(200, Title, "Serial No.(From)")
	dw_detail.SetFocus()
	dw_detail.SetColumn("serialfrom")
	Return -2
End If

If ls_serialto = "" Then
	dw_detail.object.serialto[1] = ls_serialfrom
//	f_msg_usr_err(200, Title, "Serial No.(To)")
//	dw_detail.SetFocus()
//	dw_detail.SetColumn("serialto")
//	Return -2
End If

If ls_serialfrom > ls_serialto Then
	f_msg_usr_err(200, Title, "Serial No.(From)이 Serial No.(To)보다 큽니다.")
	dw_detail.SetFocus()
	dw_detail.SetColumn("serialFrom")
	Return -2
End if	
	
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

lu_dbmgr = CREATE b8u_dbmgr

lu_dbmgr.is_caller = "b8w_reg_sn_move%save"
lu_dbmgr.is_title  = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = ls_requestdt      //할당일자
lu_dbmgr.is_data[2] = ls_serialfrom     //Serial No. (From)
lu_dbmgr.is_data[3] = ls_serialto		 //Serial No. (To)
lu_dbmgr.is_data[4] = ls_remark			 //비 고
lu_dbmgr.is_data[5] = ls_oqman			 //담당자
lu_dbmgr.is_data[6] = ls_modelno		    //모델
lu_dbmgr.is_data[7] = ls_fr_partner		 //할당대리점
lu_dbmgr.ib_data[1] = ib_new	          //무요청S/N할당...
lu_dbmgr.is_data[8] = ls_requestno		 //요청번호

lu_dbmgr.uf_prc_db()
ll_rc = lu_dbmgr.ii_rc

If ll_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)		
	Destroy lu_dbmgr
	Return ll_rc
End If

Destroy lu_dbmgr

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
String ls_activedt, ls_bil_fromdt, ls_contractno, ls_contractseq
Long ll_row
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
	f_msg_info(3010,This.Title,"대리점S/N할당")
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
	f_msg_info(3000,This.Title,"대리점S/N할당")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//재정의
Date ld_requestdt

ld_requestdt = dw_cond.object.requestdt[1]

//Reset
Trigger Event ue_reset()
dw_cond.object.requestdt[1] = ld_requestdt
Trigger Event ue_ok()

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.object.modelno.Protect = 0
dw_detail.Object.fr_partner.Protect = 0
dw_detail.Object.modelno.Background.Color = RGB(108, 147, 137)
dw_detail.Object.modelno.Color = RGB(255, 255, 255)		
dw_detail.Object.fr_partner.Background.Color = RGB(108, 147, 137)
dw_detail.Object.fr_partner.Color = RGB(255, 255, 255)
dw_detail.Object.requestdt[1] = fdt_get_dbserver_now()

return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b8w_req_sn_move
integer x = 55
integer y = 40
integer width = 1778
integer height = 144
string dataobject = "b8dw_cnd_req_sn_move"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b8w_req_sn_move
integer x = 2126
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b8w_req_sn_move
integer x = 2455
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b8w_req_sn_move
integer width = 1970
integer height = 224
end type

type dw_master from w_a_reg_m_m`dw_master within b8w_req_sn_move
integer x = 23
integer y = 260
integer width = 2821
integer height = 628
string dataobject = "b8dw_inq_req_sn_move"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.requestdt_t
uf_init(ldwo_sort, "D", RGB(255,0,0))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b8w_req_sn_move
integer x = 23
integer y = 928
integer width = 2821
integer height = 500
string dataobject = "b8dw_req_sn_move"
boolean vscrollbar = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_requestno
Long ll_row

ls_requestno = String(dw_master.object.requestno[al_select_row])
If IsNull(ls_requestno) Then ls_requestno= ""

If ls_requestno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(requestno) = '" + ls_requestno+ "'"
End If

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

this.object.modelno.Protect = 1
this.Object.fr_partner.Protect = 1
this.Object.modelno.Background.Color = RGB(255, 251, 240)
this.Object.modelno.Color = RGB(0, 0, 0)		
this.Object.fr_partner.Background.Color = RGB(255, 251, 240)
this.Object.fr_partner.Color = RGB(0, 0, 0)		

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

dw_detail.SetRedraw(True)

Return 0
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_init();call super::ue_init;String ls_temp, ls_desc, ls_filter
Integer li_exist
DataWindowChild ldc_frpartner

ls_temp = fs_get_control("A1", "C100", ls_desc)

li_exist = This.GetChild("fr_partner", ldc_frpartner)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : S/N할당대리점")
ls_filter = "levelcod = '" + ls_temp  + "' " 
ldc_frpartner.SetTransObject(SQLCA)
li_exist =ldc_frpartner.Retrieve()
ldc_frpartner.SetFilter(ls_filter)			//Filter정함
ldc_frpartner.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return  		//선택 취소 focus는 그곳에
End If  
end event

type p_insert from w_a_reg_m_m`p_insert within b8w_req_sn_move
boolean visible = false
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within b8w_req_sn_move
boolean visible = false
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within b8w_req_sn_move
integer x = 23
integer y = 1464
end type

type p_reset from w_a_reg_m_m`p_reset within b8w_req_sn_move
integer x = 713
integer y = 1464
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b8w_req_sn_move
integer x = 23
integer y = 896
end type

