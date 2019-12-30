$PBExportHeader$p1w_reg_pintopin_v20.srw
$PBExportComments$[ohj] Pin To Pin 충전 v20
forward
global type p1w_reg_pintopin_v20 from w_a_reg_m_m
end type
end forward

global type p1w_reg_pintopin_v20 from w_a_reg_m_m
integer width = 3625
integer height = 2092
end type
global p1w_reg_pintopin_v20 p1w_reg_pintopin_v20

type variables
Dec idc_from_balance
String is_refill_card[]
Integer ii_cnt
end variables

on p1w_reg_pintopin_v20.create
call super::create
end on

on p1w_reg_pintopin_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_pid
String ls_contnofr
String ls_contnoto
String ls_status
String ls_issuedtfr
String ls_issuedtto
String ls_partner
String ls_model
String ls_lotno
String ls_priceplan
String ls_validkey
Long ll_row, i
String ls_where, ls_where_1


ls_pid = Trim(dw_cond.object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contnofr = Trim(dw_cond.object.contno_from[1])
If IsNull(ls_contnofr) Then ls_contnofr = ""

ls_contnoto = Trim(dw_cond.object.contno_to[1])
If IsNull(ls_contnoto) Then ls_contnoto = ""

ls_status = Trim(dw_cond.object.status[1])
If IsNull(ls_status) Then ls_status = ""

ls_issuedtfr = String(dw_cond.object.issuedt_from[1],"YYYYMMDD")
If IsNull(ls_issuedtfr) Then ls_issuedtfr = ""

ls_issuedtto = String(dw_cond.object.issuedt_to[1],"YYYYMMDD")
If IsNull(ls_issuedtto) Then ls_issuedtto = ""

ls_partner = Trim(dw_cond.object.partner[1])
If IsNull(ls_partner) Then ls_partner = ""

ls_model = Trim(dw_cond.object.pricemodel[1])
If IsNull(ls_model) Then ls_model = ""

ls_lotno = Trim(dw_cond.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_priceplan = Trim(dw_cond.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_validkey = Trim(dw_cond.object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""


//충전가능한 상태만.
For i = 1 To ii_cnt
	If ls_where_1 <> "" Then ls_where_1 += " Or " 
	ls_where_1 += "status = '" + is_refill_card[i] + "' "
Next
 

If ls_issuedtfr > ls_issuedtto Then
	f_msg_usr_err(210, Title, "발행일시작 <= 발행일종료")
	dw_cond.SetFocus()
	dw_cond.setColumn("issuedt_from")
	Return 
End If


IF ls_pid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid = '"+ ls_pid +"'"
END IF

IF ls_contnofr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno >= '"+ ls_contnofr +"'"
END IF

IF ls_contnoto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno <= '"+ ls_contnoto +"'"
END IF

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.status = '"+ ls_status +"'"
END IF

IF ls_issuedtfr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') >= '"+ ls_issuedtfr +"'"
END IF

IF ls_issuedtto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') <= '"+ ls_issuedtto +"'"
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.partner_prefix = '"+ ls_partner +"'"
END IF

IF ls_model <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pricemodel = '"+ ls_model +"'"
END IF

IF ls_lotno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.lotno = '"+ ls_lotno +"'"
END IF

IF ls_priceplan <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.priceplan = '"+ ls_priceplan +"'"
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid in (select pid from validinfo where svctype = (select ref_content from sysctl1t where module = 'P0' and ref_no = 'P100') and validkey = '"+ ls_validkey +"')"
END IF

If ls_where = "" Then
	f_msg_info(200, Title, "1가지 이상 조회 조건")
	dw_cond.SetFocus()
	dw_cond.setColumn("pid")
	Return 
End If  

ls_where = "(" + ls_where_1 +") And " + ls_where


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")			
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If

end event

event open;call super::open;String ls_ref_desc, ls_tmp

String ls_filter
Integer i, li_row
DataWindowChild ldw_status

//충전가능상태 코드
ls_tmp = fs_get_control("P0", "P105", ls_ref_desc)	//2;3;4;5;6
ii_cnt = fi_cut_string(ls_tmp, ";", is_refill_card[])	// 판매출고, 사용, 기간만료, 잔액부족, 일시정지


li_row = dw_cond.GetChild("status", ldw_status)
If li_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

For i =1 To ii_cnt
	If ls_filter <> "" Then ls_filter += " Or "
	ls_filter += "code = '" + is_refill_card[i] + "' "
Next


ldw_status.setFilter(ls_filter)
ldw_status.Filter( )
ldw_status.SetTransObject(SQLCA)
li_row =ldw_status.Retrieve() 

If li_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;p1c_dbmgr lu_dbmgr
String ls_from_status, ls_from_pid, ls_from_contno, ls_pid, ls_from_priceplan, ls_priceplan
String ls_currency, ls_from_currency, ls_from_pricemodel, ls_from_partner_prefix
Dec ldc_from_balance
integer i, ll_rc
Boolean lb_ok
lb_ok = False

ls_pid = Trim(dw_detail.object.pid[1])		//충전할 pin번호
ls_from_pid = Trim(dw_detail.object.from_pin[1])	// 충전해줄 pin 번호
ls_priceplan = Trim(dw_detail.object.priceplan[1])	// 가격정책
If IsNull(ls_from_pid) Then ls_from_pid = ""

If ls_from_pid = "" Then	//충전해줄 pin 번호
   f_msg_usr_err(200, title, "Pin #")
	dw_detail.SetFocus()
	dw_detail.SetColumn("from_pin")
	Return -1
Else
	If ls_pid = ls_from_pid Then
		f_msg_usr_err(201, title, "동일한 Pin # 입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("from_pin")
		Return -1
	End If
		
End If

	 Select status, balance, contno, priceplan, pricemodel, partner_prefix
	 Into :ls_from_status, :ldc_from_balance, :ls_from_contno, :ls_from_priceplan,
	      :ls_from_pricemodel, :ls_from_partner_prefix
	 From p_cardmst
	 where pid = :ls_from_pid;	//충전해줄 pin 번호
	 
	 If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(title, " Select Error(p_cardmst)")
			Return -1
	End If
	 
	 
	 For i = 1 To ii_cnt 
		If ls_from_status = is_refill_card[i] Then			//충전할 카드의 상태가 충전가능상태인지 check
			lb_ok = True
			Exit;
		End If
	Next
	
	If lb_ok = False Then
		f_msg_usr_err(9000, title, "Pin# = " + ls_from_pid + " 은 충전할 수 없는 카드입니다.")
		dw_detail.object.from_pin[1] = ls_from_pid	// pin number
		dw_detail.object.from_contno[1] = ls_from_contno	// 관리번호
		dw_detail.object.from_balance[1] = ldc_from_balance	//카드 잔액
		Return -1
	End If
	
	Select currency_type into :ls_currency from priceplanmst where priceplan = :ls_priceplan;		// 가격정책
	Select currency_type into :ls_from_currency from priceplanmst where priceplan = :ls_from_priceplan;	//충전할 카드의 가격정책
	If ls_currency <>  ls_from_currency Then	//통화구분 
		f_msg_usr_err(9000, title, "Pin# = " + ls_from_pid + " 은 화폐유형이 달라 ~r" + &
		             "충전할 수 없는 카드입니다.")
		dw_detail.object.from_pin[1] = ls_from_pid	//pin number
		dw_detail.object.from_contno[1] = ls_from_contno	// 관리번호
		dw_detail.object.from_balance[1] = ldc_from_balance	//카드 잔액
		Return -1
	End If
	
	
	dw_detail.object.from_pin[1] = ls_from_pid
	dw_detail.object.from_contno[1] = ls_from_contno
	dw_detail.object.from_balance[1] = ldc_from_balance
  

lu_dbmgr = CREATE p1c_dbmgr

lu_dbmgr.is_caller = "p1w_reg_pintopin%save"
lu_dbmgr.is_title  = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = ls_from_pricemodel
lu_dbmgr.is_data[2] = ls_from_partner_prefix
lu_dbmgr.is_data[3] = ls_from_priceplan

lu_dbmgr.uf_prc_db_01()
ll_rc = lu_dbmgr.ii_rc

If ll_rc < 0 Then
	Destroy lu_dbmgr
	Return ll_rc
End If




Return 0 

end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Rollback;
	Return LI_ERROR
End if

If  dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
End if

//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within p1w_reg_pintopin_v20
integer width = 2647
integer height = 376
string dataobject = "p1dw_cnd_reg_master_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within p1w_reg_pintopin_v20
integer x = 2839
integer y = 64
end type

type p_close from w_a_reg_m_m`p_close within p1w_reg_pintopin_v20
integer x = 3145
integer y = 64
end type

type gb_cond from w_a_reg_m_m`gb_cond within p1w_reg_pintopin_v20
integer width = 2688
integer height = 444
end type

type dw_master from w_a_reg_m_m`dw_master within p1w_reg_pintopin_v20
integer y = 456
integer width = 3534
integer height = 480
string dataobject = "p1dw_mst_reg_master_v20"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)

end event

type dw_detail from w_a_reg_m_m`dw_detail within p1w_reg_pintopin_v20
integer y = 968
integer width = 3538
string dataobject = "p1dw_reg_pintopin_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//////////////////////////////////////////////////////////////////////////////////
//	  수정내용 : dw_master의 선택된 row의 pid에 대해 dw_detail을 조회하는데, 
//					 dw_detail의 where절의 pid에 대해 single quotation 마크가 없어서 
//					 pid를 숫자로 인식하여, 조회할때 마다 sqlerrtext가 나타났음.
//
//   작 성 일 : 2004.08.07
//
//	  작 성 자 : 권 정 민
//
//////////////////////////////////////////////////////////////////////////////////

String ls_where, ls_pin
Long ll_row
dec ldc_ref_contractseq

ls_pin = String(dw_master.object.pid[al_select_row])
If IsNull(ls_pin) Then ls_pin = ""
ls_where = ""
If ls_pin <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "pid = '" + ls_pin + "'"
End If

//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.from_pin
This.is_help_win[1] = "p1w_hlp_p_cardmst"
This.is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;String ls_from_status, ls_from_pin, ls_from_contno, ls_pid
Integer i
Boolean ib_ok
ib_ok = False

If dwo.name = "from_pin" Then
	
		If This.iu_cust_help.ib_data[1] Then
			 ls_from_pin = This.iu_cust_help.is_data[1]
			 ls_from_status = This.iu_cust_help.is_data[2]
			 idc_from_balance = Dec(This.iu_cust_help.is_data[3])
			 ls_from_contno = This.iu_cust_help.is_data[4]
			 
			 
			 //카드 상태 확인
			 For i = 1 To ii_cnt 
			   If ls_from_status = is_refill_card[i] Then
			      ib_ok = True
					Exit;
				End If
			Next
			
			If ib_ok = False Then
				f_msg_usr_err(9000, title, "Pin : " + ls_from_pin + " 으로 충전할 수 없는 카드입니다.")
				Return 0
			End If
			
			ls_pid = Trim(dw_detail.object.pid[1])
			If ls_from_pin = ls_pid Then
			 f_msg_usr_err(201, title, "동일한 Pin # 입니다.")
			 Return 0
		   End If
			
			This.object.from_pin[1] = ls_from_pin
			this.object.from_balance[1] = idc_from_balance
			This.object.from_contno[1] = ls_from_contno
		End If

End If
Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_from_status, ls_from_contno
Dec ldc_from_balance
integer i
Boolean lb_ok

If dwo.name  = "from_pin" Then
	 Select status, balance, contno
	 Into :ls_from_status, :ldc_from_balance, :ls_from_contno
	 From p_cardmst
	 where pid = :data;
	 
	 
	 If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(title, " Select Error(p_cardmst)")
		End If
	 
//	 For i = 1 To ii_cnt 
//		If ls_from_status = is_refill_card[1] Then
//			lb_ok = True
//			Exit;
//		End If
//	Next
//	
//	If lb_ok = False Then
//		f_msg_usr_err(9000, title, "Pin# = " + data + " 은 충전할 수 없는 카드입니다.")
//		Return -1
//	End If
	
	This.object.from_pin[1] = data
	This.object.from_balance[1] = ldc_from_balance
	This.object.from_contno[1] = ls_from_contno
End If
Return 0
	 
	 
end event

type p_insert from w_a_reg_m_m`p_insert within p1w_reg_pintopin_v20
boolean visible = false
integer y = 1844
end type

type p_delete from w_a_reg_m_m`p_delete within p1w_reg_pintopin_v20
boolean visible = false
integer y = 1848
end type

type p_save from w_a_reg_m_m`p_save within p1w_reg_pintopin_v20
integer x = 73
integer y = 1856
end type

type p_reset from w_a_reg_m_m`p_reset within p1w_reg_pintopin_v20
integer x = 443
integer y = 1856
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within p1w_reg_pintopin_v20
integer y = 936
end type

