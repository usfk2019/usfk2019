﻿$PBExportHeader$b1w_reg_customer_d_sc.srw
$PBExportComments$[islim 고객정보 등록- Signcall
forward
global type b1w_reg_customer_d_sc from w_a_reg_m_tm2
end type
type p_view from u_p_view within b1w_reg_customer_d_sc
end type
type p_find from u_p_find within b1w_reg_customer_d_sc
end type
type dw_cond2 from u_d_external within b1w_reg_customer_d_sc
end type
end forward

global type b1w_reg_customer_d_sc from w_a_reg_m_tm2
integer width = 3616
integer height = 2316
event ue_view ( )
event ue_find ( )
p_view p_view
p_find p_find
dw_cond2 dw_cond2
end type
global b1w_reg_customer_d_sc b1w_reg_customer_d_sc

type variables
Boolean ib_new, ib_billing, ib_ctype3
String is_check
String is_method, is_credit, is_inv_method, is_status, is_select_cod
Long il_row
String is_pay_method_ori, is_receiptcod          //결재방법(origin), 신청접수처
String is_drawingtype[], is_drawingresult[]		 //출금이체신청유형, 출금이체신청결과
string is_drawingtype_ori, is_drawingresult_ori  //출금이체신청유형(origin), 출금이체신청결과(origin)
String is_receiptcod_ori, is_resultcod_ori       //신청접수처(origin), 신청결과코드(origin)
String is_bank_ori, is_acctno_ori, is_acct_owner_ori, is_acct_ssno_ori //은행,계좌번호,예금주, 예금주민번호(origin)
datetime id_drawingreqdt_ori, id_receiptdt_ori 	 //이체신청일자(origin), 신청접수일자(origin)
String is_chg_flag                               //pay_method변경flag
String is_bank_chg_ori							       //자동이체 정보 변경(origin)
datetime idt_sysdate
string is_drawingtype_bef, is_drawingresult_bef  //출금이체신청유형(before), 출금이체신청결과(before)
String is_receiptcod_bef, is_resultcod_bef       //신청접수처(before), 신청결과코드(before)
String is_bank_bef, is_acctno_bef, is_acct_owner_bef, is_acct_ssno_bef //은행,계좌번호,예금주, 예금주민번호(before)
datetime id_drawingreqdt_bef, id_receiptdt_bef 	 //이체신청일자(before), 신청접수일자(before)

//Currency_type
String is_currency_old, is_payid_old
//선불제 svctype
String is_svctype_pre

//dw child
DataWindowChild idc_itemcod



end variables

forward prototypes
public function integer wfi_get_payid (string as_customerid, ref boolean ab_check)
public function integer wf_paymethod_chg_check ()
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
public subroutine of_resizepanels ()
end prototypes

event ue_view();String ls_customerid, ls_where
Long i, ll_master_row

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return 
	ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
End If

If ls_customerid = "" Then Return

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "고객정보등록"
iu_cust_msg.is_grp_name = "청구및사용내역상세조회"
iu_cust_msg.is_data[1] = ls_customerid

OpenWithParm(b1w_inq_inv_detail_pop, iu_cust_msg, gw_mdi_frame)

end event

event ue_find();Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_where, ls_customerid, ls_payid, ls_sale_month
String ls_workdt_fr, ls_workdt_to, ls_tr_month

String ls_pay_method

dw_cond2.AcceptText()

li_curtab = tab_1.selectedtab
ll_selrow = dw_master.GetSelectedRow(0)
If Not (ll_selrow > 0) Then Return
//ls_payid = dw_master.Object.customerm_payid[ll_selrow]
//If IsNull(ls_payid) Or ls_payid = "" Then Return
ls_customerid = dw_master.Object.customerm_customerid[ll_selrow]
If IsNull(ls_customerid) Or ls_customerid = "" Then Return

Choose Case li_curtab
	Case 2	        //판매내역 tab

//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		
		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "통화일(From) <= 통화일(To)")
					Return
				End If
			End If
		End If

		ls_where = " customerid = '" + ls_customerid + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(workdt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, "")
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
		
//		p_saveas.TriggerEvent("ue_enable")

	Case 3	        //판매내역 tab

//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		
		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "YYYY-MM-DD(From) <= YYYY-MM-DD(To)")
					Return
				End If
			End If
		End If

		ls_where = " customerid = '" + ls_customerid + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And yyyymmdd >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And yyyymmdd <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, "")
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
//		p_saveas.TriggerEvent("ue_enable")
	Case 4
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")
		ls_pay_method = trim(dw_cond2.Object.pay_method[1])
		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				
		If Isnull(ls_pay_method) Then ls_pay_method= ""		
		
//		***** 사용자 입력사항 검증 *****
//		If ls_workdt_fr = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(From)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_fr")
//			Return
//		End If
//		
//		If ls_workdt_to = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(to)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_to")
//			Return
//		End If
		/*
		If ls_pay_method = "" Then
			f_msg_usr_err(211, This.Title, "결제방법")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
		End If
		*/

		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "결제일자(From) <= 결제일자(To)")
					Return
				End If
			End If
		End If
		

		ls_where = " customerid = '" + ls_customerid + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(paydt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(paydt,'yyyymmdd') <= '" + ls_workdt_to + "' "
	   If ls_pay_method <> "" Then ls_where += " And pay_method = '" +ls_pay_method+ "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
	Case 5
//		***** 사용자 입력사항 변수에 대입 *****
		ls_workdt_fr = String(dw_cond2.Object.workdt_fr[1], "yyyymmdd")
		ls_workdt_to = String(dw_cond2.Object.workdt_to[1], "yyyymmdd")

		If Isnull(ls_workdt_fr) Then ls_workdt_fr = ""				
		If Isnull(ls_workdt_to) Then ls_workdt_to = ""				

		
//		***** 사용자 입력사항 검증 *****
//		If ls_workdt_fr = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(From)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_fr")
//			Return
//		End If
//		
//		If ls_workdt_to = "" Then
//			f_msg_usr_err(211, This.Title, "통화일(to)")
//			dw_cond2.setfocus()
//			dw_cond2.SetColumn("workdt_to")
//			Return
//		End If
		/*
		If ls_pay_method = "" Then
			f_msg_usr_err(211, This.Title, "결제방법")
			dw_cond2.setfocus()
			dw_cond2.SetColumn("yyyymm")
			Return
		End If
		*/

		If ls_workdt_to <> "" Then
			If ls_workdt_fr <> "" Then
				If ls_workdt_fr > ls_workdt_to Then
					f_msg_usr_err(211, This.Title, "결제일자(From) <= 결제일자(To)")
					Return
				End If
			End If
		End If
		

		ls_where = " p.customerid = '" + ls_customerid + "' "
		If ls_workdt_fr <> "" Then	ls_where += " And to_char(p.paydt,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	   If ls_workdt_to <> "" Then	ls_where += " And to_char(p.paydt,'yyyymmdd') <= '" + ls_workdt_to + "' "
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_rc = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_rc < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 
		ElseIf ll_rc = 0 Then
			f_msg_info(1000, Title, tab_1.is_tab_title[li_curtab])
			Return
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)		
		
