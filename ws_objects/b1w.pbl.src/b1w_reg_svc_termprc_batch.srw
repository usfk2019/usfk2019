$PBExportHeader$b1w_reg_svc_termprc_batch.srw
$PBExportComments$[chooys] 서비스해지처리(일괄)
forward
global type b1w_reg_svc_termprc_batch from w_a_reg_m
end type
type dw_ext from datawindow within b1w_reg_svc_termprc_batch
end type
end forward

global type b1w_reg_svc_termprc_batch from w_a_reg_m
dw_ext dw_ext
end type
global b1w_reg_svc_termprc_batch b1w_reg_svc_termprc_batch

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

on b1w_reg_svc_termprc_batch.create
int iCurrent
call super::create
this.dw_ext=create dw_ext
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_ext
end on

on b1w_reg_svc_termprc_batch.destroy
call super::destroy
destroy(this.dw_ext)
end on

event ue_ok();call super::ue_ok;String ls_payid
String ls_location
String ls_orderdt
String ls_requestdt

String ls_where
Long ll_row


ls_payid = Trim(dw_cond.object.payid[1])
ls_location = Trim(dw_cond.object.location[1])
ls_orderdt = String(dw_cond.object.orderdt[1], 'yyyymmdd')
ls_requestdt = String(dw_cond.object.requestdt[1], 'yyyymmdd')

//Null Check
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_location) Then ls_location = ""
If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""


IF ls_payid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.payid = '" + ls_payid + "' "
End If

IF ls_location <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cus.location = '" + ls_location + "' "
End If

IF ls_orderdt <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(odr.orderdt,'YYYYMMDD') <= '" + ls_orderdt + "' "
End If

IF ls_requestdt <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(odr.requestdt,'YYYYMMDD') <= '" + ls_requestdt + "' "
End If


//해지신청가능 상태코드: open에서 instance 변수에 담음...<=해지신청 가능한 것만 select함!
If ls_where <> "" Then
	If is_term_where <> "" Then ls_where = ls_where + " And  " + is_term_where + "  "  
Else
	ls_where = is_term_where
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

end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_termprc_batch
	Desc.	: 	서비스 해지 Batch
	Ver.	:	1.0
	Date	: 	2003.07.11
	Programer : Choo Youn Shik(neo)
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp
long li_i
String ls_termstatus[]
String ls_partnernm, ls_status, ls_name[]
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())


is_requestactive = ""
is_reqterm = ""
is_term = ""
is_termstatus = ""
//수행처 Default
//Select partnernm
//Into :ls_partnernm
//From partnermst 
//Where partner = :gs_user_group
//AND act_yn = 'Y';
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If

//dw_cond.Object.partner[1] = gs_user_group
//dw_cond.Object.partnernm[1] = gs_user_group

//해지신청 상태코드 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_reqterm = ls_name[1]
is_term	 = ls_name[2]

is_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
is_termstatus = fs_get_control("B0", "P201", ls_ref_desc)


//해지신청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P221", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_termstatus[])
End if


//무조건 해지신청만 select하므로... 계속 쓰인다..
is_term_where = ""
is_term_where += "odr.status = '" + ls_termstatus[1] + "'" //해지신청


is_term_where = "( " + is_term_where + " ) " 

dw_detail.SetRowFocusIndicator(Off!)


//Show External Window
dw_ext.SetTransObject(SQLCA)
dw_ext.insertrow(0)
dw_ext.object.termdt[1] = fdt_get_dbserver_now()
dw_ext.object.enddt[1] = relativedate(date(fdt_get_dbserver_now()),-1)


end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
String ls_termdt, ls_partner, ls_termtype, ls_contractseq, ls_sysdt, ls_activedt, ls_prm_check
String ls_act_status, ls_ref_desc
Boolean lb_check
Long ll_rows , ll_rc, ll_svccnt
DateTime ldt_termdt
Long ll_cnt
String ls_act_gu
String ls_enddt

dw_ext.AcceptText()

ls_termdt = String(dw_ext.object.termdt[1],"YYYYMMDD")
ls_prm_check = Trim(dw_ext.object.prm_check[1])
ls_enddt = String(dw_ext.object.enddt[1],"YYYYMMDD")
ls_termtype = Trim(dw_ext.object.termtype[1])

