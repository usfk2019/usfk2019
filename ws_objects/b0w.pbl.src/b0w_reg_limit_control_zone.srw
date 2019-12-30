$PBExportHeader$b0w_reg_limit_control_zone.srw
$PBExportComments$[ohj] 한도월정액 대상 품목관리
forward
global type b0w_reg_limit_control_zone from w_a_reg_m_m
end type
type p_new from u_p_new within b0w_reg_limit_control_zone
end type
end forward

global type b0w_reg_limit_control_zone from w_a_reg_m_m
event ue_new ( )
p_new p_new
end type
global b0w_reg_limit_control_zone b0w_reg_limit_control_zone

type variables
String is_priceplan		//Price Plan Code

DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfi_check_value (string as_parttype, string as_partcod)
public function integer wfi_get_itemcod (ref string as_itemcod[])
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
end prototypes

event ue_new();//// dw_cond의 그룹선택에 따라 popup 창을 띄우고 선택하면
//// dw_master에 새로운 행을 insert하고 선택한 ID와 명을 셋팅한다.
//String ls_parttype, ls_partcod
//String ls_partner, ls_partnernm, ls_levelcod, ls_logid1, ls_phone, ls_prefixno, ls_credit_yn
//String ls_customernm, ls_customerid, ls_ssno, ls_status, ls_ctype1, ls_payid, ls_logid
//Date   ld_enterdt
//Long   ll_row, ll_cnt, ll_result
//String ls_contno, ls_pid, ls_lotno, ls_status1, ls_partner_prefix
//Date   ld_enddt, ld_issuedt, ld_openusedt
//Dec    lc_balance
//str_item Newparm, Returnparm
//
//ls_parttype = Trim(dw_cond.object.parttype[1])
//
//If ls_parttype = "S" Then
//	
////	Newparm.is_data[1] = "대리점정보"
////	Newparm.is_data[2] = "대리점정보"
//	Newparm.is_data[1]  = "CloseWithReturn"
//	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
//	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
//	
//	OpenWithParm(b0w_reg_particular_zoncst_popup1, Newparm)
//	
//	Returnparm = Message.PowerObjectParm
//	
//	If Returnparm.ib_data[1] Then
//		ls_partcod = Returnparm.is_data[1]
//		
//		ll_result = wfi_check_value(ls_parttype, ls_partcod)
//		If ll_result = -1 Then
//			Return
//		ElseIf ll_result = -2 Then 
//			f_msg_info(9000, Title, "")
//			Return
//		End If
//		
//		ll_row = dw_master.InsertRow(0)
//		dw_master.ScrollToRow(ll_row)
//		dw_detail.Reset()
//	
//		SELECT PARTNER, PARTNERNM, LEVELCOD,
//		       LOGID, PHONE, PREFIXNO,
//				 CREDIT_YN
//		  INTO :ls_partner, :ls_partnernm, :ls_levelcod,
//		       :ls_logid1, :ls_phone, :ls_prefixno,
//	   	    :ls_credit_yn
//		  FROM PARTNERMST
//		 WHERE PARTNER = :ls_partcod ;
//	 
//		If SQLCA.SQLCode <> 0 Then
//			
//			Return
//		Else
//			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_partner
//			dw_master.Object.partnernm[ll_row]                 = ls_partnernm
//			dw_master.Object.levelcod[ll_row]                  = ls_levelcod
//			dw_master.Object.logid[ll_row]                     = ls_logid1
//			dw_master.Object.phone[ll_row]                     = ls_phone
//			dw_master.Object.prefixno[ll_row]                  = ls_prefixno
//			dw_master.Object.credit_yn[ll_row]                 = ls_credit_yn
//			
//			ll_cnt ++
//		End If
//
//	End If
//	
//ElseIf ls_parttype = "C" Then
//
////	iu_cust_msg = Create u_cust_a_msg
//
////	iu_cust_msg.is_pgm_name = "고객정보"
////	iu_cust_msg.is_grp_name = "고객정보"
//	Newparm.is_data[1]  = "CloseWithReturn"
//	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
//	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
//	
//	OpenWithParm(b0w_reg_particular_zoncst_popup, Newparm)
//	
//	Returnparm = Message.PowerObjectParm
//	
//	If Returnparm.ib_data[1] Then
//		ls_partcod = Returnparm.is_data[1]
//		
//		ll_result = wfi_check_value(ls_parttype, ls_partcod)
//		If ll_result = -1 Then
//			Return
//		ElseIf ll_result = -2 Then 
//			f_msg_info(9000, Title, "Customer Already Exists.")
//			Return
//		End If
//		
//		ll_row = dw_master.InsertRow(0)
//		dw_master.ScrollToRow(ll_row)
//		dw_detail.Reset()
//	
//		SELECT CUSTOMERNM, CUSTOMERID, SSNO,
//		       STATUS, CTYPE1, PAYID,
//				 LOGID, ENTERDT
//		  INTO :ls_customernm, :ls_customerid, :ls_ssno,
//		       :ls_status, :ls_ctype1, :ls_payid,
//	   	    :ls_logid, :ld_enterdt
//		  FROM CUSTOMERM
//		 WHERE CUSTOMERID = :ls_partcod ;
//	 
//		If SQLCA.SQLCode <> 0 Then
//			
//			Return
//		Else
//			dw_master.Object.customerm_customernm[ll_row] = ls_customernm
//			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_customerid
//			dw_master.Object.customerm_ssno[ll_row]       = ls_ssno
//			dw_master.Object.customerm_status[ll_row]     = ls_status
//			dw_master.Object.customerm_ctype1[ll_row]     = ls_ctype1
//			dw_master.Object.customerm_payid[ll_row]      = ls_payid
//			dw_master.Object.customerm_payid_1[ll_row]    = ls_payid
//			dw_master.Object.customerm_logid[ll_row]      = ls_logid
//			dw_master.Object.customerm_enterdt[ll_row]    = ld_enterdt
//			
//			ll_cnt++
//		End If
//		
//	End If
//	
//ElseIf ls_parttype = "P" Then
//
////	iu_cust_msg = Create u_cust_a_msg
//
////	iu_cust_msg.is_pgm_name = "선불카드정보"
////	iu_cust_msg.is_grp_name = "선불카드정보"
//	Newparm.is_data[1]  = "CloseWithReturn"
//	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
//	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
//	
//	OpenWithParm(b0w_reg_particular_zoncst_popup2, Newparm)
//	
//	Returnparm = Message.PowerObjectParm
//		
//	If Returnparm.ib_data[1] Then
//		ls_partcod = Returnparm.is_data[1]
//		
//		ll_result = wfi_check_value(ls_parttype, ls_partcod)
//		If ll_result = -1 Then
//			Return
//		ElseIf ll_result = -2 Then 
//			f_msg_info(9000, Title, "Prepaid card(PIN) is already existed.")
//			Return
//		End If
//		
//		ll_row = dw_master.InsertRow(0)
//		dw_master.ScrollToRow(ll_row)
//		dw_detail.Reset()
//	
//		
//	
//		SELECT CONTNO, PID, LOTNO,
//		       STATUS, BALANCE, ENDDT,
//				 ISSUEDT, PARTNER_PREFIX, OPENUSEDT
//		  INTO :ls_contno, :ls_pid, :ls_lotno,
//		       :ls_status1, :lc_balance, :ld_enddt,
//	   	    :ld_issuedt, :ls_partner_prefix, :ld_openusedt
//		  FROM P_CARDMST
//		 WHERE PID = :ls_partcod ;
//	 
//		If SQLCA.SQLCode <> 0 Then
//			
//			Return
//		Else
//			dw_master.Object.contno[ll_row]                    = ls_contno
//			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_pid
//			dw_master.Object.lotno[ll_row]                     = ls_lotno
//			dw_master.Object.status[ll_row]                    = ls_status1
//			dw_master.Object.balance[ll_row]                   = lc_balance
//			dw_master.Object.enddt[ll_row]                     = ld_enddt
//			dw_master.Object.issuedt[ll_row]                   = ld_issuedt
//			dw_master.Object.partner_prefix[ll_row]            = ls_partner_prefix
//			dw_master.Object.openusedt[ll_row]                 = ld_openusedt
//			
//			ll_cnt++
//		End If
//		
//	End If	
//End If
//
//If ll_cnt > 0 Then
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	p_new.TriggerEvent("ue_disable")
//Else
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	p_new.TriggerEvent("ue_enable")
//End If
//	
//
end event