End Choose
end event

public function integer wfi_get_payid (string as_customerid, ref boolean ab_check);//납입자랑 고객과 같은지 확인
String ls_payid
ab_check = False

Select payid
Into :ls_payid
From customerm
Where customerid = :as_customerid;

//Error
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err("납입자", "Select customerm Table")
	Return 0
End If

If ls_payid <> as_customerid Then
	ab_check = True					//같지 않음
Else
	ab_check = False					//같음
	
End If
Return 0

end function

public function integer wf_paymethod_chg_check ();String ls_drawingresult, ls_drawingtype

//신청결과=처리중
IF is_drawingresult_ori = is_drawingresult[3] Then
	is_chg_flag = 'N'			//pay_method 변경 Flag 
	return 2
End If

//신청유형=변경, 신청결과=미처리
IF is_drawingtype_ori = is_drawingtype[3] Then
	IF is_drawingresult_ori = is_drawingtype[2] Then
		is_chg_flag = 'N'       //pay_method 변경 Flag 
		return 2
	End If
End If

is_chg_flag = 'Y'
				
return 0
end function

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
		
	
	Else
		ab_check = False
		
	End If
 
Return 0
end function

public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE zoncod like :as_zoncod;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(Title, ":CURSOR cur_get_arezoncod")
	Return -1
End If

OPEN cur_get_arezoncod;
Do While(True)
	FETCH cur_get_arezoncod
	INTO :ls_zoncod;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(Title, ":cur_get_arezoncod")
		CLOSE cur_get_arezoncod;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_rows += 1
	as_arezoncod[ll_rows] = ls_zoncod
	
Loop
CLOSE cur_get_arezoncod;

Return ll_rows
end function

public subroutine of_resizepanels ();//// Resize the panels according to the Vertical Line, Horizontal Line,
//// BarThickness, and WindowBorder.
//Integer	li_index
//
//// Validate the controls.
//If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
//
//// Top processing
//idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
//idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)
//
//// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
//
//For li_index = 1 To tab_1.ii_enable_max_tab
//	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
//Next
//
end subroutine

on b1w_reg_customer_d_sc.create
int iCurrent
call super::create
this.p_view=create p_view
this.p_find=create p_find
this.dw_cond2=create dw_cond2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_view
this.Control[iCurrent+2]=this.p_find
this.Control[iCurrent+3]=this.dw_cond2
end on

on b1w_reg_customer_d_sc.destroy
call super::destroy
destroy(this.p_view)
destroy(this.p_find)
destroy(this.dw_cond2)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_reg_customer_c
	Desc.	:	고객 정보 등록(선불&후불)
	Ver	: 	1.0
	Date	: 	2003.10.21
	Prgromer : Park Kyung Haeem)
---------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_name[]

ib_new = False
//ib_billing = False
//ib_ctype3 = False		//선불 고객여부
is_check = ""
is_method = ""
is_credit = ""
is_inv_method = ""

p_find.TriggerEvent("ue_disable")
//p_saveas.TriggerEvent("ue_disable")
//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[6].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[7].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[8].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[9].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[10].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[11].SetRowFocusIndicator(off!)
//tab_1.idw_tabpage[12].SetRowFocusIndicator(off!)

//결제 정보
//카드 정보 가져오기
ls_ref_desc = ""
is_method = fs_get_control("B0", "P130", ls_ref_desc)
is_credit = fs_get_control("B0", "P131", ls_ref_desc)
is_inv_method = fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송
is_status = fs_get_control("B0", "P202", ls_ref_desc)    //등록상태

//선불제서비스TYPE
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)

//출금이체 신청유형(1.없음(0);2.신규(1);3.변경(2);4.해지(3);5.임의해지(7))
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_drawingtype[])

//출금이체 신청결과(1.없음(0);2.신청(1);3.처리중(2);4.처리성공(S);5.처리실패(F))
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_drawingresult[])

//출금이체 신청접수처
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A300", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_receiptcod = ls_name[2]

idt_sysdate = fdt_get_dbserver_now()    //sysdatetime

//p_view.TriggerEvent("ue_disable")
end event

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_customername, ls_payid, ls_logid, ls_value, ls_name
String ls_ssno, ls_corpno, ls_corpnm, ls_cregno, ls_phone, ls_status
String ls_ctype1, ls_ctype2,  ls_macod,  ls_new, ls_where
String ls_enterdtfrom, ls_enterdtto, ls_termdtfrom, ls_termdtto
Date ld_enterdtfrom, ld_enterdtto, ld_termdtfrom, ld_termdtto

String ls_value_1
Integer li_check
Long ll_row




ls_new = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

//신규 등록
If ib_new Then
	tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	//p_view.TriggerEvent("ue_disable")	
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.
	Return
//조회
Else
	ls_value = Trim(dw_cond.object.value[1])
	ls_name = Trim(dw_cond.object.name[1])
	//ls_location = Trim(dw_cond.object.location[1])			//지역구분
	//ls_value_1 = Trim(dw_cond.object.value_1[1])
	ls_enterdtfrom = String(dw_cond.object.enterdtfrom[1],'yyyymmdd')
	ls_enterdtto   = String(dw_cond.object.enterdtto[1],'yyyymmdd')

	
	ls_ctype2    = Trim(dw_cond.object.ctype2[1])
	ls_status    = Trim(dw_cond.object.status[1])
	If IsNull(ls_value) Then ls_value = ""
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_enterdtfrom) Then ls_enterdtfrom = ""
	If IsNull(ls_enterdtto) Then ls_enterdtto = ""
	If IsNull(ls_ctype2) Then ls_ctype2 = ""
	If IsNull(ls_status) Then ls_status= ""
   
	If (ls_value = ""  Or ls_name = "" )Then
		f_msg_info(200, Title, "조건항목 ")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If

   If ls_enterdtto <>"" Then
		If ls_enterdtfrom = "" Then
			f_msg_info(200, Title, "가입일 From")
			dw_cond.SetFocus()
			dw_cond.setColumn("enterdtfrom")
			Return 
		End If
	End If		

/*
   If ls_ctype2 <>"" Then
		If ls_enterdtfrom = "" Then
			f_msg_info(200, Title, "구분")
			dw_cond.SetFocus()
			dw_cond.setColumn("ctype2")
			Return 
		End If
	End If	
	
   If ls_status <>"" Then
		If ls_enterdtfrom = "" Then
			f_msg_info(200, Title, "가입구분")
			dw_cond.SetFocus()
			dw_cond.setColumn("status")
			Return 
		End If
	End If	
	*/
	/*If ls_value = "" Then
		f_msg_info(200, Title, "조건항목")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If
	
	If ls_name = "" Then
		f_msg_info(200, Title, "조건내역")
		dw_cond.SetFocus()
		dw_cond.setColumn("name")
		Return 
	End If */
		
		
	ls_where = ""
	If ls_value <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "customerid"
				ls_where += "customerid like '" + ls_name + "%' "
			Case "customernm"
				ls_where += "Upper(customernm) like '" + Upper(ls_name) + "%' "
			Case "logid"
				ls_where += "Upper(logid) like '" + Upper(ls_name) + "%' "
			Case "ssno"
				ls_where += "ssno like '" + ls_name + "%' "
