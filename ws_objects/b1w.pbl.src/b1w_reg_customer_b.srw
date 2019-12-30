$PBExportHeader$b1w_reg_customer_b.srw
$PBExportComments$[kem] 고객정보 등록-후불&선불제- com&life
forward
global type b1w_reg_customer_b from w_a_reg_m_tm2
end type
type p_view from u_p_view within b1w_reg_customer_b
end type
end forward

global type b1w_reg_customer_b from w_a_reg_m_tm2
integer width = 3616
integer height = 2296
event ue_view ( )
p_view p_view
end type
global b1w_reg_customer_b b1w_reg_customer_b

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

on b1w_reg_customer_b.create
int iCurrent
call super::create
this.p_view=create p_view
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_view
end on

on b1w_reg_customer_b.destroy
call super::destroy
destroy(this.p_view)
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b1w_reg_customer_b
	Desc.	:	고객 정보 등록(선불&후불)
	Ver	: 	1.0
	Date	: 	2003.10.21
	Prgromer : Kim Eun Mi (kem)
---------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_name[]

ib_new = False
ib_billing = False
ib_ctype3 = False		//선불 고객여부
is_check = ""
is_method = ""
is_credit = ""
is_inv_method = ""

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[6].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[7].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[8].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[9].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[10].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[11].SetRowFocusIndicator(off!)

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

p_view.TriggerEvent("ue_disable")
end event

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_customername, ls_payid, ls_logid, ls_value, ls_name
String ls_ssno, ls_corpno, ls_corpnm, ls_cregno, ls_phone, ls_status
String ls_ctype1, ls_ctype2, ls_ctype3, ls_macod, ls_location, ls_new, ls_where
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
	p_view.TriggerEvent("ue_disable")	
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
	ls_location = Trim(dw_cond.object.location[1])			//지역구분
	ls_value_1 = Trim(dw_cond.object.value_1[1])
	
	If IsNull(ls_value) Then ls_value = ""
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_value_1) Then ls_value_1 = ""
	If IsNull(ls_location) Then ls_location= ""
   
	If (ls_value = ""  Or ls_name = "" ) And ( ls_value_1 = "" Or ls_location = "") Then
		f_msg_info(200, Title, "조건항목 혹은 지역 분류")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If

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
				ls_where += "cus.customerid like '" + ls_name + "%' "
			Case "customernm"
				ls_where += "Upper(cus.customernm) like '" + Upper(ls_name) + "%' "
			Case "payid"
				ls_where += "cus.payid like '" + ls_name + "%' "
			Case "logid"
				ls_where += "Upper(cus.logid) like '" + Upper(ls_name) + "%' "
			Case "ssno"
				ls_where += "cus.ssno like '" + ls_name + "%' "
			Case "corpno"
				ls_where += "cus.corpno like '" + ls_name + "%' "
			Case "corpnm"
				ls_where += "cus.corpnm like '" + ls_name + "%' "
			Case "cregno"
				ls_where += "cus.cregno like '" + ls_name + "%' "
			Case "phone1"
				ls_where += "cus.phone1 like '" + ls_name + "%' "
			Case "key"
				ls_where += "Upper(val.validkey) like '" + Upper(ls_name) + "%' "
		End Choose		
	End If
	
	//분류선택(대,중,소분류)에 따라 select 조건이 다라짐
	If ls_value_1 <> "" Then
		Choose Case is_select_cod
			Case "categoryA"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "a.categorya = '" + ls_location + "' "
			Case "categoryB"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "b.categoryb = '" + ls_location + "' "
			Case "categoryC"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "c.categoryc = '" + ls_location + "' "
		   Case "locationL"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "loc.location = '" + ls_location + "' "
		End Choose		
	End If
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
		p_view.TriggerEvent("ue_disable")			
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")
		p_view.TriggerEvent("ue_disable")			
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
p_view.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

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
b1u_check lu_check
Integer li_tab, li_rc
Long i, ll_row, ll_master_row
String ls_customerid, ls_bank_chg, ls_paymethod, ls_drawingtype, ls_enddt
Boolean lb_check1

String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
Long   ll_rows1, ll_rows2

li_tab = ai_select_tab
If tab_1.idw_tabpage[li_tab].RowCount() = 0 Then Return 0
lu_check = Create b1u_check

Choose Case li_tab
	Case 1
		lu_check.is_caller = "b1w_reg_customer%save_tab1_cl"
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
		
   Case 2
		lu_check.is_caller = "b1w_reg_customer%save_tab2"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.is_data[1] = is_method
		lu_check.is_data[2] = is_credit
		lu_check.is_data[3] = is_inv_method
		lu_check.is_data[4] = is_bank_chg_ori	
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		lu_check.uf_prc_check_1()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
      
		//Update Log
		tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
	
		//변경시 - 변경전정보 before 컬럼에 저장....
		ls_bank_chg = tab_1.idw_tabpage[li_tab].object.bank_chg[1] 
		ls_paymethod = tab_1.idw_tabpage[li_tab].object.pay_method[1] 
		ls_drawingtype = tab_1.idw_tabpage[li_tab].object.drawingtype[1] 		
		
		//변경check = 'Y' & 결재방법 = '자동이체' & 신청유형 = '변경' 일때만... before 저장...
		If ls_bank_chg = 'Y' and ls_paymethod = is_method and ls_drawingtype = is_drawingtype[3]Then
			If is_bank_chg_ori = 'Y' Then
			Else 
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1] = is_bank_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1] = is_acctno_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1] = is_acct_owner_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1] = is_acct_ssno_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1] = is_drawingresult_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1] = is_drawingtype_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1] = id_drawingreqdt_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1] = id_receiptdt_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1] = is_resultcod_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1] = is_receiptcod_ori
			End IF
		End If
	
//  Case 3
//	
//	   //tab3 인증정보는 delete만 save 되고... insert 나 update는 모두 popup window를 이용하여 저장된다.	   
//		lu_check.is_caller = "b1w_reg_customer%save_tab3"
//		lu_check.is_title = Title
//		lu_check.ii_data[1] = li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_2()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If
//		
//		//Update Log
//		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
//		For i = 1 To ll_row
//			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
//				tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
//				tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
//			End If
//	   Next

	Case 4
		lu_check.is_caller = "b1w_reg_customer%save_tab4"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		lu_check.uf_prc_check_4()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//Update Log
		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
		For i = 1 To ll_row
			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
				tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
			End If
	   Next
	   