public function integer wfi_check_value (string as_parttype, string as_partcod);//해당 parttype, partcod 를 가지고 기존에 data가 있는지 체크한다.
Long ll_cnt

SELECT COUNT(PARTCOD)
  INTO :ll_cnt
  FROM PARTICULAR_ZONCST
 WHERE PARTTYPE = :as_parttype
   AND PARTCOD  = :as_partcod ;
	
If SQLCA.SQLCode <> 0 Then
	f_msg_usr_err(2100, Title, "Select()")
	Return -1
End If
	
If ll_cnt > 0 Then
	Return -2
End If
	
Return 0
end function

public function integer wfi_get_itemcod (ref string as_itemcod[]);String ls_itemcod
Long ll_rows

ll_rows = 0
DECLARE itemcod CURSOR FOR
				Select det.itemcod
			   From priceplandet det, itemmst item
				Where det.itemcod = item.itemcod
				and item.pricetable <> (select ref_content from sysctl1t where module = 'B0' and Ref_no = 'P100');
   
	Open itemcod;
		 	Do While(True)	
			Fetch itemcod
			into :ls_itemcod;
			
			//error
			 If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(title, " Select Error(PRICEPLANDET)")
				Close itemcod;
				Return -1
			 
			 ElseIf SQLCA.SQLCODE = 100 Then
				exit;
			 End If
			 
			 ll_rows += 1
			 as_itemcod[ll_rows] = ls_itemcod
	
	Loop