//			Case "corpno"
//				ls_where += "cus.corpno like '" + ls_name + "%' "
//			Case "corpnm"
//				ls_where += "cus.corpnm like '" + ls_name + "%' "
			Case "cregno"
				ls_where += "cregno like '" + ls_name + "%' "
//			Case "phone1"
//				ls_where += "cus.phone1 like '" + ls_name + "%' "
//			Case "key"
//				ls_where += "Upper(val.validkey) like '" + Upper(ls_name) + "%' "
		End Choose	

	End If

	If ls_enterdtfrom <>"" Then
		If ls_where <> "" Then ls_where += " And "	
		ls_where += "enterdt >= ' to_date(" + ls_enterdtfrom + "', 'yyyymmdd h24:mi:ss') "			
	End If		
	
	If ls_enterdtto <>"" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "enterdt <= ' to_date(" + ls_enterdtto + "', 'yyyymmdd h24:mi:ss') "	
	End If
	
	If ls_ctype2 <>"" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "ctype2 = '"+ ls_ctype2 +"'"
	End If
	
	If ls_status <>"" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "status = '"+ ls_status + "'"
	End If	
	
	
				

	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
		//p_view.TriggerEvent("ue_disable")			
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")
		//p_view.TriggerEvent("ue_disable")			
		Return
	Else			
		//검색을 찾으면 Tab를 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If

End If
end event

event type integer ue_reset();//초기화
Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

li_tab_index = tab_1.SelectedTab

//Reset 문제
If tab_1.ib_tabpage_check[li_tab_index] = True Then
	tab_1.idw_tabpage[li_tab_index].AcceptText() 

	If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
		(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
		
		li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
					,Question!,YesNo!)
		If li_rc <> 1 Then
			Return LI_ERROR
		End If
	End If
End If
	
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
//p_view.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")
p_find.TriggerEvent("ue_disable")

dw_cond.ReSet()
dw_master.Reset()
For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
Next
dw_cond.Enabled = True
dw_cond.InsertRow(0)
dw_cond.SetColumn("value")
ib_new = False
is_chg_flag  = 'Y'

Return 0 
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert
b1u_check lu_check	
Integer li_rc, li_tab
Long ll_master_row
String ls_customerid, ls_ref_desc, ls_reqnum_dw, ls_name[]
Boolean lb_check1
li_tab = ai_selected_tab
lu_check = create b1u_check

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return -1
	ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
End If

Choose Case li_tab
	Case 1		//Tab 1 고객정보
		
		If ib_new = True Then
		  	
			 //Status
			ls_ref_desc = ""
			ls_reqnum_dw = fs_get_control("B0", "P200", ls_ref_desc)
			If ls_reqnum_dw = "" Then Return -1
				fi_cut_string(ls_reqnum_dw, ";", ls_name[])
				tab_1.idw_tabpage[li_tab].object.status[li_tab] = ls_name[1]
				
				//Display
				tab_1.idw_tabpage[li_tab].object.termdt.Protect = 1
				
				tab_1.idw_tabpage[li_tab].object.termtype.Protect = 1
				tab_1.idw_tabpage[li_tab].Object.termdt.Background.Color = RGB(255, 251, 240)
				tab_1.idw_tabpage[li_tab].Object.termdt.Color = RGB(0, 0, 0)
				tab_1.idw_tabpage[li_tab].Object.termtype.Background.Color = RGB(255, 251, 240)
				tab_1.idw_tabpage[li_tab].Object.termtype.Color = RGB(0, 0, 0)
				
				//원상태로..
				tab_1.idw_tabpage[li_tab].object.logid.Protect = 0
				tab_1.idw_tabpage[li_tab].Object.logid.Color = RGB(0, 0, 255)
				tab_1.idw_tabpage[li_tab].Object.logid.Background.Color = RGB(255, 255, 255)
				
				//Setting
				tab_1.idw_tabpage[li_tab].object.enterdt[li_tab] = fdt_get_dbserver_now()			//가입일
		End  If
		
			
			//Log
			tab_1.idw_tabpage[li_tab].object.crt_user[1] = gs_user_id
			tab_1.idw_tabpage[li_tab].object.crtdt[1] = fdt_get_dbserver_now()
			tab_1.idw_tabpage[li_tab].object.pgm_id[1] = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
			tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
			
	Case 2		//Tab 2 청구지정보
		//Setting
		tab_1.idw_tabpage[li_tab].object.customerid[1] = ls_customerid
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[1] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[1] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
		
		p_insert.TriggerEvent("ue_disable")
	
//	Case 3		//Tab 3 인증정보
//		//Setting
//		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
//		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
//		tab_1.idw_tabpage[li_tab].object.use_yn[al_insert_row] = 'N'
//		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
//		tab_1.idw_tabpage[li_tab].SetColumn("validkey")
//		
//		//Log
//		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
//		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
//		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
	
	Case 4		//Tab 4 H/W 정보
		//HW Seq 가져오기
		lu_check.is_caller   = "b1w_reg_customer%new_hw"
		lu_check.is_title    = Title
		lu_check.il_data[1] = al_insert_row							
		lu_check.ii_data[1]  = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		lu_check.uf_prc_check_4()
		li_rc = lu_check.ii_rc
		If li_rc < 0 Then 
			Destroy lu_check
			Return li_rc
		End If
		
		//Setting
		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
		tab_1.idw_tabpage[li_tab].object.rectype[al_insert_row] = "C"
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("adtype")
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
	
//  Case 9     //국가별할인
//		tab_1.idw_tabpage[li_tab].object.customerid[al_insert_row] = ls_customerid
//		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
//		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
//		tab_1.idw_tabpage[li_tab].SetColumn("countrycod")

	Case 10     //대역별 요율 등록
		tab_1.idw_tabpage[li_tab].object.parttype[al_insert_row]  = "C"
		tab_1.idw_tabpage[li_tab].object.partcod[al_insert_row]   = ls_customerid
		tab_1.idw_tabpage[li_tab].object.opendt[al_insert_row]    = Date(fdt_get_dbserver_now())
		tab_1.idw_tabpage[li_tab].object.roundflag[al_insert_row] = "U"
		tab_1.idw_tabpage[li_tab].object.frpoint[al_insert_row]   = 0
		tab_1.idw_tabpage[li_tab].object.unitsec[al_insert_row]   = 0
		tab_1.idw_tabpage[li_tab].object.unitfee[al_insert_row]   = 0
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("zoncod")
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row]  = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
		 
	Case 11     //착신지 제한번호 등록
		tab_1.idw_tabpage[li_tab].object.parttype[al_insert_row] = "C"
		tab_1.idw_tabpage[li_tab].object.partcod[al_insert_row]  = ls_customerid
		tab_1.idw_tabpage[li_tab].object.opendt[al_insert_row]   = Date(fdt_get_dbserver_now())
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("areanum")
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]  