//	Case 9
//		lu_check.is_caller = "b1w_reg_customer%save_tab9"
//		lu_check.is_title = Title
//		lu_check.ii_data[1] = li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
//		lu_check.uf_prc_check_9()
//		li_rc = lu_check.ii_rc
//		
//		//필수 항목 오류
//		If li_rc < 0 Then
//			Destroy lu_check
//			Return -2
//		End If

	Case 10
		lu_check.is_caller = "b1w_reg_customer%save_tab10"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		lu_check.uf_prc_check_10()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//******************************************//
		
		Long ll_rows, ll_findrow
		long ll_i, ll_zoncodcnt
		String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype
		String ls_date, ls_sort
		Dec lc_data, lc_frpoint, lc_Ofrpoint

		String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt
		Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
		String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
		Boolean lb_addX, lb_notExist
		Constant Integer li_MAXTMKIND = 3

		If tab_1.idw_tabpage[li_tab].RowCount()  = 0 Then Return 0

		//  대역/시간대코드/개시일자
		ls_Ozoncod = ""
		ls_Otmcod  = ""
		ls_tmcodX = ""
		li_tmcodcnt = 0
		li_cnt_tmkind = 0

		//고객의 priceplan = ALL
		ls_priceplan = 'ALL'

		//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
		li_return = wfl_get_arezoncod(ls_zoncod, ls_arezoncod[])
		If li_return < 0 Then Return -2

		ll_rows = tab_1.idw_tabpage[li_tab].RowCount()
		If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0


		//정리하기 위해서 Sort
		tab_1.idw_tabpage[li_tab].SetRedraw(False)
		ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
		tab_1.idw_tabpage[li_tab].SetSort(ls_sort)
		tab_1.idw_tabpage[li_tab].Sort()


		For ll_row = 1 To ll_rows
			ls_zoncod = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_row])
			ls_tmcod  = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_row])
			ls_opendt = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_row], 'yyyymmdd')
			
			//시작Point - khpark 추가 -
			lc_frpoint = tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row]
			If IsNull(lc_frpoint) Then tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row] = 0

			If tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row] < 0 Then
				f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
				tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
				tab_1.idw_tabpage[li_tab].SetRow(ll_row)
				tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[li_tab].SetRedraw(True)
				Return -2
			End If
	
			// 1 zoncod가 같으면 
			If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
		
				//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
				If MidA(ls_tmcod, 2, 1) <> MidA(ls_Otmcod, 2, 1) Then
					f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
					tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[li_tab].SetRedraw(True)
					Return -2
	
				ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
					li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
				End If	// 2 close						
	
			// 1 else	
			Else
				//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
				If lb_notExist = False Then
					lb_notExist = True
					For ll_i = 1 To UpperBound(ls_arezoncod)
						If ls_arezoncod[ll_i] = ls_zoncod Then 
							lb_notExist = False
							Exit
						End If
					Next
				End If	 // 3 close	
				If ls_Ozoncod <>  ls_zoncod Then 
	      		ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
			   End If
        
				// 4 zonecod가  바뀌었거나 처음 row 일때
				// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
				If ll_row > 1 Then
			
					If ls_tmcodX <> 'X' and LenA(ls_tmcodX) <> li_MAXTMKIND Then
						f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
						tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
						tab_1.idw_tabpage[li_tab].SetRow(ll_row - 1)
						tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row - 1)
						tab_1.idw_tabpage[li_tab].SetRedraw(True)
						Return -2
					End If 
			
					li_rtmcnt = -1
					//이미 Select됐된 시간대인지 Check
					For li_i = 1 To li_cnt_tmkind
						If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
					Next
		
					// 5 tmcod에 해당 pricecod 별로 tmcod check
					If li_rtmcnt < 0 Then
						li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
						If li_return < 0 Then 
							tab_1.idw_tabpage[li_tab].SetRedraw(True)
							Return -2
						End If
				
						li_cnt_tmkind += 1
						ls_tmkind[li_cnt_tmkind,1] = LeftA(ls_Otmcod, 2)
						ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
					End If // 5 close
			
					//누락된 시간대코드가 없는지 Check
					If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
						f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
						tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
						tab_1.idw_tabpage[li_tab].SetRow(ll_row - 1)
						tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row - 1)
						tab_1.idw_tabpage[li_tab].SetRedraw(True)
						Return -2
					End If
	
					li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
				   ls_tmcodX = ""
				Else // 4 else	 
					li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
			
				End If // 4 close
			End If // 1 close ls_Ozoncod = ls_zoncod 조건 
	
			// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
			If LeftA(ls_tmcod, 1) = 'X' Then
				If LenA(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
					f_msg_usr_err(9000, Title, "모든 시간대는 다른 시간대랑 같이 사용 할 수 없습니다." )
					tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[li_tab].SetRedraw(True)
					Return -2
				ElseIf LenA(ls_tmcodX) = 0 Then 
					ls_tmcodX += LeftA(ls_tmcod, 1)
				End If
			Else
				lb_addX = True
				For li_i = 1 To LenA(ls_tmcodX)
					If MidA(ls_tmcodX, li_i, 1) = LeftA(ls_tmcod, 1) Then lb_addX = False
				Next
				If lb_addX Then ls_tmcodX += LeftA(ls_tmcod, 1)
			End If				
	
			ll_findrow = 0
			If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
		
				ll_findrow = tab_1.idw_tabpage[li_tab].Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
		   	                         "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
												"' and frpoint = 0", 1, ll_rows)

				If ll_findrow <= 0 Then
					f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
					tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
					tab_1.idw_tabpage[li_tab].SetRow(ll_row)
					tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
					tab_1.idw_tabpage[li_tab].SetRedraw(True)
					return -2
				End If
		
			End If
		
			ls_Ozoncod = ls_zoncod
			ls_Otmcod  = ls_tmcod
			ls_Oopendt = ls_opendt
		Next


		// zoncod가 하나만 있을경우 
		If LenA(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
			f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
			tab_1.idw_tabpage[li_tab].SetFocus()
			tab_1.idw_tabpage[li_tab].SetRedraw(True)
			Return -2
		End If

		li_rtmcnt = -1
		//이미 Select됐된 시간대인지 Check
		For li_i = 1 To li_cnt_tmkind
			If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
		Next

		//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
		If li_rtmcnt < 0 Then
			li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
			If li_return < 0 Then
				tab_1.idw_tabpage[li_tab].SetRedraw(True)
				Return -2
			End If
		End If

		//누락된 시간대코드가 없는지 Check
		If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
			f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
			tab_1.idw_tabpage[li_tab].SetColumn("tmcod")
			tab_1.idw_tabpage[li_tab].SetRow(ll_rows)
			tab_1.idw_tabpage[li_tab].ScrollToRow(ll_rows)
			tab_1.idw_tabpage[li_tab].SetRedraw(True)
			Return -2
		End If

		//같은 시간대  code error 처리
		ls_Ozoncod = ""
		ls_Otmcod  = ""
		ls_Oopendt = ""
		lc_Ofrpoint = -1
		For ll_row = 1 To ll_rows
			ls_zoncod = Trim(tab_1.idw_tabpage[li_tab].Object.zoncod[ll_row])
			ls_opendt = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_row],'yyyymmdd')
			ls_tmcod = Trim(tab_1.idw_tabpage[li_tab].Object.tmcod[ll_row])
			lc_frpoint = tab_1.idw_tabpage[li_tab].Object.frpoint[ll_row]
		
			If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
				f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
				tab_1.idw_tabpage[li_tab].SetColumn("frpoint")
				tab_1.idw_tabpage[li_tab].SetRow(ll_row)
				tab_1.idw_tabpage[li_tab].ScrollToRow(ll_row)
				tab_1.idw_tabpage[li_tab].SetRedraw(True)
				Return -2
			End If
			ls_Ozoncod = ls_zoncod
			ls_Oopendt = ls_opendt
			ls_Otmcod = ls_tmcod
			lc_Ofrpoint = lc_frpoint
		Next		

		If lb_notExist Then
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 대역입니다." )
			//Return -2
		End If

		If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
			f_msg_info(9000, Title, "정의된 모든대역에 대해서 요율을 등록해야 합니다.")
			//Return -2
		End If


		ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
		tab_1.idw_tabpage[li_tab].SetSort(ls_sort)
		tab_1.idw_tabpage[li_tab].Sort()
		tab_1.idw_tabpage[li_tab].SetRedraw(True)
	
		//******************************************//
		
		//적용종료일 체크
		For i = 1 To tab_1.idw_tabpage[li_tab].RowCount()
			ls_opendt = Trim(String(tab_1.idw_tabpage[li_tab].object.opendt[i], 'yyyymmdd'))
			ls_enddt  = Trim(String(tab_1.idw_tabpage[li_tab].object.enddt[i], 'yyyymmdd'))
			
			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
			
			If ls_opendt > ls_enddt Then
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				tab_1.idw_tabpage[li_tab].setColumn("enddt")
				tab_1.idw_tabpage[li_tab].setRow(i)
				tab_1.idw_tabpage[li_tab].scrollToRow(i)
				tab_1.idw_tabpage[li_tab].setFocus()
				Return -2
			End If
		Next
		
		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
		For ll_rows1 = 1 To tab_1.idw_tabpage[li_tab].RowCount()
			ls_parttype1  = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows1])
			ls_partcod1   = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows1])
			ls_zoncod1    = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_rows1])
			ls_tmcod1     = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_rows1])
			ls_frpoint1   = String(tab_1.idw_tabpage[li_tab].object.frpoint[ll_rows1])
			ls_areanum1   = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows1])
			ls_itemcod1   = Trim(tab_1.idw_tabpage[li_tab].object.itemcod[ll_rows1])
			ls_opendt1    = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows1], 'yyyymmdd')
			ls_enddt1     = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows1], 'yyyymmdd')
	
			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
	
			For ll_rows2 = tab_1.idw_tabpage[li_tab].RowCount() To ll_rows1 - 1 Step -1
				If ll_rows1 = ll_rows2 Then
					Exit
				End If
				ls_parttype2 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows2])
				ls_partcod2  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows2])
				ls_zoncod2   = Trim(tab_1.idw_tabpage[li_tab].object.zoncod[ll_rows2])
				ls_tmcod2    = Trim(tab_1.idw_tabpage[li_tab].object.tmcod[ll_rows2])
				ls_frpoint2  = String(tab_1.idw_tabpage[li_tab].object.frpoint[ll_rows2])
				ls_areanum2  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows2])
				ls_itemcod2  = Trim(tab_1.idw_tabpage[li_tab].object.itemcod[ll_rows2])
				ls_opendt2   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows2], 'yyyymmdd')
				ls_enddt2    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows2], 'yyyymmdd')
				
				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
				
				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
					And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
					
					If ls_enddt1 >= ls_opendt2 Then
						f_msg_info(9000, Title, "같은 대역[ " + ls_zoncod1 + " ], 같은 착신지번호[ " + ls_areanum1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
														+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]으로 적용개시일이 중복됩니다.")
						Return -1
					End If
				End If
				
			Next
		Next

		
		//Update Log
		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
		For i = 1 To ll_row
			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[li_tab].object.updt_user[i] = gs_user_id
				tab_1.idw_tabpage[li_tab].object.updtdt[i] = fdt_get_dbserver_now()
			End If
	   Next
		
	Case 11
		lu_check.is_caller = "b1w_reg_customer%save_tab11"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		lu_check.uf_prc_check_11()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//적용종료일 체크
		For i = 1 To tab_1.idw_tabpage[li_tab].RowCount()
			ls_opendt = Trim(String(tab_1.idw_tabpage[li_tab].object.opendt[i], 'yyyymmdd'))
			ls_enddt  = Trim(String(tab_1.idw_tabpage[li_tab].object.enddt[i], 'yyyymmdd'))
			
			If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
			
			If ls_opendt > ls_enddt Then
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				tab_1.idw_tabpage[li_tab].setColumn("enddt")
				tab_1.idw_tabpage[li_tab].setRow(i)
				tab_1.idw_tabpage[li_tab].scrollToRow(i)
				tab_1.idw_tabpage[li_tab].setFocus()
				Return -2
			End If
		Next
		
		//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
		For ll_rows = 1 To tab_1.idw_tabpage[li_tab].RowCount()
			ls_parttype1 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows])
			ls_partcod1  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows])
			ls_areanum1  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows])
			ls_opendt1   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows], 'yyyymmdd')
			ls_enddt1    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows], 'yyyymmdd')
			
			If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
			
			For ll_rows1 = tab_1.idw_tabpage[li_tab].RowCount() To ll_rows - 1 Step -1
				If ll_rows = ll_rows1 Then
					Exit
				End If
				ls_parttype2 = Trim(tab_1.idw_tabpage[li_tab].object.parttype[ll_rows1])
				ls_partcod2  = Trim(tab_1.idw_tabpage[li_tab].object.partcod[ll_rows1])
				ls_areanum2  = Trim(tab_1.idw_tabpage[li_tab].object.areanum[ll_rows1])
				ls_opendt2   = String(tab_1.idw_tabpage[li_tab].object.opendt[ll_rows1], 'yyyymmdd')
				ls_enddt2    = String(tab_1.idw_tabpage[li_tab].object.enddt[ll_rows1], 'yyyymmdd')
				
				If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
				
				If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_areanum1 = ls_areanum2) Then
					If ls_enddt1 >= ls_opendt2 Then
						f_msg_info(9000, Title, "같은 제한번호[ " + ls_areanum1 + " ]로 적용개시일이 중복됩니다.")
						Return -1
					End If
				End If
				
			Next
			
		Next

		//Update Log
		ll_row = tab_1.idw_tabpage[li_tab].RowCount()
		For i = 1 To ll_row
			If tab_1.idw_tabpage[li_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[li_tab].object.updt_uer[i] = gs_user_id
				tab_1.idw_tabpage[li_tab].object.updtdt[i] = fdt_get_dbserver_now()
			End If
	   Next
		
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
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_view.Y		= newheight - iu_cust_w_resize.ii_button_space_1
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

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_customer_b
integer y = 60
integer width = 2578
integer height = 200
string dataobject = "b1dw_cnd_reg_customer"
end type

event dw_cond::clicked;call super::clicked;String ls_selectcod

Choose Case dwo.Name
	Case "location"
		ls_selectcod = This.Object.value_1[row]
		If IsNull(ls_selectcod) or ls_selectcod = "" Then
			 f_msg_usr_err(9000, parent.Title, "지역분류 선택을 먼저 선택하세요!")
			 return -1
		End If
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
Choose Case dwo.Name
	Case "value_1"
		Choose Case data
			Case "A"         //소분류
				is_select_cod = "locationA"
				Modify("location.dddw.name=''")
				Modify("location.dddw.DataColumn=''")
				Modify("location.dddw.DisplayColumn=''")
				This.Object.location[row] = ''				
				Modify("location.dddw.name=b1c_dddw_locategorya")
				Modify("location.dddw.DataColumn='locategorya_locategorya'")
				Modify("location.dddw.DisplayColumn='locategorya_locategoryanm'")
				
			Case "B"			//중분류
				is_select_cod = "locationB"				
				Modify("location.dddw.name=''")
				Modify("location.dddw.DataColumn=''")
				Modify("location.dddw.DisplayColumn=''")
				This.Object.location[row] = ''				
				Modify("location.dddw.name=b1c_dddw_locategoryb")
				Modify("location.dddw.DataColumn='locategoryb_locategoryb'")
				Modify("location.dddw.DisplayColumn='locategoryb_locategorybnm'")
				 
			Case "C"			//대분류
				is_select_cod = "locationC"				
				Modify("location.dddw.name=''")
				Modify("location.dddw.DataColumn=''")
				Modify("location.dddw.DisplayColumn=''")
				This.Object.location[row] = ''				
				Modify("location.dddw.name=b1c_dddw_locategoryc")
				Modify("location.dddw.DataColumn='locategoryc'")
				Modify("location.dddw.DisplayColumn='locategorycnm'")
			Case "L"
				is_select_cod = "locationL"				
				Modify("location.dddw.name=''")
				Modify("location.dddw.DataColumn=''")
				Modify("location.dddw.DisplayColumn=''")
				This.Object.location[row] = ''				
				Modify("location.dddw.name=b1dc_dddw_location")
				Modify("location.dddw.DataColumn='location'")
				Modify("location.dddw.DisplayColumn='locationnm'")
				
			Case else					//분류선택 안했을 경우...
				is_select_cod = ""				
				Modify("location.dddw.name=''")
				This.Object.location[row] = ''
		End Choose
End Choose

Return 0
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_customer_b
integer x = 2779
integer y = 40
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_customer_b
integer x = 3081
integer y = 40
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_customer_b
integer x = 37
integer width = 2615
integer height = 280
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_customer_b
integer y = 296
integer width = 3534
integer height = 568
string dataobject = "b1dw_inq_customer"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.customerm_customernm_t
uf_init(ldwo_SORT)
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

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_customer_b
integer y = 2056
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_customer_b
integer y = 2056
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_customer_b
integer x = 622
integer y = 2056
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_customer_b
integer x = 1207
integer y = 2056
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_customer_b
integer y = 912
integer width = 3534
integer height = 1116
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 11		//Tab 갯수
//Tab Title
is_tab_title[1] = "고객정보"
is_tab_title[2] = "청구정보"
is_tab_title[3] = "인증정보"
is_tab_title[4] = "H/W 정보"
is_tab_title[5] = "신청정보"
is_tab_title[6] = "계약정보"
is_tab_title[7] = "일시정지 기간정보"
is_tab_title[8] = "할부 계약정보"
//is_tab_title[9] = "국가별 할인"
is_tab_title[9] = "선불충전로그"
is_tab_title[10] = "대역별요율"
is_tab_title[11] = "착신지제한번호"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_customer_t1_cl"
is_dwObject[2] = "b1dw_reg_customer_t2"
is_dwObject[3] = "b1dw_reg_customer_t3"
is_dwObject[4] = "b1dw_reg_customer_t4"
is_dwObject[5] = "b1dw_reg_customer_t5"
is_dwObject[6] = "b1dw_reg_customer_t6"
is_dwObject[7] = "b1dw_reg_customer_t7"
is_dwObject[8] = "b1dw_reg_customer_t8"
//is_dwObject[9] = "b1dw_reg_customer_t9"
is_dwObject[9] = "b1dw_reg_customer_t10"
is_dwObject[10] = "b0dw_reg_particular_zoncst"  //"b1dw_reg_customer_t11_1"
is_dwObject[11] = "b0dw_reg_blacklist_a"  //"b1dw_reg_customer_t12"
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;
//Tab Retrieve
DataWindowChild ldc
String ls_customerid, ls_payid, ls_zoncod, ls_priceplan
String ls_where, ls_filter, ls_type, ls_desc
Long ll_row, i, ll_cnt, ll_rowcount
Integer li_rc, li_tab
Boolean lb_check
Dec     lc_data

b1u_check	lu_check
lu_check = Create b1u_check

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_customerid = Trim(dw_master.object.customerm_customerid[al_master_row])
ls_payid = Trim(dw_master.object.customerm_payid[al_master_row])

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
		
	Case 2
		
		//선불 고객인지 확인
//		wfi_get_ctype3(ls_customerid, ib_ctype3)
//		If ib_ctype3 Then
//		   idw_tabpage[li_tab].Reset()
//			Return 0		//조회하지 않는다.
//		End If	
		  
		//고객과 납입자가 다를 경우
//		wfi_get_payid(ls_customerid,lb_check)
//		If lb_check Then
//			idw_tabpage[li_tab].Reset()
//			Return 0		//조회하지 않는다.
//		End If
		
		ls_where = "customerm.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
		//origin data
		is_pay_method_ori = tab_1.idw_tabpage[li_tab].object.pay_method[1]
		is_bank_ori = tab_1.idw_tabpage[li_tab].object.bank[1]
		is_acctno_ori = tab_1.idw_tabpage[li_tab].object.acctno[1]
		is_acct_owner_ori = tab_1.idw_tabpage[li_tab].object.acct_owner[1]
		is_acct_ssno_ori = tab_1.idw_tabpage[li_tab].object.acct_ssno[1]			
		is_drawingresult_ori = tab_1.idw_tabpage[li_tab].object.drawingresult[1]
		is_drawingtype_ori = tab_1.idw_tabpage[li_tab].object.drawingtype[1]
		id_drawingreqdt_ori = tab_1.idw_tabpage[li_tab].object.drawingreqdt[1]
		id_receiptdt_ori = tab_1.idw_tabpage[li_tab].object.receiptdt[1]
		is_resultcod_ori = tab_1.idw_tabpage[li_tab].object.resultcod[1]		
		is_receiptcod_ori	= tab_1.idw_tabpage[li_tab].object.receiptcod[1]			

		If is_drawingtype_ori = is_drawingtype[3] and is_drawingresult_ori = is_drawingresult[2] Then
			is_bank_chg_ori = 'Y' 
        	tab_1.idw_tabpage[li_tab].object.bank_chg[1]  = 'Y'
			tab_1.idw_tabpage[li_tab].SetitemStatus(1, "bank_chg", Primary!, NotModified!)   //수정 안되었다고 인식.				
			is_bank_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1]
			is_acctno_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1]
			is_acct_owner_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1]
			is_acct_ssno_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1]			
			is_drawingresult_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1]
			is_drawingtype_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1]
			id_drawingreqdt_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1]
			id_receiptdt_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1]
			is_resultcod_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1]		
			is_receiptcod_bef	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1]
		End If
		
		wf_paymethod_chg_check()
		
		lu_check.is_caller   = "b1w_reg_customer%inq_customer_tab2"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.is_data[1] = is_method
		lu_check.is_data[2] = is_credit
		lu_check.is_data[3] = is_inv_method
		lu_check.is_data[4] = is_chg_flag
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		lu_check.uf_prc_check_1()
		li_rc = lu_check.ii_rc
		If li_rc < 0 Then 
			Destroy lu_check
			Return li_rc
		End If
	   //화폐
	   is_currency_old = tab_1.idw_tabpage[li_tab].object.billinginfo_currency_type[1]
 	Case 3
	    ll_row = idw_tabpage[li_tab].Retrieve(ls_customerid)	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
	Case 4 
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
	Case 5
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
	Case 6
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
	Case 7
		ls_where = "sus.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
   
 	Case 8
		ls_where = "quo.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
	