//Null Check
If IsNull(ls_termdt) Then ls_termdt = ""
If IsNull(ls_enddt) Then ls_enddt = ""
If IsNull(ls_termtype) Then ls_termtype = ""


	IF ls_termdt = "" THEN
		f_msg_usr_err(200, Title, "해지일")
		dw_ext.SetFocus()
		dw_ext.SetColumn("termdt")
		Return -2
	END IF
	
	IF ls_enddt = "" THEN
		f_msg_usr_err(200, Title, "과금종료일")
		dw_ext.SetFocus()
		dw_ext.SetColumn("enddt")
		Return -2
	END IF


	If ls_termtype = "" Then
		f_msg_usr_err(200, Title, "해지사유")
		dw_ext.SetFocus()
		dw_ext.SetColumn("termtype")
		Return -2
	End If
	
		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
	
		If ls_termdt < ls_sysdt Then
			f_msg_usr_err(200, Title, "해지요청일은 오늘날짜 이상이여야 합니다.")
			dw_ext.SetFocus()
			dw_ext.SetColumn("termdt")
			Return -2
		End If		
	

		
		If ls_termdt < ls_enddt Then
			f_msg_usr_err(200, Title, "'과금종료일은 해지일 이전이어야 합니다.")
			dw_ext.SetFocus()
			dw_ext.SetColumn("termdt")
			Return -2
		End If
		

	ll_rows = dw_detail.RowCount()
	If ll_rows = 0 Then Return 0
	

	FOR ll_cnt=1 TO ll_rows

		ls_activedt = String(dw_detail.object.contractmst_activedt[ll_cnt],"YYYYMMDD")

			If ls_termdt <= ls_activedt Then
				f_msg_usr_err(210, Title, "'해지요청일은 개통일보다 커야 합니다.")
				dw_ext.SetFocus()
				dw_ext.SetColumn("termdt")
				Return -2
			End If
			
			If ls_enddt <= ls_activedt Then
				f_msg_usr_err(210, Title, "'과금종료일은 개통일보다 커야 합니다.")
				dw_ext.SetFocus()
				dw_ext.SetColumn("enddt")
				Return -2
			End If
		
		//	//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
		//	Select count(*)
		//	  Into :ll_svccnt
		//	  from validinfo
		//	 Where to_char(fromdt,'yyyymmdd') >= :ls_termdt
		//	   and to_char(contractseq) = :ls_contractseq
		//	   and status = :ls_act_status;	
		//	   
		//	If SQLCA.SQLCode < 0 Then
		//		f_msg_sql_err(title, " Select count Error(validinfo)")
		//		Return  -2
		//	End If
		//	
		//	If ll_svccnt > 0 Then
		//		f_msg_usr_err(210, Title, "해지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
		//		dw_detail.SetFocus()
		//		dw_detail.SetColumn("termdt")
		//		Return -2
		//	End If
	NEXT


b1u_dbmgr 	lu_dbmgr
Integer li_rc
lu_dbmgr = Create b1u_dbmgr

lu_dbmgr.is_caller = "b1w_reg_svc_termprc_batch%save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_reqterm
lu_dbmgr.is_data[2] = is_term
lu_dbmgr.is_data[3] = gs_user_group
lu_dbmgr.is_data[4] = is_requestactive
lu_dbmgr.is_data[5] = is_termstatus
lu_dbmgr.is_data[6] = gs_user_id
lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[8] = ls_termdt
lu_dbmgr.is_data[9] = ls_enddt
lu_dbmgr.is_data[10] = ls_termtype
lu_dbmgr.is_data[11] = ls_prm_check
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.idw_data[2] = dw_ext
lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc


dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

If li_rc < 0 Then	
	Destroy lu_dbmgr
	Return li_rc
End If

Destroy lu_dbmgr

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
Constant Int LI_ERROR = -1

Date ld_orderdt, ld_requestdt
String ls_location

String ls_activedt, ls_bil_fromdt
String ls_customerid, ls_payid, ls_contractseq, ls_validkey , ls_contractno
Long ll_row, li_chk, i
Integer li_rc

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

li_chk =  f_msg_ques_yesno2(9000, Title, "[확인Message] 해지처리 하시겠습니까?!", 1)

If li_chk = 1 Then		//Yes

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
		f_msg_info(3010,This.Title,"해지처리")
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
		f_msg_info(3000,This.Title,"해지처리")
	ElseIF li_rc = -2 Then
		Return LI_ERROR
	End if
	
//	p_save.TriggerEvent("ue_disable")
End If

ll_row = dw_detail.RowCount()

FOR i=1 TO ll_row
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
NEXT

//다시 Reset

ls_payid = Trim(dw_cond.object.payid[1])
ls_location = Trim(dw_cond.object.location[1])
ld_orderdt =dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]

Trigger Event ue_reset()
dw_cond.object.payid[1] = ls_payid
dw_cond.object.location[1] = ls_location
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt

Trigger Event ue_ok()

Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_svc_termprc_batch
integer y = 40
integer width = 2309
integer height = 204
string dataobject = "b1dw_cnd_reg_svc_termprc_batch"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "payid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.payid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.paynm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.payid
This.is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_svc_termprc_batch
end type

type p_close from w_a_reg_m`p_close within b1w_reg_svc_termprc_batch
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_svc_termprc_batch
integer x = 18
integer width = 2368
integer height = 256
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_svc_termprc_batch
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_svc_termprc_batch
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_svc_termprc_batch
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_svc_termprc_batch
integer y = 516
integer height = 1048
string dataobject = "b1dw_mst_reg_svc_termprc_batch"
end type

type p_reset from w_a_reg_m`p_reset within b1w_reg_svc_termprc_batch
end type

type dw_ext from datawindow within b1w_reg_svc_termprc_batch
integer x = 32
integer y = 280
integer width = 3003
integer height = 204
integer taborder = 11
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_ext_reg_svc_termprc_batch"
boolean livescroll = true
end type