End Choose

Destroy lu_check
Return 0

end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;//Save Check
b1u_check_sc lu_check
Integer li_tab, li_rc
Long i, ll_row, ll_master_row
String ls_customerid, ls_bank_chg, ls_paymethod, ls_drawingtype, ls_enddt
Boolean lb_check1

String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
Long   ll_rows1, ll_rows2, li_pre_cnt, li_old_cnt

li_tab = ai_select_tab
If tab_1.idw_tabpage[li_tab].RowCount() = 0 Then Return 0
lu_check = Create b1u_check_sc

Choose Case li_tab
	Case 1
		lu_check.is_caller = "b1w_reg_customer_c%save_tab1"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.ib_data[1] = ib_new
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		
		lu_check.uf_prc_check()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc = -2 Then
			Destroy lu_check
			Return -2
		End If
		
	   //납입자 오류
		If li_rc = -3 Then
			Destroy lu_check
			Return -3
		End If
		Destroy lu_check
	   
		//Update Log
		tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()

End Choose

If ib_billing = True	 Then ib_billing = False
		
Return 0
end event

event type integer ue_save();//Override
Constant Int LI_ERROR = -1
Int li_tab_index, li_return

li_tab_index = tab_1.SelectedTab

If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = tab_1.is_parent_title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return LI_ERROR
	End If

	tab_1.SelectedTab = li_tab_index
	tab_1.idw_tabpage[li_tab_index].SetFocus()
	Return LI_ERROR
End If

li_return = Trigger Event ue_extra_save(li_tab_index)
Choose Case li_return
	Case -3
		ib_billing = True 	
	Case -2
		//필수항목 미입력
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return -2
	Case -1
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

		f_msg_info(3010, tab_1.is_parent_title, "Save")
		ib_update = False
		Return -1
End Choose

If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return LI_ERROR
	End If

	tab_1.SelectedTab = li_tab_index
	tab_1.idw_tabpage[li_tab_index].SetFocus()
	f_msg_info(3010,tab_1.is_parent_title,"Save")
	Return LI_ERROR
End If

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

//cuesee
//저장 되어있으므로
String ls_customerid, ls_payid
Int li_rc, li_selectedTab
Long ll_row, ll_tab_rowcount, ll_master_row
Boolean lb_check2

li_selectedTab = tab_1.SelectedTab
If li_selectedTab = 1 Then						//Tab 1
	
	//신규등록
	If ib_new Then
		ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
		If ll_tab_rowcount < 1 Then Return 0
		dw_cond.Reset()
		dw_cond.InsertRow(0)
		ls_customerid = tab_1.idw_tabpage[1].object.customerid[1]
		dw_cond.object.value[1] = "customerid"
		dw_cond.object.name[1] = ls_customerid
		TriggerEvent("ue_ok")
		tab_1.SelectedTab = 2
		ib_new = False
	End If
	
	//청구 정보를 입력하게 한다.	
	If ib_billing Then						
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row <> 0 Then
			ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
			
			//wfi_get_ctype3(ls_customerid, lb_check1)
			wfi_get_payid(ls_customerid, lb_check2)

			If Not (lb_check2) Then
				tab_1.SelectedTab = 2
				TriggerEvent("ue_insert")
				p_insert.TriggerEvent("ue_disable") 		
			End If
		End If
  End If
  
ElseIf li_selectedTab = 2 Then	
	
	tab_1.idw_tabpage[2].Reset()
	tab_1.ib_tabpage_check[2] = False
	
	tab_1.Trigger Event SelectionChanged(2, 2)
 
End If

If is_check = "DEL" Then	//Delete 
	If  li_selectedTab = 1 Then
		 TriggerEvent("ue_reset")
		 is_check = ""
	End If
End If

Return 0
end event

event ue_extra_delete;//Delete
Integer li_tab

li_tab = tab_1.SelectedTab
If li_tab = 1 Then
  is_check = "DEL"
End If
Return 0 
end event

event type integer ue_delete();Constant Int LI_ERROR = -1
Long ll_row, ll_exist
String ls_rectype


If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End If

If tab_1.Selectedtab = 4 Then
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
		ll_row = tab_1.idw_tabpage[tab_1.SelectedTab].GetRow()
	   If ll_row <= 0 Then Return 0
		
		tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
		
		//delete 버튼 비활성화
		ll_exist = tab_1.idw_tabpage[tab_1.SelectedTab].Find("rectype = 'C'", 1, &
					tab_1.idw_tabpage[tab_1.SelectedTab].RowCount())
		
		If ll_exist = 0 Then
			p_delete.TriggerEvent("ue_disable")
		Else
			p_delete.TriggerEvent("ue_enable")
		End If
	End if
Else
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
	   	tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
	End if
End If

Return 0

end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//

CALL w_a_m_master::resize

Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_view.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	dw_cond2.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space 
	p_find.Y	   = tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	//p_saveas.Y = tab_1.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 125
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_view.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	dw_cond2.Y	= newheight - iu_cust_w_resize.ii_button_space_1 - 32
	p_find.Y	   = newheight - iu_cust_w_resize.ii_button_space_1
//	p_saveas.Y = newheight - iu_cust_w_resize.ii_button_space	
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_insert();Constant Int LI_ERROR = -1
String ls_cusid, ls_cusnm
Long ll_row,  ll_master_row
Integer li_curtab
//Int li_return

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return -1
li_curtab = tab_1.Selectedtab

If li_curtab = 3 Then
//		ls_cusid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		ls_cusnm = Trim(dw_master.object.customerm_customernm[ll_master_row])
//
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "인증정보 INSERT"
//		iu_cust_msg.is_grp_name = "고객등록"
//		iu_cust_msg.is_data[1] = ls_cusid			   //고객 ID
//		iu_cust_msg.is_data[2] = ls_cusnm            //고객명
//		iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//	
//		OpenWithParm(b1w_reg_validinfo_popup, iu_cust_msg)
//
//		If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
//			Return -1
//		End If
//
//		tab_1.ib_tabpage_check[3] = True

Else
	
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)
		
		tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
		tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
		tab_1.idw_tabpage[li_curtab].SetFocus()
		
		If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
			Return LI_ERROR
		End if
	
End if

//ii_error_chk = 0
Return 0


end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_customer_d_sc
integer y = 60
integer width = 2578
integer height = 200
string dataobject = "b1dw_cnd_reg_customer_sc"
end type

event dw_cond::clicked;call super::clicked;String ls_selectcod