//	//국가별할인
//	Case 9
//		ls_where = "customerid = '" + ls_customerid + "' "
//		idw_tabpage[li_tab].is_where = ls_where		
//		ll_row = idw_tabpage[li_tab].Retrieve()	
//		If ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		ElseIf ll_row = 0 Then 
//			Return 0 		//해당자료 없는것
//		End If 
		
	//선불충전로그
	Case 9
		ls_where = " r.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If 
		
	//대역별요율
	Case 10
		ls_where = " partcod = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where
		ll_row = idw_tabpage[li_tab].Retrieve()
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
		ls_type = fs_get_control("B1", "Z100", ls_desc)
		
		If ls_type = "0" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0"
			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0"
		ElseIf ls_type = "1" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.0"
		ElseIf ls_type = "2" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.00"
		ElseIF ls_type = "3" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.000"
		Else
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee.Format  = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee1.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee2.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee3.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee4.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.munitfee5.Format = "#,##0.0000"
		End If
		
		For i =1 To tab_1.idw_tabpage[10].RowCount()
	   	lc_data = tab_1.idw_tabpage[10].object.unbilsec[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unbilsec[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.confee[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.confee[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitfee1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.tmrange1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitsec1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitfee2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.tmrange2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitsec2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitfee3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.tmrange3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitsec3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitfee4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.tmrange4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitsec4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitfee5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitfee5[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.tmrange5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.tmrange5[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.unitsec5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.unitsec5[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitfee1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.mtmrange1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitsec1[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec1[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitfee2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.mtmrange2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitsec2[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec2[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitfee3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.mtmrange3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitsec3[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec3[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitfee4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.mtmrange4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitsec4[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec4[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitfee5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitfee5[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.mtmrange5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.mtmrange5[i] = 0
			lc_data = tab_1.idw_tabpage[10].object.munitsec5[i]
			If IsNull(lc_data) Then tab_1.idw_tabpage[10].object.munitsec5[i] = 0	 
			
			tab_1.idw_tabpage[10].SetItemStatus(i, 0, Primary!, NotModified!)
		Next

	//착신지제한번호
	Case 11
		ls_where = " partcod = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
End Choose

Destroy lu_check

Return 0

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row		
String ls_customerid, ls_payid, ls_type, ls_desc
Boolean lb_check2

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
	
ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
	p_view.TriggerEvent("ue_disable")	
    Return 0
End If

//선불 고객 이거나 납입고객 아닌 경우
ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//wfi_get_ctype3(ls_customerid, lb_check1)
//wfi_get_payid(ls_customerid, lb_check2)

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")		
		
	Case 2		//Billing 정보
		//선불 고객 
//		If lb_check1 Then 
//			p_insert.TriggerEvent("ue_disable") 		
//			p_delete.TriggerEvent("ue_disable")
//			p_save.TriggerEvent("ue_disable")
//			p_reset.TriggerEvent("ue_enable")
//		End If
		
		
		//신규 납입 고객은 반드시 청구정보 존재
		//그래서 reset 할 수 없다.
		If ll_tab_row > 0  Then
			p_insert.TriggerEvent("ue_disable") 		
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")	
			p_view.TriggerEvent("ue_enable")		
		Else
			p_insert.TriggerEvent("ue_enable") 		
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
			p_view.TriggerEvent("ue_enable")		
		End If
	Case 3		//인증 정보
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")
	Case 4		//H/W 정보								
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")	
	Case 5		//신청정보										
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")		
	Case 6		//계약정보
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")		
	Case 7		//일시정지 기간 정보
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")		
	Case 8		//할부 계약 정보
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")	
//	Case 9 		//국가별 할인
//		p_insert.TriggerEvent("ue_enable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		p_view.TriggerEvent("ue_enable")	
	Case 9		//선불충전로그
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")
	Case 10     //대역별 요율등록
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")
		
		ls_type = fs_get_control("B1", "Z100", ls_desc)
		
		If ls_type = "0" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0"
		ElseIf ls_type = "1" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0"
		ElseIf ls_type = "2" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.00"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.00"
		ElseIF ls_type = "3" Then
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.000"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.000"
		Else
			tab_1.idw_tabpage[10].object.frpoint.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.confee.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee1.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee2.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee3.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee4.Format = "#,##0.0000"
			tab_1.idw_tabpage[10].object.unitfee5.Format = "#,##0.0000"
		End If
		
	Case 11     //착신지 제한번호등록
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_view.TriggerEvent("ue_enable")
End Choose

Return 0
	
end event

event tab_1::constructor;call super::constructor;Integer li_exist
DataWindowChild ldc_priceplan
//help Window
idw_tabpage[1].is_help_win[1] = "b1w_hlp_logid"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.logid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

idw_tabpage[1].is_help_win[2] = "b1w_hlp_payid"
idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.payid
idw_tabpage[1].is_data[2] = "CloseWithReturn"

idw_tabpage[1].is_help_win[3] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[3] = idw_tabpage[1].Object.zipcod
idw_tabpage[1].is_data[3] = "CloseWithReturn"

idw_tabpage[1].is_help_win[4] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[4] = idw_tabpage[1].Object.holder_zipcod
idw_tabpage[1].is_data[4] = "CloseWithReturn"

idw_tabpage[2].is_help_win[1] = "w_hlp_post"
idw_tabpage[2].idwo_help_col[1] = idw_tabpage[2].Object.bil_zipcod
idw_tabpage[2].is_data[1] = "CloseWithReturn"

//가로로 출력 
tab_1.idw_tabpage[3].object.datawindow.print.orientation = 1
tab_1.idw_tabpage[4].object.datawindow.print.orientation = 1
tab_1.idw_tabpage[5].object.datawindow.print.orientation = 1
tab_1.idw_tabpage[6].object.datawindow.print.orientation = 1

li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")

ldc_priceplan.SetTransObject(SQLCA)
ldc_priceplan.Retrieve("I")
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
					
					 ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
				  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
				  If li_exist > 0 Then 
					 f_msg_usr_err(404, title, "")
					 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
					 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
					 Return 0
				 End If
				
					
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
			Case "holder_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
	Case 2
		Choose Case adwo_dwo.name
			Case "bil_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.bil_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.bil_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.bil_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
		
	Case 3

		idw_tabpage[3].accepttext()
		
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		If idw_tabpage[ai_tabpage].object.use_yn[al_row] = 'Y' Then		
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "인증정보수정"
			iu_cust_msg.is_grp_name = "고객등록"
			iu_cust_msg.is_data[1] = Trim(idw_tabpage[ai_tabpage].object.svctype[al_row])  //svctype
			iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]										 //프로그램 ID
			iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row])  //validkey
			iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
		
			OpenWithParm(b1w_reg_validinfo_popup_update_cl, iu_cust_msg)
	
			If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
				Return -1
			End If
			
			tab_1.ib_tabpage_check[3] = True
		End IF
		
		
	Case 5
		
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "신청정보 상세품목"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.orderno[al_row])
		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.ref_contractseq[al_row])
		
		OpenWithParm(b1w_inq_svcorder_popup, iu_cust_msg)
	
	Case 6
		ll_master_row = dw_master.GetSelectedRow(0)
	  	If ll_master_row < 0 Then Return 0
	  
	  	ls_svctype = idw_tabpage[ai_tabpage].object.svcmst_svctype[al_row]
		  
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "계약정보 상세품목"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractseq[al_row])
		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		
		If ls_svctype = is_svctype_pre Then
		  	OpenWithParm(b1w_inq_contmst_popup_pre, iu_cust_msg) 
		Else
		  	OpenWithParm(b1w_inq_contmst_popup, iu_cust_msg) 			
		End If
	
	Case 8
		
		ll_master_row = dw_master.GetSelectedRow(0)
	  	If ll_master_row < 0 Then Return 0
	  
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "할부 내역 상세정보"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractmst_contractseq[al_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[4] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		
		OpenWithParm(b1w_inq_quota_popup, iu_cust_msg) 

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
String ls_svccod, ls_priceplan, ls_customerid, ls_where
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
					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@@@@-@@@@@@@"
					tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.customernm[row]
					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.ssno[row]
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
			Case "addrtype"
					tab_1.idw_tabpage[1].object.holder_addrtype[row] = data
			Case "zipcod"
					tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
			Case "addr1"
					tab_1.idw_tabpage[1].object.holder_addr1[row] = data
			Case "addr2"
					tab_1.idw_tabpage[1].object.holder_addr2[row] = data
		  End Choose
		  
		  //개인이면
		  If lb_check1 Then
				Choose Case dwo.name
					Case "customernm"
						tab_1.idw_tabpage[1].object.holder[row] = data
					Case "zipcode" 
						tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
					Case "ssno"
						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
				End Choose
			ElseIf lb_check2 Then		//법인이면
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
			End If
		
	Case 2		//Tab
		Choose Case dwo.name
			Case "inv_method"
				If is_inv_method = Trim(data) Then
					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(108, 147, 137)
				Else
					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(255, 255, 255)
				End If
				
			 Case "billinginfo_currency_type"
				 
				 ls_payid = tab_1.idw_tabpage[2].object.customerid[1]		//Pay ID
				 
				 Select count(*) into :li_exist from customerm where customerid <> payid and payid = :ls_payid;
				 Select count(*) into :li_exist1 From svcorder where customerid = :ls_payid;
				 If li_exist > 0  Or li_exist1 > 0 Then 
					f_msg_usr_err(404, title, "") 
					//다시 원복 한다.
					tab_1.idw_tabpage[2].object.billinginfo_currency_type[1] = is_currency_old
					tab_1.idw_tabpage[2].SetitemStatus(1, "billinginfo_currency_type", Primary!, NotModified!)   //수정 안되었다고 인식.
					Return 2
				 End If
			
			Case "pay_method"
				Choose case is_pay_method_ori     //변경전데이타
					case is_method    			  //자동이체
						If Trim(data) <> is_pay_method_ori Then   //변경된데이타: 자동이체가 아닌경우
							If is_drawingresult_ori = is_drawingresult[4] Then   //변경전 신청결과가 처리성공인경우
								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			   //신청일자:sysdate
								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[4]         //신청유형:해지
								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]     //신청결과:미처리
								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod              //신청접수처:이용이관
							Else
								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			   //신청일자:sysdate
								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[1]		   //신청유형:없음
								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[1]	   //신청결과:없음
								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			   //신청접수처:이용기관
							End If
						Elseif Trim(data) = is_pay_method_ori Then      //자동이체 -> 지로, 기타 -> 자동이체 일경우가 존재 할 수 있기 때문에...원래대로 setting
								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori
								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori
								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori
								tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori
								tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori	
								tab_1.idw_tabpage[2].Object.bank[1] = is_bank_ori
								tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_ori
								tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_ori
								tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_ori
    					End IF
					case else    //변경전데이타가 자동이체가 아닌경우
						If Trim(data) = is_method Then      //변경한 데이타가 자동이체인 경우
						    //지로/카드->자동이체로 변경시 해지 미처리일때 는  자동이체의 신규 처리성공으로 셋팅...
							If is_drawingtype_ori = is_drawingtype[4] and is_drawingresult_ori = is_drawingresult[2] Then
								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[2]		//신청유형:신규
								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[4]	//신청결과:처리성공
							Else
								ls_ctype2 = Trim(tab_1.idw_tabpage[2].Object.customerm_ctype2[1])
								b1fb_check_control("B0", "P111", "", ls_ctype2,lb_check1)
								b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[2]		//신청유형:신규
								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
								If lb_check1 Then //개인이면 주민등록 번호 필수
									tab_1.idw_tabpage[2].object.acct_ssno[1] = tab_1.idw_tabpage[2].Object.customerm_ssno[1]
								End If	
								If lb_check2 Then //법인이면 사업장 정보 필수					
									tab_1.idw_tabpage[2].object.acct_ssno[1] = tab_1.idw_tabpage[2].Object.customerm_cregno[1]
								End If
							End If
					    Else
							tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori
							tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori
							tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
							tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori
							tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori
							tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori								
    					End IF
				End Choose
				
				lu_check.is_caller   = "b1w_reg_customer%inq_customer_tab2"
				lu_check.is_title    = Title
				lu_check.ii_data[1]  = tab_1.SelectedTab
				lu_check.is_data[1] = is_method
				lu_check.is_data[2] = is_credit
				lu_check.is_data[3] = is_inv_method
				lu_check.is_data[4] = is_chg_flag
				lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
				lu_check.uf_prc_check_1()
				li_rc = lu_check.ii_rc
				If li_rc < 0 Then 
					Destroy lu_check
					Return li_rc
				End If				

			Case "bank_chg"			
				If data = 'Y' Then
					tab_1.idw_tabpage[2].Object.bank.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[2].Object.bank.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acctno.Color = RGB(255, 255, 255)	
					tab_1.idw_tabpage[2].Object.acctno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acct_owner.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[2].Object.acct_owner.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acct_ssno.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[2].Object.acct_ssno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.bank.Protect =0
					tab_1.idw_tabpage[2].Object.acctno.Protect = 0
					tab_1.idw_tabpage[2].Object.acct_owner.Protect =0
					tab_1.idw_tabpage[2].Object.acct_ssno.Protect =0
					tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
					tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[3]		//신청유형:변경
					tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
					tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
				Else
					If is_bank_chg_ori = 'Y' Then
						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_bef				        //은행:before
						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_bef					//계좌번호:before
						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_bef 			//계좌명:before
						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_bef				//계좌주민번호:before
						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_bef		//신청일자:before
						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_bef 		//신청유형:before
						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_bef 	//신청결과:before
						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_bef			//접수처:before
						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_bef 	        //신청접수일자:before
						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_bef			    //신청결과코드:before
					Else
						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_ori					    //은행:origin
						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_ori 					//계좌번호:origin
						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_ori 			//계좌명:origin
						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_ori				//계좌주민번호:origin
						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori		//신청일자:origin
						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori 		//신청유형:origin
						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori 	//신청결과:origin
						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori			//접수처:origin
						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori 	        //신청접수일자:origin
						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori			    //신청결과코드:origin
					End If
					lu_check.is_caller   = "b1w_reg_customer%inq_customer_tab2"
					lu_check.is_title    = Title
					lu_check.ii_data[1]  = tab_1.SelectedTab
					lu_check.is_data[1] = is_method
					lu_check.is_data[2] = is_credit
					lu_check.is_data[3] = is_inv_method
					lu_check.is_data[4] = is_chg_flag
					lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
					lu_check.uf_prc_check_1()
					li_rc = lu_check.ii_rc
					If li_rc < 0 Then 
						Destroy lu_check
						Return li_rc
					End If				
			  End If		
		End Choose
		
	Case 3
		Choose Case dwo.name
			Case "svccod"
				li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			
				ldc_priceplan.SetTransObject(SQLCA)
				ldc_priceplan.Retrieve(data)
				
		End Choose
	
	Case 10
		If (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
			ls_munitsec = "0"
		Else
			ls_munitsec = String(tab_1.idw_tabpage[10].object.munitsec[row])
			If IsNull(ls_munitsec) Then ls_munitsec = ""
		End If
		
		Choose Case dwo.name
			Case "zoncod"
				If data <> "ALL" Then
					tab_1.idw_tabpage[10].Object.areanum[row] = "ALL"
					tab_1.idw_tabpage[10].Object.areanum.Protect = 1
				Else
					tab_1.idw_tabpage[10].Object.areanum[row] = ""
					tab_1.idw_tabpage[10].Object.areanum.Protect = 0
				End If
				
			Case "enddt"
				//적용종료일 체크
				ls_opendt	= Trim(String(tab_1.idw_tabpage[10].Object.opendt[row],'yyyymmdd'))
		
				If data <> "" Then
					If ls_opendt > data Then
						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
						tab_1.idw_tabpage[10].setColumn("enddt")
						tab_1.idw_tabpage[10].setRow(row)
						tab_1.idw_tabpage[10].scrollToRow(row)
						tab_1.idw_tabpage[10].setFocus()
						Return -1
					End If
				End If
				
			Case "unitsec"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitsec[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitsec[row] = Long(data)
				End If
			End If
			
		Case "unitfee"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitfee[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee[row] = Long(data)
				End If
			End If
			
		Case "tmrange1"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.mtmrange1[row] > 0)  Then
					tab_1.idw_tabpage[10].object.mtmrange1[row] = Long(data)
				End If
			End If
			
		Case "unitsec1"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].object.munitsec1[row] > 0) Then
					tab_1.idw_tabpage[10].object.munitsec1[row] = Long(data)
				End If
			End If
		
		Case "unitfee1"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].object.munitfee[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee1[row] = Long(data)
				End If
			End If
			
		Case "tmrange2"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.mtmrange2[row] > 0)  Then
					tab_1.idw_tabpage[10].object.mtmrange2[row] = Long(data)
				End If
			End If
		
			
		Case "unitsec2"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitsec2[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitsec2[row] = Long(data)
				End If
			End If
			
		Case "unitfee2"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitfee2[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee2[row] = Long(data)
				End If
			End If
			
		Case "tmrange3"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.mtmrange3[row] > 0)  Then
					tab_1.idw_tabpage[10].object.mtmrange3[row] = Long(data)
				End If
			End If
			
		Case "unitsec3"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitsec3[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitsec3[row] = Long(data)
				End If
			End If
			
		Case "unitfee3"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitfee3[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee3[row] = Long(data)
				End If
			End If
			
		Case "tmrange4"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.mtmrange4[row] > 0)  Then
					tab_1.idw_tabpage[10].object.mtmrange4[row] = Long(data)
				End If
			End If
			
		Case "unitsec4"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitsec4[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitsec4[row] = Long(data)
				End If
			End If
			
		Case "unitfee4"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitfee4[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee4[row] = Long(data)
				End If
			End If
			
		Case "tmrange5"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.mtmrange5[row] > 0)  Then
					tab_1.idw_tabpage[10].object.mtmrange5[row] = Long(data)
				End If
			End If
			
		Case "unitsec5"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitsec5[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitsec5[row] = Long(data)
				End If
			End If
			
		Case "unitfee5"
			If ls_munitsec = '0' Or ls_munitsec = "" Then
				If NOT(tab_1.idw_tabpage[10].Object.munitfee5[row] > 0)  Then
					tab_1.idw_tabpage[10].object.munitfee5[row] = Long(data)
				End If
			End If
		End Choose
	
	Case 11
		Choose Case dwo.name
			Case "enddt"
				//적용종료일 체크
				ls_opendt	= Trim(String(tab_1.idw_tabpage[11].Object.opendt[row],'yyyymmdd'))
		
				If data <> "" Then
					If ls_opendt > data Then
						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
						tab_1.idw_tabpage[11].setColumn("enddt")
						tab_1.idw_tabpage[11].setRow(row)
						tab_1.idw_tabpage[11].scrollToRow(row)
						tab_1.idw_tabpage[11].setFocus()
						Return -1
					End If
				End If
		End Choose
End Choose
Return 0

end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;String ls_rectype, ls_status

//신청 상태일때만 delete
If ai_tabpage = 3 Then
	If al_row = 0 then Return -1
	
	If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
		 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
	Else
	    tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
		tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
	End If
	
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
End If

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_customer_b
integer y = 868
end type

type p_view from u_p_view within b1w_reg_customer_b
integer x = 914
integer y = 2056
boolean bringtotop = true
string pointer = "HyperLink!"
end type