CLOSE itemcod;

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

on b0w_reg_limit_control_zone.create
int iCurrent
call super::create
this.p_new=create p_new
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
end on

on b0w_reg_limit_control_zone.destroy
call super::destroy
destroy(this.p_new)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_particular_zoncst
	Desc.	: 	개별 요율등록
	Ver.	:	1.0
	Date	: 	2003.10.06
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
p_new.TriggerEvent("ue_disable")
end event

event ue_ok();call super::ue_ok;String ls_svccod, ls_where, ls_ref_desc, ls_temp, ls_result[], ls_where_1
Long   ll_row, li_i

ls_svccod = Trim(dw_cond.object.svccod[1])

If IsNull(ls_svccod) Then ls_svccod = ""

If ls_svccod = "" Then
	f_msg_info(200, Title, "Service")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
   Return 
End If

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " C.svccod = '" + ls_svccod + "' "

//한도종량제 D,S
ls_ref_desc = ""
ls_temp = fs_get_control("B0","A100", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_where_1 = ""
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then ls_where_1 += " Or "
	ls_where_1 += "A.method = '" + ls_result[li_i] + "'"
Next

If ls_where <> "" Then
	If ls_where_1 <> "" Then ls_where = ls_where + " And ( " + ls_where_1 + " ) "  
Else
	ls_where = ls_where_1
End if

dw_master.SetRedraw(False)

dw_master.is_where = ls_where

//Retrieve
ll_row = dw_master.Retrieve()

dw_master.SetRedraw(True)
dw_master.SetFocus()
dw_master.SelectRow(0, False)
dw_master.ScrollToRow(1)
dw_master.SelectRow(1, True)
	
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
//	This.Trigger Event ue_reset()		//찾기가 없으면 reset
//	Return
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_disable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
	
Else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_disable")
End If


	
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_priceplan, ls_itemcod, ls_target_type
Long ll_row



ll_row = dw_master.GetSelectedRow(0) 

ls_priceplan   = Trim(dw_master.object.priceplan  [ll_row])
ls_itemcod     = Trim(dw_master.object.itemcod    [ll_row])
ls_target_type = Trim(dw_master.object.target_type[ll_row])

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.priceplan[al_insert_row]   = ls_priceplan
dw_detail.object.itemcod[al_insert_row]     = ls_itemcod
dw_detail.object.target_type[al_insert_row] = ls_target_type

// 2004.11.26 ohj  target_type에 따라 dddw 변경
If ls_target_type = 'I' Then
	dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_itemcod_voice'
	dw_detail.object.target_code.dddw.DataColumn    = 'itemcod'
	dw_detail.object.target_code.dddw.DisplayColumn = 'itemnm'
ElseIf ls_target_type = 'Z' Then
	dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_zoncod'
	dw_detail.object.target_code.dddw.DataColumn    = 'zoncod'
	dw_detail.object.target_code.dddw.DisplayColumn = 'zonnm'
End If

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("target_code")

Return 0 
end event

event type integer ue_extra_save();//Save Check
//Save
Long ll_row, ll_rows, ll_findrow
long ll_i, ll_zoncodcnt, i
String ls_target_code
//String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype, ls_enddt, ls_areanum, ls_itemcod
//String ls_date, ls_sort
//Dec lc_data, lc_frpoint, lc_Ofrpoint
//
//String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt, ls_arezoncod1, ls_arezoncodnm
//Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
//String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
//Boolean lb_addX, lb_notExist
//Constant Integer li_MAXTMKIND = 3
//
//String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
//String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
Long   ll_rows1, ll_rows2
//
//If dw_detail.RowCount()  = 0 Then Return 0
//
////  대역/시간대코드/개시일자
//ls_Ozoncod = ""
//ls_Otmcod  = ""
//ls_tmcodX = ""
//li_tmcodcnt = 0
//li_cnt_tmkind = 0
//
////해당 priceplan 찾기
//ls_priceplan = 'ALL'
//
////arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음
//li_return = wfl_get_arezoncod(ls_zoncod, ls_arezoncod[])
//If li_return < 0 Then Return -2
//
ll_rows = dw_detail.RowCount()
//If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0
//
//
////정리하기 위해서 Sort
//dw_detail.SetRedraw(False)
//ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
//dw_detail.SetSort(ls_sort)
//dw_detail.Sort()
//

For ll_row = 1 To ll_rows
	ls_target_code = Trim(dw_detail.Object.target_code[ll_row])

	If IsNull(ls_target_code) Then ls_target_code = ""
	
    //필수 항목 check 
	If ls_target_code = "" Then
		f_msg_usr_err(200, Title, "target code")
		dw_detail.SetColumn("target_code")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If
	
//	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
//	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
//	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
//	ls_areanum = Trim(dw_detail.Object.areanum[ll_row])
//	ls_itemcod = Trim(dw_detail.Object.itemcod[ll_row])
//	ls_enddt  = String(dw_detail.Object.enddt[ll_row])
//	
//	If IsNull(ls_zoncod) Then ls_zoncod = ""
//	If IsNull(ls_opendt) Then ls_opendt = ""
//	If IsNull(ls_tmcod) Then ls_tmcod = ""
//	If IsNull(ls_areanum) Then ls_areanum = ""
//	If IsNull(ls_itemcod) Then ls_itemcod = ""
//	If IsNull(ls_enddt) Then ls_enddt = ""
//	
//    //필수 항목 check 
//	If ls_zoncod = "" Then
//		f_msg_usr_err(200, Title, "Zone")
//		dw_detail.SetColumn("zoncod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//		
//	End If
//	
//	If ls_opendt = "" Then
//		f_msg_usr_err(200, Title, "Effective-From")
//		dw_detail.SetColumn("opendt")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_enddt <> "" Then
//		If ls_opendt > ls_enddt Then
//			f_msg_usr_err(9000, Title, "Effective-To Date Should Be Later Or Equal To Effective-From Date.")
//			dw_detail.setColumn("enddt")
//			dw_detail.setRow(ll_row)
//			dw_detail.scrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//		End If
//	End If
//	
//	If ls_areanum = "" Then
//		f_msg_usr_err(200, Title, "Called Number")
//		dw_detail.SetColumn("areanum")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_tmcod = "" Then
//		f_msg_usr_err(200, Title, "Rate Period")
//		dw_detail.SetColumn("tmcod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//
//	//시작Point - khpark 추가 -
//	lc_frpoint = dw_detail.Object.frpoint[ll_row]
//	If IsNull(lc_frpoint) Then dw_detail.Object.frpoint[ll_row] = 0
//
//	If dw_detail.Object.frpoint[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Usage Tier Should Be More Than 0.")
//		dw_detail.SetColumn("frpoint")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_itemcod = "" Then
//		f_msg_usr_err(200, Title, "Item")
//		dw_detail.SetColumn("itemcod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.unitsec[ll_row] = 0 Then
//		f_msg_usr_err(200, Title, "Initial Increment")
//		dw_detail.SetColumn("unitsec")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.unitfee[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Initial Rate")
//		dw_detail.SetColumn("unitfee")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.munitsec[ll_row] = 0 Then
//		f_msg_usr_err(200, Title, "Initial Increment(Message)")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetColumn("munitsec")		
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.munitfee[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Initial Rate(Message)")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetColumn("munitfee")		
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	// 1 zoncod가 같으면 
//	If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
//		
//		//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
//		If Mid(ls_tmcod, 2, 1) <> Mid(ls_Otmcod, 2, 1) Then
//			f_msg_usr_err(9000, Title, "Same Zone Should Be Same Discount Hours.")
//			dw_detail.SetColumn("tmcod")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//	
//		ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
//			li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
//		End If	// 2 close						
//	
//	// 1 else	
//	Else
//		//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
//		If lb_notExist = False Then
//			lb_notExist = True
//			For ll_i = 1 To UpperBound(ls_arezoncod)
//				If ls_arezoncod[ll_i] = ls_zoncod Then 
//					lb_notExist = False
//					Exit
//				Else
//					ls_arezoncod1 = ls_zoncod
//					ls_arezoncodnm = Trim(dw_detail.object.compute_zone[ll_row])
//				End If
//			Next
//		End If	 // 3 close	
//	  If ls_Ozoncod <>  ls_zoncod Then 
//	      ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
//	   End If
//        
//		// 4 zonecod가  바뀌었거나 처음 row 일때
//		// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
//		If ll_row > 1 Then
//			
//			If ls_tmcodX <> 'X' and Len(ls_tmcodX) <> li_MAXTMKIND Then
//				f_msg_usr_err(9000, Title, "All The Discount Hours Codes Have To Be Registered By Each Day(weekday/weekend/holyday).")
//				dw_detail.SetColumn("tmcod")
//				dw_detail.SetRow(ll_row - 1)
//				dw_detail.ScrollToRow(ll_row - 1)
//				dw_detail.SetRedraw(True)
//				Return -2
//			End If 
//			
//			li_rtmcnt = -1
//			//이미 Select됐된 시간대인지 Check
//			For li_i = 1 To li_cnt_tmkind
//				If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
//			Next
//		
//			// 5 tmcod에 해당 pricecod 별로 tmcod check
//			If li_rtmcnt < 0 Then
//				li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//				If li_return < 0 Then 
//					dw_detail.SetRedraw(True)
//					Return -2
//				End If
//				
//				li_cnt_tmkind += 1
//				ls_tmkind[li_cnt_tmkind,1] = Left(ls_Otmcod, 2)
//				ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
//			End If // 5 close
//			
//			//누락된 시간대코드가 없는지 Check
//			If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//				f_msg_usr_err(9000, Title, "Registered Discount Hours Code Is Not Enough Or It Is Not Registered Discount Hours Code.")
//				dw_detail.SetColumn("tmcod")
//				dw_detail.SetRow(ll_row - 1)
//				dw_detail.ScrollToRow(ll_row - 1)
//				dw_detail.SetRedraw(True)
//				Return -2
//			End If
//	
//			li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
//		    ls_tmcodX = ""
//		Else // 4 else	 
//			li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
//			
//		End If // 4 close
//	End If // 1 close ls_Ozoncod = ls_zoncod 조건 
//	
//	// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
//	If Left(ls_tmcod, 1) = 'X' Then
//		If Len(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
//			f_msg_usr_err(9000, Title, "All Time Cannot Be Used With Other Discount Hours." )
//			dw_detail.SetColumn("tmcod")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//		ElseIf Len(ls_tmcodX) = 0 Then 
//			ls_tmcodX += Left(ls_tmcod, 1)
//		End If
//	Else
//		lb_addX = True
//		For li_i = 1 To Len(ls_tmcodX)
//			If Mid(ls_tmcodX, li_i, 1) = Left(ls_tmcod, 1) Then lb_addX = False
//		Next
//		If lb_addX Then ls_tmcodX += Left(ls_tmcod, 1)
//	End If				
//	
//	ll_findrow = 0
//	If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
//		
//		ll_findrow = dw_detail.Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
//		                            "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
//									"' and frpoint = 0", 1, ll_rows)
//
//		If ll_findrow <= 0 Then
//			f_msg_usr_err(9000, Title, "Usage Tier Value '0' Is Mandatory For Corresponding Zone/Effective-From/Discount Hours." )		
//			dw_detail.SetColumn("frpoint")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			return -2
//		End IF
//		
//	End IF
//		
//	ls_Ozoncod = ls_zoncod
//	ls_Otmcod  = ls_tmcod
//	ls_Oopendt = ls_opendt
Next

//
//// zoncod가 하나만 있을경우 
//If Len(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
//	f_msg_usr_err(9000, Title, "All The Discount Hours Codes Have To Be Registered By Each Day(weekday/weekend/holyday).")
//							
//	dw_detail.SetFocus()
//	dw_detail.SetRedraw(True)
//	Return -2
//End If
//
//li_rtmcnt = -1
////이미 Select됐된 시간대인지 Check
//For li_i = 1 To li_cnt_tmkind
//	If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
//Next
//
////새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
//If li_rtmcnt < 0 Then
//	li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//	If li_return < 0 Then
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//End If
//
////누락된 시간대코드가 없는지 Check
//If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//	f_msg_usr_err(9000, Title, "Registered Discount Hours Code Is Not Enough Or It Is Not Registered Discount Hours Code.")
//						
//	dw_detail.SetColumn("tmcod")
//	dw_detail.SetRow(ll_rows)
//	dw_detail.ScrollToRow(ll_rows)
//	dw_detail.SetRedraw(True)
//	Return -2
//End If
//
////같은 시간대  code error 처리
//ls_Ozoncod = ""
//ls_Otmcod  = ""
//ls_Oopendt = ""
//lc_Ofrpoint = -1
//For ll_row = 1 To ll_rows
//	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
//	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
//	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
//	lc_frpoint = dw_detail.Object.frpoint[ll_row]
//	If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
//		f_msg_usr_err(9000, Title, "Same Zone And Same Discount Hours Use Same Usage Tier.")
//		dw_detail.SetColumn("frpoint")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	ls_Ozoncod = ls_zoncod
//	ls_Oopendt = ls_opendt
//	ls_Otmcod = ls_tmcod
//	lc_Ofrpoint = lc_frpoint
//Next		
//
//If lb_notExist Then
//	If ls_arezoncod1 <> ls_arezoncodnm Then
//		f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//		//Return -2
//	Else
//		If ls_arezoncod1 = "ALL" Then
//			f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//			//Return -2
//		Else
//			f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//			dw_detail.SetFocus()
//			dw_detail.SetRedraw(True)
//			Return -2
//		End If
//	End If
//End If
//
//If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
//	f_msg_info(9000, Title, "You Have To Register The Rate For All Registered Zones.")
//	//Return -2
//End If
//
//ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
//dw_detail.SetSort(ls_sort)
//dw_detail.Sort()
//dw_detail.SetRedraw(True)
//
//
////적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows1 = 1 To dw_detail.RowCount()
//	ls_parttype1  = Trim(dw_detail.object.parttype[ll_rows1])
//	ls_partcod1   = Trim(dw_detail.object.partcod[ll_rows1])
//	ls_zoncod1    = Trim(dw_detail.object.zoncod[ll_rows1])
//	ls_tmcod1     = Trim(dw_detail.object.tmcod[ll_rows1])
//	ls_frpoint1   = String(dw_detail.object.frpoint[ll_rows1])
//	ls_areanum1   = Trim(dw_detail.object.areanum[ll_rows1])
//	ls_itemcod1   = Trim(dw_detail.object.itemcod[ll_rows1])
//	ls_opendt1    = String(dw_detail.object.opendt[ll_rows1], 'yyyymmdd')
//	ls_enddt1     = String(dw_detail.object.enddt[ll_rows1], 'yyyymmdd')
//	
//	If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//	
//	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
//		If ll_rows1 = ll_rows2 Then
//			Exit
//		End If
//		ls_parttype2 = Trim(dw_detail.object.parttype[ll_rows2])
//		ls_partcod2  = Trim(dw_detail.object.partcod[ll_rows2])
//		ls_zoncod2   = Trim(dw_detail.object.zoncod[ll_rows2])
//		ls_tmcod2    = Trim(dw_detail.object.tmcod[ll_rows2])
//		ls_frpoint2  = String(dw_detail.object.frpoint[ll_rows2])
//		ls_areanum2  = Trim(dw_detail.object.areanum[ll_rows2])
//		ls_itemcod2  = Trim(dw_detail.object.itemcod[ll_rows2])
//		ls_opendt2   = String(dw_detail.object.opendt[ll_rows2], 'yyyymmdd')
//		ls_enddt2    = String(dw_detail.object.enddt[ll_rows2], 'yyyymmdd')
//		
//		If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//		
//		If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
//			And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
//			
//			If ls_enddt1 >= ls_opendt2 Then
//				f_msg_info(9000, Title, "Same Zone[ " + ls_zoncod1 + " ], Same Discount[ " + ls_tmcod1 + " ], " &
//												+ "Same Usage Tier[ " + ls_frpoint1 + " ], Same Item[ " + ls_itemcod1 + " ] Use Same Effective-From Date.")
//				Return -2
//			End If
//		End If
//		
//	Next
	//Update Log
	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
	End If
	
Next



Return 0
end event

event resize;//2000-06-28 by kem
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)


If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_new.Y	   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_new.Y	   = newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.svccod[1] = ""

//p_new.TriggerEvent("ue_disable")

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
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
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
	
	 dw_detail.ResetUpdate()
	 dw_detail.ReSet()
    This.Trigger Event ue_ok()
	 
	f_msg_info(3000,This.Title,"Save")
End if

//ii_error_chk = 0
//p_new.TriggerEvent("ue_enable")

Return 0

end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
//Int li_return

//ii_error_chk = -1
ll_row = dw_master.GetSelectedRow(0) 

//2004.11.26 ohj master에서 타켓 type지정하지 않으면 insertrow 할 수 없다. 
If IsNull(dw_master.object.target_type[ll_row]) Then 
		f_msg_usr_err(200, Title, "target type")
		dw_master.SetColumn("target_type")
	Return 1
End If

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

Return 0
//ii_error_chk = 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_limit_control_zone
integer x = 46
integer y = 60
integer width = 1701
integer height = 124
string dataobject = "b0dw_cnd_limit_control_zone"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;
If Lower(dwo.name) = "parttype" Then
	Choose Case data
		Case "S"
			This.Object.partcod_t.Text     = "Agent"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_partner"
			is_data[1] = "CloseWithReturn"
			
		Case "C"
			This.Object.partcod_t.Text     = "Customer ID"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_customerm"
			is_data[1] = "CloseWithReturn"
			
		Case "P"
			This.Object.partcod_t.Text     = "Pin"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_cardmst"
			is_data[1] = "CloseWithReturn"
	End Choose
	
End If
			
		

end event

event dw_cond::ue_init();call super::ue_init;//고객 help popup
//idwo_help_col[1] = Object.partcod
//is_help_win[1] = "b1w_hlp_customerm"
//is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//String ls_parttype
//
//This.AcceptText()
//
//ls_parttype = Trim(This.Object.parttype[1])
//
//If IsNull(ls_parttype) Or ls_parttype = "" Then
//	f_msg_info(200, Title, "Group")
//	This.SetFocus()
//	This.SetColumn("parttype")
//	Return
//End If
//
//If ls_parttype = "C" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[2]
//			End If
//	End Choose
//	
//ElseIf ls_parttype = "S" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[2]
//			End If 
//
//	End Choose
//	
//ElseIf ls_parttype = "P" Then
//	Choose Case dwo.Name
//		Case "partcod"
//			If iu_cust_help.ib_data[1] Then
//				This.Object.partcod1[row] = iu_cust_help.is_data[1]
//				This.Object.partcod[row] = iu_cust_help.is_data[1]
//			End If
//
//	End Choose
//	
//End If
end event

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_limit_control_zone
integer x = 2057
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_limit_control_zone
integer x = 2363
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_limit_control_zone
integer x = 23
integer y = 4
integer width = 1934
integer height = 212
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_limit_control_zone
integer x = 23
integer y = 256
integer height = 448
string dataobject = "b0dw_cnd_reg_limit_control_zone"
boolean ib_sort_use = false
end type

event dw_master::ue_init();call super::ue_init;////Sort
//dwObject ldwo_sort
//ldwo_sort = Object.partnernm_t
//uf_init(ldwo_sort)

end event

event dw_master::rowfocuschanged;call super::rowfocuschanged;
If currentrow = 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
End If
end event

event dw_master::retrieveend;String ls_parttype

If rowcount >= 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
	
End If
end event

event dw_master::doubleclicked;// 2004.11.26 ohj target_type이 입력되어 있는 경우 변경 안됨. 
String  ls_check_gubun

If row = 0 Then Return 1

ls_check_gubun = dw_master.object.check_gubun[row]

If ls_check_gubun <> "" Then Return 1

If dw_detail.Rowcount() >= 1 Then return 1

end event

event dw_master::clicked;call super::clicked;// 2004.11.26 ohj target_type이 입력되어 있는 경우 변경 안됨. 
String  ls_check_gubun

//If row = 0 Then Return 1
If row <> 0 Then
	ls_check_gubun = dw_master.object.check_gubun[row]
	If ls_check_gubun <> "" Then Return 1

	If dw_detail.Rowcount() >= 1 Then return 1
End If



end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_limit_control_zone
integer x = 23
integer y = 736
integer height = 900
string dataobject = "b0dw_reg_limit_control_zone"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_priceplan, ls_itemcod, ls_filter, ls_method, ls_target_type
String ls_type
Long ll_row, i
Integer li_cnt
Dec{0} lc_data
DataWindowChild ldc

dw_master.AcceptText()

If dw_master.RowCount() > 0 Then
	ls_priceplan   = Trim(dw_master.object.priceplan[al_select_row])
	ls_itemcod     = Trim(dw_master.object.itemcod  [al_select_row])	
	ls_target_type = Trim(dw_master.object.target_type[al_select_row])	
	
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_itemcod)   Then ls_itemcod = ""

	ls_where = ""

	If ls_priceplan <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " A.PRICEPLAN = '" + ls_priceplan + "' "

	End If
	If ls_itemcod <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " A.ITEMCOD = '" + ls_itemcod + "' "

	End If
		// 2004.11.26 ohj  target_type에 따라 dddw 변경
	If ls_target_type = 'I' Then
		dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_itemcod_voice'
		dw_detail.object.target_code.dddw.DataColumn    = 'itemcod'
		dw_detail.object.target_code.dddw.DisplayColumn = 'itemnm'
   ElseIf ls_target_type = 'Z' Then
		dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_zoncod'
		dw_detail.object.target_code.dddw.DataColumn    = 'zoncod'
		dw_detail.object.target_code.dddw.DisplayColumn = 'zonnm'
	End If
	
	//dw_detail 조회
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	dw_detail.SetRedraw(False)
	If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
	End If
	
	// 2004.11.26 ohj  target_type에 따라 dddw 변경
	If ls_target_type = 'I' Then
		dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_itemcod_voice'
		dw_detail.object.target_code.dddw.DataColumn    = 'itemcod'
		dw_detail.object.target_code.dddw.DisplayColumn = 'itemnm'
   ElseIf ls_target_type = 'Z' Then
		dw_detail.object.target_code.dddw.name          = 'b0dc_dddw_zoncod'
		dw_detail.object.target_code.dddw.DataColumn    = 'zoncod'
		dw_detail.object.target_code.dddw.DisplayColumn = 'zonnm'
	End If
	
	For i = 1 To dw_detail.RowCount()
		dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
	Next
   
	dw_detail.SetRedraw(true)