Choose Case dwo.Name
//		ls_selectcod = This.Object.value_1[row]
//		If IsNull(ls_selectcod) or ls_selectcod = "" Then
//			 f_msg_usr_err(9000, parent.Title, "지역분류 선택을 먼저 선택하세요!")
//			 return -1
//		End If	Case "location"

	Case "name"
		   ls_selectcod = This.Object.value[row]
			If IsNull(ls_selectcod) or ls_selectcod = "" Then
			 f_msg_usr_err(9000, parent.Title, "조건항목을 먼저 선택하세요!")
			 return -1
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;
//분류선택에서 대분류, 중분류, 소분류를 선택함에 따라 location 컬럼의 dddw를 바꾼다.
//Choose Case dwo.Name
//	Case "value_1"
//		Choose Case data
//			Case "A"         //소분류
//				is_select_cod = "locationA"
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategorya")
//				Modify("location.dddw.DataColumn='locategorya_locategorya'")
//				Modify("location.dddw.DisplayColumn='locategorya_locategoryanm'")
//				
//			Case "B"			//중분류
//				is_select_cod = "locationB"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategoryb")
//				Modify("location.dddw.DataColumn='locategoryb_locategoryb'")
//				Modify("location.dddw.DisplayColumn='locategoryb_locategorybnm'")
//				 
//			Case "C"			//대분류
//				is_select_cod = "locationC"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1c_dddw_locategoryc")
//				Modify("location.dddw.DataColumn='locategoryc'")
//				Modify("location.dddw.DisplayColumn='locategorycnm'")
//			Case "L"
//				is_select_cod = "locationL"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1dc_dddw_location")
//				Modify("location.dddw.DataColumn='location'")
//				Modify("location.dddw.DisplayColumn='locationnm'")
//				
//			Case else					//분류선택 안했을 경우...
//				is_select_cod = ""				
//				Modify("location.dddw.name=''")
//				This.Object.location[row] = ''
//		End Choose
//End Choose
//
Return 0
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_customer_d_sc
integer x = 2779
integer y = 40
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_customer_d_sc
integer x = 3081
integer y = 40
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_customer_d_sc
integer x = 27
integer y = 8
integer width = 2615
integer height = 280
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_customer_d_sc
integer y = 296
integer width = 3534
integer height = 568
string dataobject = "b1dw_inq_customer_sc"
end type

event dw_master::ue_init();call super::ue_init;//dwObject ldwo_SORT
//ldwo_SORT = Object.customerm_customernm_t
//uf_init(ldwo_SORT)
end event

event dw_master::clicked;//Override
Integer li_SelectedTab
Long ll_selected_row
Long ll_old_selected_row
Int li_tab_index,li_rc

String ls_customerid
Boolean lb_check1, lb_check2


ll_old_selected_row = This.GetSelectedRow(0)

Call w_a_m_master`dw_master::clicked

li_SelectedTab = tab_1.SelectedTab
ll_selected_row = This.GetSelectedRow(0)

//Override - w_a_reg_m_tm2

If (tab_1.idw_tabpage[li_SelectedTab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_SelectedTab].DeletedCount() > 0)	Then

// 확인 메세지 두번 나오는 문제 해결(tab_1)
//	tab_1.SelectedTab = li_tab_index
	li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
		"Do you want to cancel?",Question!,YesNo!)
	If li_rc <> 1 Then
		If ll_selected_row > 0 Then
			SelectRow(ll_selected_row ,FALSE)
		End If
		SelectRow(ll_old_selected_row , TRUE )
		ScrollToRow(ll_old_selected_row)
		tab_1.idw_tabpage[li_SelectedTab].SetFocus()
		Return 
	End If
End If
		
tab_1.idw_tabpage[li_SelectedTab].Reset()
tab_1.ib_tabpage_check[li_SelectedTab] = False

// Button Enable Or Disable
tab_1.Trigger Event SelectionChanged(li_SelectedTab, li_SelectedTab)	

Return 0




end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
	ib_retrieve = True
//	dw_cond2.Object.userid[1] = Object.userhis_userid[1]	
	
	tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)	
End If
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_customer_d_sc
integer y = 1948
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_customer_d_sc
integer y = 1948
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_customer_d_sc
integer x = 622
integer y = 1948
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_customer_d_sc
integer x = 914
integer y = 1948
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_customer_d_sc
integer y = 912
integer width = 3534
integer height = 1012
fontcharset fontcharset = ansi!
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 5		//Tab 갯수
//Tab Title
is_tab_title[1] = "고객정보"
is_tab_title[2] = "통화내역"
is_tab_title[3] = "녹음내역"
is_tab_title[4] = "결재내역조회"
is_tab_title[5] = "상세결제내역조회"


//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_customer_t1_sc"
is_dwObject[2] = "b1dw_reg_customer_t2_sc"
is_dwObject[3] = "b1dw_reg_customer_t5_sc"
is_dwObject[4] = "b1dw_reg_customer_t3_sc"
is_dwObject[5] = "b1dw_reg_customer_t4_sc"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
DataWindowChild ldc
String ls_customerid, ls_payid, ls_zoncod, ls_priceplan, ls_paynm
String ls_where, ls_filter, ls_type, ls_desc
Long ll_row, i, ll_cnt, ll_rowcount,ll_rc
Integer li_rc, li_tab
Boolean lb_check
Dec     lc_data

b1u_check_sc	lu_check
lu_check = Create b1u_check_sc

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_customerid = Trim(dw_master.object.customerm_customerid[al_master_row])
//ls_payid = Trim(dw_master.object.customerm_payid[al_master_row])

//find 추가시 살리자!
li_rc = dw_cond2.AcceptText()
If li_rc <> 1 Then
	f_msg_usr_err(2100, Parent.Title, "dw_cond2.AcceptText()")
	Return -1
End If

dw_master.AcceptText()		
idw_tabpage[ai_select_tabpage].Reset()
ls_payid  = Trim(dw_master.Object.customerm_customerid[al_master_row])
ls_paynm = Trim(dw_master.Object.customerm_customernm[al_master_row])
If IsNull(ls_payid) Then ls_payid = ""


idw_tabpage[ai_select_tabpage].SetRedraw(false)

Choose Case li_tab
	Case 1								//Tab 1
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		lu_check.is_caller   = "b1w_reg_customer%inq_customer_tab1"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		lu_check.uf_prc_check()
		li_rc = lu_check.ii_rc
		If li_rc < 0 Then 
			Destroy lu_check
			Return li_rc
		End If
		
		//logid의 데이터가 없을경우
		String ls_logid
		ls_logid = tab_1.idw_tabpage[li_tab].object.logid[1]
		If IsNull(ls_logid) Then ls_logid = ""
		If ls_logid <> "" Then
			tab_1.idw_tabpage[li_tab].object.logid.Pointer = "Arrow!"
			tab_1.idw_tabpage[li_tab].idwo_help_col[1] = idw_tabpage[ai_select_tabpage].object.crt_user
		Else
			tab_1.idw_tabpage[li_tab].object.logid.Pointer = "help!"
			tab_1.idw_tabpage[li_tab].idwo_help_col[1] = idw_tabpage[ai_select_tabpage].object.logid
		End If
		is_payid_old = tab_1.idw_tabpage[li_tab].object.payid[1]
		

	Case  2,3
		idw_tabpage[ai_select_tabpage].Object.t_payid.Text = " [ " + ls_payid + " ]  " + ls_paynm + " "		
		ls_where  = "customerid = '" + ls_customerid+ "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_rc = idw_tabpage[ai_select_tabpage].Retrieve()	

		If ll_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rc = 0 Then
			Return 0				
		End If
		
	Case  4
		idw_tabpage[ai_select_tabpage].Object.t_payid.Text = " [ " + ls_payid + " ]  " + ls_paynm + " "		
		ls_where  = "customerid = '" + ls_customerid+ "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_rc = idw_tabpage[ai_select_tabpage].Retrieve()	

		If ll_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rc = 0 Then
			Return 0				
		End If		
	Case  5
		idw_tabpage[ai_select_tabpage].Object.t_payid.Text = " [ " + ls_payid + " ]  " + ls_paynm + " "				
		ls_where  = "p.customerid = '" + ls_customerid+ "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_rc = idw_tabpage[ai_select_tabpage].Retrieve()	

		If ll_rc < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rc = 0 Then
			Return 0				
		End If				

End Choose

idw_tabpage[ai_select_tabpage].SetRedraw(True)

Destroy lu_check

Return 0

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row		
String ls_customerid, ls_payid, ls_type, ls_desc
Boolean lb_check2
Integer li_exist

DataWindowChild ldc_paymethod


ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
	
ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()


//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
	//p_view.TriggerEvent("ue_disable")	
   Return 0
End If

//선불 고객 이거나 납입고객 아닌 경우
ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])

Choose Case newindex
	Case 1
		p_reset.visible=true
		//p_view.visible=true		
      p_find.visible=false		
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		//p_view.TriggerEvent("ue_enable")		
		dw_cond2.Visible = false	
		
		p_find.TriggerEvent("ue_disable")
		//p_saveas.TriggerEvent("ue_disable")
		dw_cond2.Visible = False
		
	Case 2,3		
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")
		//p_view.TriggerEvent("ue_disable")
		p_reset.visible=false
		//p_view.visible=false
      p_find.visible=true
		p_find.TriggerEvent("ue_enable")
		//p_saveas.TriggerEvent("ue_disable")
		//fine datawindow을 보여준다.
		dw_cond2.dataobject = "b1dw_inq_customer_sc3"
		dw_cond2.reset()
		dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		dw_cond2.Visible = True		


	Case 4
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")
		//p_view.TriggerEvent("ue_disable")
		p_reset.visible=false
		//p_view.visible=false
      p_find.visible=true
		p_find.TriggerEvent("ue_enable")
		//p_saveas.TriggerEvent("ue_disable")
		//fine datawindow을 보여준다.
		dw_cond2.dataobject = "b1dw_inq_customer_sc2"
		dw_cond2.reset()
      dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		dw_cond2.Visible = True		
      li_exist = dw_cond2.GetChild("pay_method", ldc_paymethod)		//DDDW 구함
      If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 결재방법")
      ldc_paymethod.SetTransObject(SQLCA)
      ldc_paymethod.Retrieve()		
	Case 5
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")
		//p_view.TriggerEvent("ue_disable")
		p_reset.visible=false
		//p_view.visible=false
      p_find.visible=true
		p_find.TriggerEvent("ue_enable")
		//p_saveas.TriggerEvent("ue_disable")
		//fine datawindow을 보여준다.
		dw_cond2.dataobject = "b1dw_inq_customer_sc4"
		dw_cond2.reset()
		dw_cond2.insertrow(0)
		dw_cond2.Setfocus()
		dw_cond2.Visible = True				
				
End Choose

idw_tabpage[newindex].Visible	 = True		
Return 0
	
end event

event tab_1::constructor;call super::constructor;Integer li_exist

DataWindowChild ldc_paymethod
//help Window
idw_tabpage[1].is_help_win[1] = "b1w_hlp_logid_1_sc"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.logid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

idw_tabpage[1].is_help_win[2] = "b1w_hlp_payid_sc"
idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.payid
idw_tabpage[1].is_data[2] = "CloseWithReturn"

idw_tabpage[1].is_help_win[3] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[3] = idw_tabpage[1].Object.zipcod
idw_tabpage[1].is_data[3] = "CloseWithReturn"

idw_tabpage[1].is_help_win[4] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[4] = idw_tabpage[1].Object.corp_zipcod
idw_tabpage[1].is_data[4] = "CloseWithReturn"

//idw_tabpage[2].is_help_win[1] = "w_hlp_post"
//idw_tabpage[2].idwo_help_col[1] = idw_tabpage[2].Object.bil_zipcod
//idw_tabpage[2].is_data[1] = "CloseWithReturn"

//가로로 출력 
//tab_1.idw_tabpage[3].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[4].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[5].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[6].object.datawindow.print.orientation = 1
//tab_1.idw_tabpage[12].object.datawindow.print.orientation = 1

//li_exist = tab_1.idw_tabpage[4].GetChild("pay_method", ldc_paymethod)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 결재방법")

li_exist = dw_cond2.GetChild("pay_method", ldc_paymethod)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 결재방법")

ldc_paymethod.SetTransObject(SQLCA)
ldc_paymethod.Retrieve()
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = ""
String ls_svctype, ls_customerid
Integer li_exist
 
Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
			Case "logid"		//Log ID
				ls_logid = Trim(idw_tabpage[ai_tabpage].Object.logid[al_row])
				If IsNull(ls_logid) Then ls_logid = ""
				If ls_logid = ""  Then
					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					End If
					
					idw_tabpage[ai_tabpage].Object.password.Color = RGB(255,255,255)		
			        idw_tabpage[ai_tabpage].Object.password.Background.Color = RGB(108, 147, 137)
				End If
			Case "payid"		//납입자 번호
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.payid[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					
					/* 2005.07.01 juede comment ?? 뭔소린지 모르겠음.
					 ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
				  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
				  If li_exist > 0 Then 
					 f_msg_usr_err(404, title, "")
					 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
					 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
					 Return 0
				 End If
				  */
					
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.phone1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.phone1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.phone1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[6]
					End If
					
					
					//명의인 정보에 넣기
					/* 2005.07.01 juede comment
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
					End If
					*/
					
				End If
			Case "zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					
					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
			Case "corp_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.corp_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.corp_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.corp_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
//	Case 2
//		Choose Case adwo_dwo.name
//			Case "bil_zipcod"
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.bil_zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.bil_addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.bil_addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//				End If
//		End Choose
//		
//	Case 3
//
//		idw_tabpage[3].accepttext()
//		
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row < 0 Then Return 0
//		
//		If idw_tabpage[ai_tabpage].object.use_yn[al_row] = 'Y' Then		
//			iu_cust_msg = Create u_cust_a_msg
//			iu_cust_msg.is_pgm_name = "인증정보수정"
//			iu_cust_msg.is_grp_name = "고객등록"
//			iu_cust_msg.is_data[1] = Trim(idw_tabpage[ai_tabpage].object.svctype[al_row])  //svctype
//			iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
//			iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row]) //validkey
//			iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
//		
////			ohj 2005.02.21 인증방법 추가(패스워드인증, 일반인증)로 인한 로직 추가로 popup변경
////			OpenWithParm(b1w_reg_validinfo_popup_update_cl, iu_cust_msg)
//			OpenWithParm(b1w_reg_validinfo_popup_update_cl_g, iu_cust_msg)
//	
//			If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
//				Return -1
//			End If
//			
//			tab_1.ib_tabpage_check[3] = True
//		End IF
//		
//		
//	Case 5
//		
//		//row Double Click시 해당 청구 자료 보여줌
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row < 0 Then Return 0
//		
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "신청정보 상세품목"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.orderno[al_row])
//		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.ref_contractseq[al_row])
//		
//		OpenWithParm(b1w_inq_svcorder_popup, iu_cust_msg)
//	
//	Case 6
//		ll_master_row = dw_master.GetSelectedRow(0)
//	  	If ll_master_row < 0 Then Return 0
//	  
//	  	ls_svctype = idw_tabpage[ai_tabpage].object.svcmst_svctype[al_row]
//		  
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "계약정보 상세품목"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractseq[al_row])
//		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		
//		If ls_svctype = is_svctype_pre Then
//		  	OpenWithParm(b1w_inq_contmst_popup_pre, iu_cust_msg) 
//		Else
//		  	OpenWithParm(b1w_inq_contmst_popup, iu_cust_msg) 			
//		End If
//	
//	Case 8
//		
//		ll_master_row = dw_master.GetSelectedRow(0)
//	  	If ll_master_row < 0 Then Return 0
//	  
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "할부 내역 상세정보"
//		iu_cust_msg.is_grp_name = "고객관리"
//		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractmst_contractseq[al_row])
//		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customerid[ll_master_row])
//		iu_cust_msg.is_data[4] = Trim(dw_master.object.customerm_customernm[ll_master_row])
//		
//		OpenWithParm(b1w_inq_quota_popup, iu_cust_msg) 

End Choose  

Return 0
end event

event tab_1::selectionchanging;//Occurs when another tab is about to be selected.
//Long. Return code choices (specify in a RETURN statement):

//0  Allow the selection to change
//1  Prevent the selection from changing

//신규 등록이면
If ib_new = TRUE Then Return 1

end event

event type integer tab_1::ue_dw_buttonclicked(integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo);call super::ue_dw_buttonclicked;//Butonn Click
String ls_payid
String ls_svccod, ls_priceplan, ls_customerid, ls_where, ls_acct_ssno
Long i, ll_master_row

If ai_tabpage = 1 Then		//납입자 청구정보
	tab_1.idw_tabpage[1].AcceptText()
	ls_payid = Trim(tab_1.idw_tabpage[1].object.payid[al_row])
	OpenWithParm(b1w_inq_payid_billing_info, ls_payid)				//Open
	
//ElseIf ai_tabpage = 3  Then
// //버튼 클릭시 서비스 신청 화면
//
// For i = 1 To idw_tabpage[3].RowCount()
//	
//	If idw_tabpage[3].object.status[i] = "00" Then   //신청이면
//		//서비스를 선택하지 않았을때는 그냥 끝낸다.
//		ls_svccod = Trim(tab_1.idw_tabpage[3].object.svccod[i]) 
//		ls_priceplan = Trim(tab_1.idw_tabpage[3].object.priceplan[i])
//	
//		If IsNull(ls_svccod) Then ls_svccod = ""
//		If IsNull(ls_priceplan) Then ls_priceplan = ""
//		
//		If ls_svccod = "" Or ls_priceplan = "" Then Return 0
//	
//	
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "서비스개통신청"
//		iu_cust_msg.is_grp_name = "서비스 신청"
//		iu_cust_msg.is_data[1] = Trim(tab_1.idw_tabpage[3].object.customerid[i])
//		iu_cust_msg.is_data[2] = Trim(tab_1.idw_tabpage[3].object.svccod[i])
//		iu_cust_msg.is_data[3] = Trim(tab_1.idw_tabpage[3].object.priceplan[i])
//		iu_cust_msg.is_data[4] = gs_pgm_id[gi_open_win_no]
//		iu_cust_msg.idw_data[1] = tab_1.idw_tabpage[3]
//		
//		OpenWithParm(b1w_reg_svc_actorder_1, iu_cust_msg,gw_mdi_frame)
//		End If
//	Next
End If


//INSOOK 수정 주민등록번호 유효성 Check 버튼(2004.06.29)
If ai_tabpage = 2 Then  //주민번호 check
	tab_1.idw_tabpage[2].AcceptText()
	ls_acct_ssno = Trim(tab_1.idw_tabpage[2].object.acct_ssno[al_row])

	//주민등록 번호(13자리),법인번호(10자리)format)
	If LenA(ls_acct_ssno) = 13 Then
		If fi_check_juminnum(ls_acct_ssno) = -1 Then
			f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
			tab_1.idw_tabpage[2].SetFocus()
			tab_1.idw_tabpage[2].SetColumn("acct_ssno")
			Return -1
		else
			MessageBox("주민번호 Check", "유효한 주민번호입니다.", information!, OK!, 1)
			tab_1.idw_tabpage[2].SetFocus()
			tab_1.idw_tabpage[2].SetColumn("acct_ssno")
		End If
	else
		f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
		tab_1.idw_tabpage[2].SetFocus()
		tab_1.idw_tabpage[2].SetColumn("acct_ssno")
		Return -1

	End If	

end if


Return 0 
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Changed
Boolean lb_check1, lb_check2
String ls_data , ls_ctype2, ls_filter, ls_svctype, ls_opendt
String  ls_payid, ls_customerid, ls_munitsec
Integer li_exist, li_exist1, li_rc

DataWindowChild ldc_priceplan
b1u_check	lu_check
lu_check = Create b1u_check

Choose Case tab_1.SelectedTab
	Case 1		//Tab 1
		ls_ctype2 = Trim(tab_1.idw_tabpage[1].Object.ctype2[1])
		b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
		b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
		
	    Choose Case dwo.name
		   Case "logid"
				If IsNull(data) Or data = "" Then
					tab_1.idw_tabpage[1].Object.password.Color = RGB(0,0,0)		
					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(255,255,255)
				Else //필수
					tab_1.idw_tabpage[1].Object.password.Color = RGB(255,255,255)		
					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(108, 147, 137)
				End If
				
			 //납입자 정보 바꿀 시
		   Case "payid"
			  ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
			  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
			  If li_exist > 0 Then 
				 f_msg_usr_err(404, title, "")
				 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
				 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
				 Return 2
			 End If
			 
		   //sms 수신여부
		   Case "sms_yn"
			  If data = 'Y' Then 
				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(255,255,255)		
				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(108, 147, 137)
   			  Else
				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(0,0,0)				
				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(255,255,255)
			  End If

		   //email 수신여부
		   Case "email_yn"
			  If data = 'Y' Then 
				  tab_1.idw_tabpage[1].Object.email1.Color = RGB(255,255,255)		
				  tab_1.idw_tabpage[1].Object.email1.Background.Color = RGB(108, 147, 137)
   			  Else
				  tab_1.idw_tabpage[1].Object.email1.Color = RGB(0,0,0)				
				  tab_1.idw_tabpage[1].Object.email1.Background.Color = RGB(255,255,255)
			  End If
			 
			 
			Case "ctype2"
				If lb_check1 Then		//개인이면 주민등록 번호 필수
					tab_1.idw_tabpage[1].Object.ssno.Color = RGB(255,255,255)		
					tab_1.idw_tabpage[1].Object.ssno.Background.Color = RGB(108, 147, 137)
					//tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@@@@-@@@@@@@"
					//tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.customernm[row]
					//tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.ssno[row]
				Else
					tab_1.idw_tabpage[1].Object.ssno.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.ssno.Background.Color = RGB(255, 255, 255)
				End If	
				
				If lb_check2 Then		//법인이면 사업장 정보 필수
					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(255, 255, 255)	
					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[1].Object.representative.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(255, 255, 255)	
					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(108, 147, 137)

					/* 2005.07.01 juede comment
				   Choose Case dwo.name
						Case "corpnm"
					   	tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.cprpnm[row]
						Case "cregno"
							tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.cregno[row]
						Case "businesstype"
							tab_1.idw_tabpage[1].object.holder_type[row] = tab_1.idw_tabpage[1].object.businesstype[row]
						Case "businessitem"
							tab_1.idw_tabpage[1].object.holder_item[row] = tab_1.idw_tabpage[1].object.businessitem[row]
					End Choose
					*/
				Else
					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.representative.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(255, 255, 255)

				End If
		   /* 2005.07.01 juede comment
			Case "addrtype"
					tab_1.idw_tabpage[1].object.holder_addrtype[row] = data
			Case "zipcod"
					tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
			Case "addr1"
					tab_1.idw_tabpage[1].object.holder_addr1[row] = data
			Case "addr2"
					tab_1.idw_tabpage[1].object.holder_addr2[row] = data
			*/
		  End Choose
		  
		  //개인이면
		  If lb_check1 Then
			   /* 2005.07.01 juede comment
				Choose Case dwo.name
					Case "customernm"
						tab_1.idw_tabpage[1].object.holder[row] = data
					Case "zipcode" 
						tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
					Case "ssno"
						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
				End Choose
				*/
			ElseIf lb_check2 Then		//법인이면
				/* 2005.07.07 juede comment
				Choose Case dwo.name
					Case "corpnm"
					   tab_1.idw_tabpage[1].object.holder[row] = data
					Case "cregno"
						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
					Case "businesstype"
						tab_1.idw_tabpage[1].object.holder_type[row] = data
					Case "businessitem"
						tab_1.idw_tabpage[1].object.holder_item[row] = data
				End Choose
				*/
			End If
		
//	Case 3
//		Choose Case dwo.name
//			Case "svccod"
//				li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//			
//				ldc_priceplan.SetTransObject(SQLCA)
//				ldc_priceplan.Retrieve(data)
//				
//		End Choose
//	
//	Case 10
//		If (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//			ls_munitsec = "0"
//		Else
//			ls_munitsec = String(tab_1.idw_tabpage[10].object.munitsec[row])
//			If IsNull(ls_munitsec) Then ls_munitsec = ""
//		End If
//		
//		Choose Case dwo.name
//			Case "zoncod"
//				If data <> "ALL" Then
//					tab_1.idw_tabpage[10].Object.areanum[row] = "ALL"
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 1
//				Else
//					tab_1.idw_tabpage[10].Object.areanum[row] = ""
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 0
//				End If
//				
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[10].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[10].setColumn("enddt")
//						tab_1.idw_tabpage[10].setRow(row)
//						tab_1.idw_tabpage[10].scrollToRow(row)
//						tab_1.idw_tabpage[10].setFocus()
//						Return -1
//					End If
//				End If
//				
//			Case "unitsec"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange1[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange1[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitsec1[row] > 0) Then
//					tab_1.idw_tabpage[10].object.munitsec1[row] = Long(data)
//				End If
//			End If
//		
//		Case "unitfee1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee1[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange2[row] = Long(data)
//				End If
//			End If
//		
//			
//		Case "unitsec2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec2[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee2[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee3[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee4[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee5[row] = Long(data)
//				End If
//			End If
//		End Choose
//	
//	Case 11
//		Choose Case dwo.name
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[11].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[11].setColumn("enddt")
//						tab_1.idw_tabpage[11].setRow(row)
//						tab_1.idw_tabpage[11].scrollToRow(row)
//						tab_1.idw_tabpage[11].setFocus()
//						Return -1
//					End If
//				End If
//		End Choose
End Choose
Return 0

end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;String ls_rectype, ls_status

//신청 상태일때만 delete
//If ai_tabpage = 3 Then
//	If al_row = 0 then Return -1
//	
//	If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
//		 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
//	Else
//	    tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
//		tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
//	End If
	
//rectype = "A" 이면 Delete 막음
//ElseIf ai_tabpage = 4 Then
//	il_row = al_row
//	If al_row <= 0 Then Return 0
//	ls_rectype = tab_1.idw_tabpage[tab_1.SelectedTab].object.rectype[al_row]
//	If ls_rectype = "A" Then
//		p_delete.TriggerEvent("ue_disable")
//	Else
//		p_delete.TriggerEvent("ue_enable")
//	End If
//End If

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_customer_d_sc
integer y = 868
end type

type p_view from u_p_view within b1w_reg_customer_d_sc
boolean visible = false
integer x = 1541
integer y = 1948
boolean bringtotop = true
string pointer = "HyperLink!"
boolean enabled = false
end type

type p_find from u_p_find within b1w_reg_customer_d_sc
boolean visible = false
integer x = 1207
integer y = 1948
boolean bringtotop = true
boolean originalsize = false
end type

type dw_cond2 from u_d_external within b1w_reg_customer_d_sc
boolean visible = false
integer x = 27
integer y = 1924
integer width = 1070
integer height = 188
integer taborder = 20
string dataobject = "b1dw_inq_customer_sc2"
boolean hscrollbar = false
boolean vscrollbar = false
end type