End If

Return 0
	
end event

event dw_detail::itemchanged;call super::itemchanged;//String ls_opendt, ls_munitsec
//Long ll_range1, ll_range2, ll_range3, ll_range4, ll_range5, ll_mod
//
//If (dw_detail.GetItemStatus(row, 0, Primary!) = New!) Or (This.GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//	ls_munitsec = "0"
//Else
//	ls_munitsec = String(This.object.munitsec[row])
//	If IsNull(ls_munitsec) Then ls_munitsec = ""
//End If
//
//Choose Case dwo.name
//	// 대역이 ALL 이면 착신지번호(특번) 필수입력
//	// 대역이 ALL 이 아니면 착신지번호는 ALL로 셋팅
//	Case "zoncod"
//		If data = 'ALL'  Then 
//			This.Object.areanum[row] = ""
//			This.Object.areanum.Protect = 0 
//		Else
//			This.Object.areanum[row] = 'ALL'
//			This.Object.areanum.Protect = 1
//		End If
//
//	Case "unitsec"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec[row] > 0)  Then
//				This.object.munitsec[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitfee"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee[row] > 0)  Then
//				This.object.munitfee[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange1[row] > 0)  Then
//				This.object.mtmrange1[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.object.munitsec1[row] > 0) Then
//				This.object.munitsec1[row] = Long(data)
//			End If
//		End If
//		
//		ll_range1 = This.object.tmrange1[row]
//		
//		If ll_range1 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range1, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetColumn("tmrange1")
//				Return -1
//			End If
//		End If
//	
//	Case "unitfee1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.object.munitfee1[row] > 0)  Then
//				This.object.munitfee1[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange2[row] > 0)  Then
//				This.object.mtmrange2[row] = Long(data)
//			End If
//		End If
//	
//		
//	Case "unitsec2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec2[row] > 0)  Then
//				This.object.munitsec2[row] = Long(data)
//			End If
//		End If
//		
//		ll_range2 = This.object.tmrange2[row]
//		
//		If ll_range2 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range2, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange2")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee2[row] > 0)  Then
//				This.object.munitfee2[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange3[row] > 0)  Then
//				This.object.mtmrange3[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec3[row] > 0)  Then
//				This.object.munitsec3[row] = Long(data)
//			End If
//		End If
//		
//		ll_range3 = This.object.tmrange3[row]
//		
//		If ll_range3 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range3, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange3")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee3[row] > 0)  Then
//				This.object.munitfee3[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange4[row] > 0)  Then
//				This.object.mtmrange4[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec4[row] > 0)  Then
//				This.object.munitsec4[row] = Long(data)
//			End If
//		End If
//		
//		ll_range4 = This.object.tmrange4[row]
//		
//		If ll_range4 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range4, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange4")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee4[row] > 0)  Then
//				This.object.munitfee4[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange5[row] > 0)  Then
//				This.object.mtmrange5[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec5[row] > 0)  Then
//				This.object.munitsec5[row] = Long(data)
//			End If
//		End If
//		
//		ll_range5 = This.object.tmrange5[row]
//		
//		If ll_range5 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range5, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange5")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee5[row] > 0)  Then
//				This.object.munitfee5[row] = Long(data)
//			End If
//		End If
//		
//End Choose
//
//Return 0
end event

event dw_detail::retrieveend;call super::retrieveend;Long ll_row, i
String ls_filter, ls_target_type
Dec lc_data

If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
		
ElseIf rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
   dw_cond.Enabled = False

End If


end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_limit_control_zone
integer y = 1660
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_limit_control_zone
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_limit_control_zone
integer x = 617
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_limit_control_zone
integer x = 1353
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_limit_control_zone
integer y = 704
integer height = 36
end type

type p_new from u_p_new within b0w_reg_limit_control_zone
boolean visible = false
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

