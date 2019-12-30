$PBExportHeader$b0w_reg_particular_zoncst_v20.srw
$PBExportComments$[ohj] 개별 요율 등록 v20
forward
global type b0w_reg_particular_zoncst_v20 from w_a_reg_m_m
end type
type p_new from u_p_new within b0w_reg_particular_zoncst_v20
end type
end forward

global type b0w_reg_particular_zoncst_v20 from w_a_reg_m_m
event ue_new ( )
p_new p_new
end type
global b0w_reg_particular_zoncst_v20 b0w_reg_particular_zoncst_v20

type variables
String is_priceplan		//Price Plan Code
String is_svccod_control
DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfi_get_itemcod (ref string as_itemcod[])
public function integer wfi_check_value (string as_parttype, string as_partcod)
public function integer wfl_get_arezoncod (string as_svccod, string as_priceplan, ref string as_arezoncod[])
end prototypes

event ue_new();// dw_cond의 그룹선택에 따라 popup 창을 띄우고 선택하면
// dw_master에 새로운 행을 insert하고 선택한 ID와 명을 셋팅한다.
String ls_parttype, ls_partcod
String ls_partner, ls_partnernm, ls_levelcod, ls_logid1, ls_phone, ls_prefixno, ls_credit_yn
String ls_customernm, ls_customerid, ls_ssno, ls_status, ls_ctype1, ls_payid, ls_logid
Date   ld_enterdt
Long   ll_row, ll_cnt, ll_result
String ls_contno, ls_pid, ls_lotno, ls_status1, ls_partner_prefix, ls_priceplan
Date   ld_enddt, ld_issuedt, ld_openusedt
Dec    lc_balance
str_item Newparm, Returnparm

ls_parttype = Trim(dw_cond.object.parttype[1])

If ls_parttype = "S" Then
	
//	Newparm.is_data[1] = "대리점정보"
//	Newparm.is_data[2] = "대리점정보"
	Newparm.is_data[1]  = "CloseWithReturn"
	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
	
	OpenWithParm(b0w_reg_particular_zoncst_popup1, Newparm)
	
	Returnparm = Message.PowerObjectParm
	
	If Returnparm.ib_data[1] Then
		ls_partcod = Returnparm.is_data[1]
		
		ll_result = wfi_check_value(ls_parttype, ls_partcod)
		If ll_result = -1 Then
			Return
		ElseIf ll_result = -2 Then 
			f_msg_info(9000, Title, "기존에 해당하는 대리점이 존재합니다.")
			Return
		End If
		
		ll_row = dw_master.InsertRow(0)
		dw_master.ScrollToRow(ll_row)
		dw_detail.Reset()
	
		SELECT PARTNER, PARTNERNM, LEVELCOD,
		       LOGID, PHONE, PREFIXNO,
				 CREDIT_YN
		  INTO :ls_partner, :ls_partnernm, :ls_levelcod,
		       :ls_logid1, :ls_phone, :ls_prefixno,
	   	    :ls_credit_yn
		  FROM PARTNERMST
		 WHERE PARTNER = :ls_partcod ;
	 
		If SQLCA.SQLCode <> 0 Then
			
			Return
		Else
			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_partner
			dw_master.Object.partnernm[ll_row]                 = ls_partnernm
			dw_master.Object.levelcod[ll_row]                  = ls_levelcod
			dw_master.Object.logid[ll_row]                     = ls_logid1
			dw_master.Object.phone[ll_row]                     = ls_phone
			dw_master.Object.prefixno[ll_row]                  = ls_prefixno
			dw_master.Object.credit_yn[ll_row]                 = ls_credit_yn
			
			ll_cnt ++
		End If

	End If
	
ElseIf ls_parttype = "C" Then

//	iu_cust_msg = Create u_cust_a_msg

//	iu_cust_msg.is_pgm_name = "고객정보"
//	iu_cust_msg.is_grp_name = "고객정보"
	Newparm.is_data[1]  = "CloseWithReturn"
	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
	
	OpenWithParm(b0w_reg_particular_zoncst_popup, Newparm)
	
	Returnparm = Message.PowerObjectParm
	
	If Returnparm.ib_data[1] Then
		ls_partcod = Returnparm.is_data[1]
		
		ll_result = wfi_check_value(ls_parttype, ls_partcod)
		If ll_result = -1 Then
			Return
		ElseIf ll_result = -2 Then 
			f_msg_info(9000, Title, "기존에 해당하는 고객이 존재합니다.")
			Return
		End If
		
		ll_row = dw_master.InsertRow(0)
		dw_master.ScrollToRow(ll_row)
		dw_detail.Reset()
	
		SELECT CUSTOMERNM, CUSTOMERID, SSNO,
		       STATUS, CTYPE1, PAYID,
				 LOGID, ENTERDT
		  INTO :ls_customernm, :ls_customerid, :ls_ssno,
		       :ls_status, :ls_ctype1, :ls_payid,
	   	    :ls_logid, :ld_enterdt
		  FROM CUSTOMERM
		 WHERE CUSTOMERID = :ls_partcod ;
	 
		If SQLCA.SQLCode <> 0 Then
			
			Return
		Else
			dw_master.Object.customerm_customernm[ll_row] = ls_customernm
			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_customerid
			dw_master.Object.customerm_ssno[ll_row]       = ls_ssno
			dw_master.Object.customerm_status[ll_row]     = ls_status
			dw_master.Object.customerm_ctype1[ll_row]     = ls_ctype1
			dw_master.Object.customerm_payid[ll_row]      = ls_payid
			dw_master.Object.customerm_payid_1[ll_row]    = ls_payid
			dw_master.Object.customerm_logid[ll_row]      = ls_logid
			dw_master.Object.customerm_enterdt[ll_row]    = ld_enterdt
			
			ll_cnt++
		End If
		
	End If
	
ElseIf ls_parttype = "P" Then

//	iu_cust_msg = Create u_cust_a_msg

//	iu_cust_msg.is_pgm_name = "선불카드정보"
//	iu_cust_msg.is_grp_name = "선불카드정보"
	Newparm.is_data[1]  = "CloseWithReturn"
	Newparm.is_data[2]  = Trim(dw_cond.object.partcod[1])
	Newparm.is_data[3]  = gs_pgm_id[gi_open_win_no]			//프로그램 ID
	
	OpenWithParm(b0w_reg_particular_zoncst_popup2, Newparm)
	
	Returnparm = Message.PowerObjectParm
		
	If Returnparm.ib_data[1] Then
		ls_partcod = Returnparm.is_data[1]
		
		ll_result = wfi_check_value(ls_parttype, ls_partcod)
		If ll_result = -1 Then
			Return
		ElseIf ll_result = -2 Then 
			f_msg_info(9000, Title, "기존에 해당하는 선불카드(PIN)가 존재합니다.")
			Return
		End If
		
		ll_row = dw_master.InsertRow(0)
		dw_master.ScrollToRow(ll_row)
		dw_detail.Reset()
	
		
	
		SELECT CONTNO, PID, LOTNO,
		       STATUS, BALANCE, ENDDT,
				 ISSUEDT, PARTNER_PREFIX, OPENUSEDT, PRICEPLAN
		  INTO :ls_contno, :ls_pid, :ls_lotno,
		       :ls_status1, :lc_balance, :ld_enddt,
	   	    :ld_issuedt, :ls_partner_prefix, :ld_openusedt, :ls_priceplan
		  FROM P_CARDMST
		 WHERE PID = :ls_partcod ;
	 
		If SQLCA.SQLCode <> 0 Then
			
			Return
		Else
			dw_master.Object.contno[ll_row]                    = ls_contno
			dw_master.Object.particular_zoncst_partcod[ll_row] = ls_pid
			dw_master.Object.lotno[ll_row]                     = ls_lotno
			dw_master.Object.status[ll_row]                    = ls_status1
			dw_master.Object.balance[ll_row]                   = lc_balance
			dw_master.Object.enddt[ll_row]                     = ld_enddt
			dw_master.Object.issuedt[ll_row]                   = ld_issuedt
			dw_master.Object.partner_prefix[ll_row]            = ls_partner_prefix
			dw_master.Object.openusedt[ll_row]                 = ld_openusedt
			dw_master.Object.priceplan[ll_row]                 = ls_priceplan
			
			ll_cnt++
		End If
		
	End If	
End If

If ll_cnt > 0 Then
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_disable")
Else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_enable")
End If
	

end event

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

public function integer wfl_get_arezoncod (string as_svccod, string as_priceplan, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

//If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE svccod     = :as_svccod
  and priceplan  = :as_priceplan;
//  and zoncod like :as_zoncod;

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

on b0w_reg_particular_zoncst_v20.create
int iCurrent
call super::create
this.p_new=create p_new
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
end on

on b0w_reg_particular_zoncst_v20.destroy
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
String ls_desc
dw_cond.object.partcod_t.Text = '그룹'

p_new.TriggerEvent("ue_disable")

dw_cond.object.svccod_t.visible = False
dw_cond.object.svccod.visible   = False

is_svccod_control = fs_get_control("00", "Z150" , ls_desc)
end event

event ue_ok();call super::ue_ok;//그룹선택별 요금 조회
String ls_parttype, ls_partcod, ls_zoncod, ls_where, ls_partcod1, ls_svccod
Long ll_row

ls_parttype = Trim(dw_cond.object.parttype[1])
ls_partcod1 = Trim(dw_cond.object.partcod1[1])
If IsNull(ls_partcod1) Or ls_partcod1 = "" Then
	dw_cond.object.partcod1[1] = Trim(dw_cond.object.partcod[1])
End If
ls_partcod  = Trim(dw_cond.object.partcod1[1])
ls_zoncod   = Trim(dw_cond.object.zoncod[1])
ls_svccod   = Trim(dw_cond.object.svccod[1])

If IsNull(ls_parttype) Then ls_parttype = ""
If IsNull(ls_partcod)  Then ls_partcod  = ""
If IsNull(ls_zoncod)   Then ls_zoncod   = ""
If IsNull(ls_svccod)   Then ls_svccod   = ""

If ls_parttype = "" Then
	f_msg_info(200, Title, "그룹선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
   Return 
End If

If ls_parttype = "S" Or ls_parttype = "C"  Then 
	If ls_svccod = "" Then
		f_msg_info(200, Title, "서비스선택")
		dw_cond.SetFocus()
		dw_cond.SetColumn("svccod")
		Return 
	End If
End If
	
ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " A.parttype = '" + ls_parttype + "' "

If ls_partcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.partcod = '" + ls_partcod + "' "
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.zoncod = '" + ls_zoncod + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.SVCCOD = '" + ls_svccod + "' "
End If

dw_master.SetRedraw(False)

//데이터 윈도우 바꾸기 
If ls_parttype = "S"  Then 
	dw_master.DataObject = "b0dw_cnd_reg_particular_zoncst1_v20"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
ElseIf ls_parttype = "C" Then
	dw_master.DataObject = "b0dw_cnd_reg_particular_zoncst_v20"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
ElseIf ls_parttype = "P" Then
	dw_master.DataObject = "b0dw_cnd_reg_particular_zoncst2_v20"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
End If

//Retrieve
ll_row = dw_master.Retrieve()

dw_master.SetRedraw(True)

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
//	This.Trigger Event ue_reset()		//찾기가 없으면 reset
//	Return
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_enable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
	
Else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_new.TriggerEvent("ue_enable")
End If


	
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;DataWindowChild ldc_zoncod, ldc_tmcod, ldc_itemcod
String ls_partcod, ls_parttype, ls_svccod, ls_priceplan, ls_filter
Long ll_row


//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("zoncod")

ll_row = dw_master.GetSelectedRow(0) 
ls_partcod = Trim(dw_master.object.particular_zoncst_partcod[ll_row])

ls_parttype = dw_cond.object.parttype[1]

If ls_parttype = "P" Then
//	ls_svccod    = dw_master.object.svccod[dw_master.Getrow()]
	ls_priceplan = dw_master.object.priceplan[dw_master.Getrow()]
	
	 select svccod 
	  into :ls_svccod 
	  from priceplanmst
	 where priceplan = :ls_priceplan ;
	 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select priceplanmst Table")
		Return -1
	End If	
	
	dw_detail.object.svccod[al_insert_row] = ls_svccod
	//ls_partcod = trim(dw_master.object.pid[ll_row])
	
Else		
	ls_svccod    = dw_cond.object.svccod[1]
	ls_priceplan = 'ALL'
	
	dw_detail.object.svccod[al_insert_row] = ls_svccod
End If

//If ls_parttype = "C" Then
//	//ls_partcod = trim(dw_master.object.customerid[ll_row])
//	
//ElseIf ls_parttype = "S" Then
//	ls_partcod = trim(dw_master.object.partner[ll_row])
//End If

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.parttype[al_insert_row]  = Trim(dw_cond.object.parttype[1])
dw_detail.object.partcod[al_insert_row]   = ls_partcod
dw_detail.object.opendt[al_insert_row]    = Date(fdt_get_dbserver_now())
dw_detail.object.roundflag[al_insert_row] = "U"
dw_detail.object.frpoint[al_insert_row]   = 0
dw_detail.object.unitsec[al_insert_row]   = 0
dw_detail.object.unitfee[al_insert_row]   = 0


	
	dw_detail.Modify("zoncod.dddw.name=''")
	dw_detail.Modify("zoncod.dddw.DataColumn=''")
	dw_detail.Modify("zoncod.dddw.DisplayColumn=''")

	dw_detail.Modify("zoncod.dddw.name=b0dc_dddw_zoncod_svccod_v20")
	dw_detail.Modify("zoncod.dddw.DataColumn='zoncod'")
	dw_detail.Modify("zoncod.dddw.DisplayColumn='zonnm'")	

	ll_row = dw_detail.GetChild("zoncod", ldc_zoncod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	ls_filter = "svccod = '" + ls_svccod + "' "
	ldc_zoncod.SetFilter(ls_filter)			//Filter정함
	ldc_zoncod.Filter()
	ldc_zoncod.SetTransObject(SQLCA)
	ll_row =ldc_zoncod.Retrieve()
	
	dw_detail.Modify("tmcod.dddw.name=''")
	dw_detail.Modify("tmcod.dddw.DataColumn=''")
	dw_detail.Modify("tmcod.dddw.DisplayColumn=''")

	dw_detail.Modify("tmcod.dddw.name=b0dc_dddw_tmcod_v20")
	dw_detail.Modify("tmcod.dddw.DataColumn='tmcod'")
	dw_detail.Modify("tmcod.dddw.DisplayColumn='codenm'")	
	
	ll_row = dw_detail.GetChild("tmcod", ldc_tmcod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	ls_filter = "svccod = '" + ls_svccod + "' and priceplan = '" +ls_priceplan+"'"

	ldc_tmcod.SetFilter(ls_filter)			//Filter정함
	ldc_tmcod.Filter()
	ldc_tmcod.SetTransObject(SQLCA)
	ll_row =ldc_tmcod.Retrieve()	
	
	//svccod 별 item가져오기
	ll_row = dw_detail.GetChild("itemcod", ldc_itemcod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
	ls_filter = "svccod = '" + ls_svccod + "' "
	ldc_itemcod.SetFilter(ls_filter)			//Filter정함
	ldc_itemcod.Filter()
	ldc_itemcod.SetTransObject(SQLCA)
	ll_row =ldc_itemcod.Retrieve()
	
Return 0 
end event

event type integer ue_extra_save();//Save Check
//Save
Long ll_row, ll_rows, ll_findrow
long ll_i, ll_zoncodcnt, i, ll_surrate
String ls_zoncod, ls_tmcod, ls_opendt, ls_priceplan, ls_parttype, ls_enddt, ls_areanum, ls_itemcod
String ls_date, ls_sort
Dec lc_data, lc_frpoint, lc_Ofrpoint

String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt, ls_arezoncod1, ls_arezoncodnm
Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
Boolean lb_addX, lb_notExist
Constant Integer li_MAXTMKIND = 3

String ls_parttype1, ls_partcod1, ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
String ls_parttype2, ls_partcod2, ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
String ls_svccod
Long   ll_rows1, ll_rows2

If dw_detail.RowCount()  = 0 Then Return 0

//  대역/시간대코드/개시일자
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_tmcodX = ""
li_tmcodcnt = 0
li_cnt_tmkind = 0

//해당 priceplan 찾기
//ls_priceplan = 'ALL'
//
//ls_svccod = dw_master.Object.svccod[dw_master.Getrow()]
//arezoncod에서 해당 pricecod와 zoncod로 arecod 코드 찾음

ls_parttype = dw_cond.Object.parttype[1]

//If ls_parttype = "P" Then
//	ls_svccod    = dw_master.object.svccod[dw_master.Getrow()]
//	ls_priceplan = dw_master.object.priceplan[dw_master.Getrow()]
//Else		
//	ls_svccod    = dw_cond.object.svccod[1]
//	ls_priceplan = 'ALL'
//End If
If ls_parttype = "P" Then
//	ls_svccod    = dw_master.object.svccod[dw_master.Getrow()]
	ls_priceplan = dw_master.object.priceplan[dw_master.Getrow()]
	
	 select svccod 
	  into :ls_svccod 
	  from priceplanmst
	 where priceplan = :ls_priceplan ;
	 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select priceplanmst Table")
		Return -1
	End If	
	
	//dw_detail.object.svccod[al_insert_row] = ls_svccod
	//ls_partcod = trim(dw_master.object.pid[ll_row])
	
Else		
	ls_svccod    = dw_cond.object.svccod[1]
	ls_priceplan = 'ALL'
	
	//dw_detail.object.svccod[al_insert_row] = ls_svccod
End If
	
	
//li_return = wfl_get_arezoncod(ls_svccod, ls_zoncod, ls_arezoncod[])
li_return = wfl_get_arezoncod(ls_svccod, ls_priceplan, ls_arezoncod[])
If li_return < 0 Then Return -2

ll_rows = dw_detail.RowCount()
If ll_rows < 1 And UpperBound(ls_arezoncod) < 1 Then Return 0


//정리하기 위해서 Sort
dw_detail.SetRedraw(False)
ls_sort = "zoncod, string(opendt,'yyyymmdd'), tmcod, frpoint"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()

For ll_row = 1 To ll_rows
	ll_surrate = dw_detail.Object.surrate[ll_row]
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
	ls_areanum = Trim(dw_detail.Object.areanum[ll_row])
	ls_itemcod = Trim(dw_detail.Object.itemcod[ll_row])
	ls_enddt  = String(dw_detail.Object.enddt[ll_row])
	
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If IsNull(ls_opendt) Then ls_opendt = ""
	If IsNull(ls_tmcod) Then ls_tmcod = ""
	If IsNull(ls_areanum) Then ls_areanum = ""
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	If IsNull(ls_enddt) Then ls_enddt = ""
	
    //필수 항목 check 
	If ls_zoncod = "" Then
		f_msg_usr_err(200, Title, "대역")
		dw_detail.SetColumn("zoncod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
		
	End If
	
	If ls_opendt = "" Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If ls_enddt <> "" Then
		If ls_opendt > ls_enddt Then
			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
			dw_detail.setColumn("enddt")
			dw_detail.setRow(ll_row)
			dw_detail.scrollToRow(ll_row)
			dw_detail.SetRedraw(True)
			Return -2
		End If
	End If
	
	If ls_areanum = "" Then
		f_msg_usr_err(200, Title, "착신지번호")
		dw_detail.SetColumn("areanum")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If ls_tmcod = "" Then
		f_msg_usr_err(200, Title, "시간대")
		dw_detail.SetColumn("tmcod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If

	//시작Point - khpark 추가 -
	lc_frpoint = dw_detail.Object.frpoint[ll_row]
	If IsNull(lc_frpoint) Then dw_detail.Object.frpoint[ll_row] = 0

	If dw_detail.Object.frpoint[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "사용범위는 0보다 커야 합니다.")
		dw_detail.SetColumn("frpoint")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If ll_surrate < 0 Then
		f_msg_usr_err(200, Title, "Surcharge(%)")
		dw_detail.SetColumn("surrate")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title, "품목")
		dw_detail.SetColumn("itemcod")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If dw_detail.Object.unitsec[ll_row] = 0 Then
		f_msg_usr_err(200, Title, "기본시간")
		dw_detail.SetColumn("unitsec")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If dw_detail.Object.unitfee[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "기본요금")
		dw_detail.SetColumn("unitfee")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If dw_detail.Object.munitsec[ll_row] = 0 Then
		f_msg_usr_err(200, Title, "기본시간(멘트)")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("munitsec")		
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	If dw_detail.Object.munitfee[ll_row] < 0 Then
		f_msg_usr_err(200, Title, "기본요금(멘트)")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("munitfee")		
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	// 1 zoncod가 같으면 
	If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
		
		//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
		If MidA(ls_tmcod, 2, 1) <> MidA(ls_Otmcod, 2, 1) Then
			f_msg_usr_err(9000, Title, "동일한 대역은 시간대코드의 구분이 동일해야합니다.")
			dw_detail.SetColumn("tmcod")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
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
				Else
					ls_arezoncod1 = ls_zoncod
					ls_arezoncodnm = Trim(dw_detail.object.compute_zone[ll_row])
				End If
			Next
		End If	 // 3 close	
	  If ls_Ozoncod <>  ls_zoncod Then 
	      ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
	   End If
        
		// 4 zonecod가  바뀌었거나 처음 row 일때
		// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
		If ll_row > 1 Then
		//오 막음	1
//			If ls_tmcodX <> 'X' and Len(ls_tmcodX) <> li_MAXTMKIND Then
//				f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
//				dw_detail.SetColumn("tmcod")
//				dw_detail.SetRow(ll_row - 1)
//				dw_detail.ScrollToRow(ll_row - 1)
//				dw_detail.SetRedraw(True)
//				Return -2
//			End If 
			//여기까지1
			
			li_rtmcnt = -1
			//이미 Select됐된 시간대인지 Check
			For li_i = 1 To li_cnt_tmkind
				If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
			Next
		
			// 5 tmcod에 해당 pricecod 별로 tmcod check
			If li_rtmcnt < 0 Then
				li_return = b0fi_chk_tmcod_v20(ls_svccod, ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
				If li_return < 0 Then 
					dw_detail.SetRedraw(True)
					Return -2
				End If
				
				li_cnt_tmkind += 1
				ls_tmkind[li_cnt_tmkind,1] = LeftA(ls_Otmcod, 2)
				ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
			End If // 5 close
			
			//누락된 시간대코드가 없는지 Check
			If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
				f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
				dw_detail.SetColumn("tmcod")
				dw_detail.SetRow(ll_row - 1)
				dw_detail.ScrollToRow(ll_row - 1)
				dw_detail.SetRedraw(True)
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
			dw_detail.SetColumn("tmcod")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
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
		
		ll_findrow = dw_detail.Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
		                            "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
									"' and frpoint = 0", 1, ll_rows)

		If ll_findrow <= 0 Then
			f_msg_usr_err(9000, Title, "해당 대역/적용개시일/시간대별에 사용범위 0은 필수입력입니다." )		
			dw_detail.SetColumn("frpoint")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetRedraw(True)
			return -2
		End IF
		
	End IF
		
	ls_Ozoncod = ls_zoncod
	ls_Otmcod  = ls_tmcod
	ls_Oopendt = ls_opendt
Next

//오 막음2
//// zoncod가 하나만 있을경우 
//If Len(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
//	f_msg_usr_err(9000, Title, "각 요일(평일/주말/휴일)에 해당하는 시간대 코드가 모두 등록되어야 합니다.")
//							
//	dw_detail.SetFocus()
//	dw_detail.SetRedraw(True)
//	Return -2
//End If
//여기 2
li_rtmcnt = -1
//이미 Select됐된 시간대인지 Check
For li_i = 1 To li_cnt_tmkind
	If LeftA(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
Next

//새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
If li_rtmcnt < 0 Then
	li_return = b0fi_chk_tmcod(ls_priceplan, LeftA(ls_Otmcod, 2), li_rtmcnt, Title)
	If li_return < 0 Then
		dw_detail.SetRedraw(True)
		Return -2
	End If
End If

//누락된 시간대코드가 없는지 Check
If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
	f_msg_usr_err(9000, Title, "정의된 시간대코드가 충분하지 않거나 정의되지 않은 시간대코드입니다.")
						
	dw_detail.SetColumn("tmcod")
	dw_detail.SetRow(ll_rows)
	dw_detail.ScrollToRow(ll_rows)
	dw_detail.SetRedraw(True)
	Return -2
End If

//같은 시간대  code error 처리
ls_Ozoncod = ""
ls_Otmcod  = ""
ls_Oopendt = ""
lc_Ofrpoint = -1
For ll_row = 1 To ll_rows
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
	lc_frpoint = dw_detail.Object.frpoint[ll_row]
	If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
		f_msg_usr_err(9000, Title, "동일한 대역에 같은 시간대에 같은 사용범위가 존재합니다.")
		dw_detail.SetColumn("frpoint")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	ls_Ozoncod = ls_zoncod
	ls_Oopendt = ls_opendt
	ls_Otmcod = ls_tmcod
	lc_Ofrpoint = lc_frpoint
Next		

If lb_notExist Then
	If ls_arezoncod1 <> ls_arezoncodnm Then
		f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
		//Return -2
	Else
		If ls_arezoncod1 = "ALL" Then
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
			//Return -2
		Else
			f_msg_info(9000, Title, "지역별 대역정의에서 정의되지 않은 [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] 대역입니다." )
			dw_detail.SetFocus()
			dw_detail.SetRedraw(True)
			Return -2
		End If
	End If
End If

If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
	f_msg_info(9000, Title, "정의된 모든 대역에 대해서 요율을 등록해야 합니다.")
	//Return -2
End If

ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)


//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows1 = 1 To dw_detail.RowCount()
	ls_parttype1  = Trim(dw_detail.object.parttype[ll_rows1])
	ls_partcod1   = Trim(dw_detail.object.partcod[ll_rows1])
	ls_zoncod1    = Trim(dw_detail.object.zoncod[ll_rows1])
	ls_tmcod1     = Trim(dw_detail.object.tmcod[ll_rows1])
	ls_frpoint1   = String(dw_detail.object.frpoint[ll_rows1])
	ls_areanum1   = Trim(dw_detail.object.areanum[ll_rows1])
	ls_itemcod1   = Trim(dw_detail.object.itemcod[ll_rows1])
	ls_opendt1    = String(dw_detail.object.opendt[ll_rows1], 'yyyymmdd')
	ls_enddt1     = String(dw_detail.object.enddt[ll_rows1], 'yyyymmdd')
	
	If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		ls_parttype2 = Trim(dw_detail.object.parttype[ll_rows2])
		ls_partcod2  = Trim(dw_detail.object.partcod[ll_rows2])
		ls_zoncod2   = Trim(dw_detail.object.zoncod[ll_rows2])
		ls_tmcod2    = Trim(dw_detail.object.tmcod[ll_rows2])
		ls_frpoint2  = String(dw_detail.object.frpoint[ll_rows2])
		ls_areanum2  = Trim(dw_detail.object.areanum[ll_rows2])
		ls_itemcod2  = Trim(dw_detail.object.itemcod[ll_rows2])
		ls_opendt2   = String(dw_detail.object.opendt[ll_rows2], 'yyyymmdd')
		ls_enddt2    = String(dw_detail.object.enddt[ll_rows2], 'yyyymmdd')
		
		If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
		
		If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
			And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
			
			If ls_enddt1 >= ls_opendt2 Then
				f_msg_info(9000, Title, "같은 대역[ " + ls_zoncod1 + " ], 같은 착신지번호[ " + ls_areanum1 + " ], 같은 시간대[ " + ls_tmcod1 + " ], " &
												+ "같은 사용범위[ " + ls_frpoint1 + " ], 같은 품목[ " + ls_itemcod1 + " ]으로 적용개시일이 중복됩니다.")
				Return -2
			End If
		End If
		
	Next
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

event type integer ue_reset();call super::ue_reset;dw_cond.object.partcod_t.Text = "그룹"
dw_cond.object.partcod[1] = ""
dw_cond.object.partcod1[1] = ""

p_new.TriggerEvent("ue_disable")

dw_cond.object.svccod_t.visible = False
dw_cond.object.svccod.visible   = False

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
	f_msg_info(3000,This.Title,"Save")
End if

//ii_error_chk = 0
p_new.TriggerEvent("ue_enable")

Return 0

end event

event type integer ue_insert();////////////////////////////////////////////////////////////
//
// 수정내용 : master에 data 없으면 insert 못함
//
// 수 정 자 : 권 정 민
//
// 수 정 일 : 2004.08.30
//
////////////////////////////////////////////////////////////

Constant Int LI_ERROR = -1
Long ll_row,	ll_cnt

dw_master.AcceptText()

ll_cnt = dw_master.RowCount()

IF ll_cnt < 1 THEN
	f_msg_usr_err(9000, Title, "입력이 불가능합니다.")
	RETURN -1
END IF

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

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_particular_zoncst_v20
integer x = 37
integer y = 64
integer width = 2075
integer height = 196
string dataobject = "b0dw_cnd_particular_zoncst_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;
If Lower(dwo.name) = "parttype" Then
	Choose Case data
		Case "S"
			This.Object.partcod_t.Text     = "대리점"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_partner"
			is_data[1] = "CloseWithReturn"
			dw_cond.object.svccod_t.visible = True
			dw_cond.object.svccod.visible   = True

			
		Case "C"
			This.Object.partcod_t.Text     = "고객번호"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_customerm"
			is_data[1] = "CloseWithReturn"
			dw_cond.object.svccod_t.visible = True
			dw_cond.object.svccod.visible   = True
			
		Case "P"
			This.Object.partcod_t.Text     = "Pin"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_cardmst"
			is_data[1] = "CloseWithReturn"
			dw_cond.object.svccod_t.visible = False
			dw_cond.object.svccod.visible   = False
		
			
	End Choose
	
End If
			
		

end event

event dw_cond::ue_init();call super::ue_init;//고객 help popup
idwo_help_col[1] = Object.partcod
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;String ls_parttype

This.AcceptText()

ls_parttype = Trim(This.Object.parttype[1])

If IsNull(ls_parttype) Or ls_parttype = "" Then
	f_msg_info(200, Title, "그룹선택")
	This.SetFocus()
	This.SetColumn("parttype")
	Return
End If

If ls_parttype = "C" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[2]
			End If
	End Choose
	
ElseIf ls_parttype = "S" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[2]
			End If 

	End Choose
	
ElseIf ls_parttype = "P" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[1]
			End If

	End Choose
	
End If
end event

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_particular_zoncst_v20
integer x = 2267
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_particular_zoncst_v20
integer x = 2574
integer y = 40
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_particular_zoncst_v20
integer x = 23
integer y = 4
integer width = 2117
integer height = 276
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_particular_zoncst_v20
integer x = 23
integer y = 296
integer width = 3054
integer height = 468
string dataobject = "b0dw_cnd_reg_particular_zoncst2_v20"
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

event dw_master::doubleclicked;//
end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_particular_zoncst_v20
integer x = 23
integer y = 804
integer width = 3054
integer height = 824
string dataobject = "b0dw_reg_particular_zoncst_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_parttype, ls_partcod, ls_filter, ls_method
String ls_type
Long ll_row, i
Integer li_cnt
Dec{0} lc_data
DataWindowChild ldc

dw_master.AcceptText()

If dw_master.RowCount() > 0 Then
	ls_partcod  = Trim(dw_master.object.particular_zoncst_partcod[al_select_row])
	ls_parttype = Trim(dw_cond.object.parttype[1])

	If IsNull(ls_partcod) Then ls_partcod = ""
	If IsNull(ls_parttype) Then ls_parttype = ""

	ls_where = ""

	If ls_partcod <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " PARTCOD = '" + ls_partcod + "' "

	End If
	If ls_parttype <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " PARTTYPE = '" + ls_parttype + "' "

	End If

	//dw_detail 조회
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	dw_detail.SetRedraw(False)
	If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
	End If

	For i = 1 To dw_detail.RowCount()
		dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
	Next

	dw_detail.SetRedraw(true)
	
End If

////String ls_parttype, ls_type
////Integer li_cnt
//
////Format 지정
//dw_detail.object.frpoint.Format  = "#,##0"
//dw_detail.object.unitfee.Format  = "#,##0"
//dw_detail.object.unitfee1.Format = "#,##0"
//dw_detail.object.unitfee2.Format = "#,##0"
//dw_detail.object.unitfee3.Format = "#,##0"
//dw_detail.object.unitfee4.Format = "#,##0"
//dw_detail.object.unitfee5.Format = "#,##0"
//dw_detail.object.confee.Format   = "#,##0"
//
//
//For i =1 To dw_detail.RowCount()
//    lc_data = dw_detail.object.unbilsec[i]
//	 If IsNull(lc_data) Then dw_detail.object.unbilsec[i] = 0
//	 lc_data = dw_detail.object.confee[i]
//	 If IsNull(lc_data) Then dw_detail.object.confee[i] = 0
//	 lc_data = dw_detail.object.unitfee1[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee1[i] = 0
//	 lc_data = dw_detail.object.tmrange1[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange1[i] = 0
//	 lc_data = dw_detail.object.unitsec1[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec1[i] = 0
//	 lc_data = dw_detail.object.unitfee2[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee2[i] = 0
//	 lc_data = dw_detail.object.tmrange2[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange2[i] = 0
//	 lc_data = dw_detail.object.unitsec2[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec2[i] = 0
//	 lc_data = dw_detail.object.unitfee3[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee3[i] = 0
//	 lc_data = dw_detail.object.tmrange3[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange3[i] = 0
//	 lc_data = dw_detail.object.unitsec3[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec3[i] = 0
//	 lc_data = dw_detail.object.unitfee4[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee4[i] = 0
//	 lc_data = dw_detail.object.tmrange4[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange4[i] = 0
//	 lc_data = dw_detail.object.unitsec4[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec4[i] = 0
//	 lc_data = dw_detail.object.unitfee5[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitfee5[i] = 0
//	 lc_data = dw_detail.object.tmrange5[i]
//	 If IsNull(lc_data) Then dw_detail.object.tmrange5[i] = 0
//	 lc_data = dw_detail.object.unitsec5[i]
//	 If IsNull(lc_data) Then dw_detail.object.unitsec5[i] = 0
//Next

Return 0
	
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_opendt, ls_munitsec
Long ll_range1, ll_range2, ll_range3, ll_range4, ll_range5, ll_mod

If (dw_detail.GetItemStatus(row, 0, Primary!) = New!) Or (This.GetItemStatus(row, 0, Primary!)) = NewModified!	Then
	ls_munitsec = "0"
Else
	ls_munitsec = String(This.object.munitsec[row])
	If IsNull(ls_munitsec) Then ls_munitsec = ""
End If

Choose Case dwo.name
	// 대역이 ALL 이면 착신지번호(특번) 필수입력
	// 대역이 ALL 이 아니면 착신지번호는 ALL로 셋팅
	Case "zoncod"
		If data = 'ALL'  Then 
			This.Object.areanum[row] = ""
			This.Object.areanum.Protect = 0 
		Else
			This.Object.areanum[row] = 'ALL'
			This.Object.areanum.Protect = 1
		End If

	Case "unitsec"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec[row] > 0)  Then
				This.object.munitsec[row] = Long(data)
			End If
		End If
		
	Case "unitfee"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee[row] > 0)  Then
				This.object.munitfee[row] = Long(data)
			End If
		End If
		
	Case "tmrange1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange1[row] > 0)  Then
				This.object.mtmrange1[row] = Long(data)
			End If
		End If
		
	Case "unitsec1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.object.munitsec1[row] > 0) Then
				This.object.munitsec1[row] = Long(data)
			End If
		End If
		
		ll_range1 = This.object.tmrange1[row]
		
		If ll_range1 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range1, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange1")
				Return -1
			End If
		End If
	
	Case "unitfee1"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.object.munitfee1[row] > 0)  Then
				This.object.munitfee1[row] = Long(data)
			End If
		End If
		
	Case "tmrange2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange2[row] > 0)  Then
				This.object.mtmrange2[row] = Long(data)
			End If
		End If
	
		
	Case "unitsec2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec2[row] > 0)  Then
				This.object.munitsec2[row] = Long(data)
			End If
		End If
		
		ll_range2 = This.object.tmrange2[row]
		
		If ll_range2 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range2, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange2")
				Return -1
			End If
		End If
		
	Case "unitfee2"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee2[row] > 0)  Then
				This.object.munitfee2[row] = Long(data)
			End If
		End If
		
	Case "tmrange3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange3[row] > 0)  Then
				This.object.mtmrange3[row] = Long(data)
			End If
		End If
		
	Case "unitsec3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec3[row] > 0)  Then
				This.object.munitsec3[row] = Long(data)
			End If
		End If
		
		ll_range3 = This.object.tmrange3[row]
		
		If ll_range3 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range3, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange3")
				Return -1
			End If
		End If
		
	Case "unitfee3"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee3[row] > 0)  Then
				This.object.munitfee3[row] = Long(data)
			End If
		End If
		
	Case "tmrange4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange4[row] > 0)  Then
				This.object.mtmrange4[row] = Long(data)
			End If
		End If
		
	Case "unitsec4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec4[row] > 0)  Then
				This.object.munitsec4[row] = Long(data)
			End If
		End If
		
		ll_range4 = This.object.tmrange4[row]
		
		If ll_range4 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range4, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange4")
				Return -1
			End If
		End If
		
	Case "unitfee4"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee4[row] > 0)  Then
				This.object.munitfee4[row] = Long(data)
			End If
		End If
		
	Case "tmrange5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.mtmrange5[row] > 0)  Then
				This.object.mtmrange5[row] = Long(data)
			End If
		End If
		
	Case "unitsec5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitsec5[row] > 0)  Then
				This.object.munitsec5[row] = Long(data)
			End If
		End If
		
		ll_range5 = This.object.tmrange5[row]
		
		If ll_range5 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_range5, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetFocus()
				This.SetColumn("tmrange5")
				Return -1
			End If
		End If
		
	Case "unitfee5"
		If ls_munitsec = '0' Or ls_munitsec = "" Then
			If NOT(This.Object.munitfee5[row] > 0)  Then
				This.object.munitfee5[row] = Long(data)
			End If
		End If
		
End Choose

Return 0
end event

event dw_detail::retrieveend;call super::retrieveend;Long ll_row, i
String ls_filter, ls_svccod, ls_priceplan
Dec lc_data
DataWindowChild ldc_zoncod, ldc_tmcod, ldc_itemcod

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

String ls_parttype, ls_type
Integer li_cnt

//Format 지정
dw_detail.object.frpoint.Format  = "#,##0"
dw_detail.object.unitfee.Format  = "#,##0"
dw_detail.object.unitfee1.Format = "#,##0"
dw_detail.object.unitfee2.Format = "#,##0"
dw_detail.object.unitfee3.Format = "#,##0"
dw_detail.object.unitfee4.Format = "#,##0"
dw_detail.object.unitfee5.Format = "#,##0"
dw_detail.object.confee.Format   = "#,##0"
dw_detail.object.munitfee.Format  = "#,##0"
dw_detail.object.munitfee1.Format = "#,##0"
dw_detail.object.munitfee2.Format = "#,##0"
dw_detail.object.munitfee3.Format = "#,##0"
dw_detail.object.munitfee4.Format = "#,##0"
dw_detail.object.munitfee5.Format = "#,##0"

For i =1 To dw_detail.RowCount()
    lc_data = dw_detail.object.unbilsec[i]
	 If IsNull(lc_data) Then dw_detail.object.unbilsec[i] = 0
	 lc_data = dw_detail.object.confee[i]
	 If IsNull(lc_data) Then dw_detail.object.confee[i] = 0
	 lc_data = dw_detail.object.unitfee1[i]
	 If IsNull(lc_data) Then dw_detail.object.unitfee1[i] = 0
	 lc_data = dw_detail.object.tmrange1[i]
	 If IsNull(lc_data) Then dw_detail.object.tmrange1[i] = 0
	 lc_data = dw_detail.object.unitsec1[i]
	 If IsNull(lc_data) Then dw_detail.object.unitsec1[i] = 0
	 lc_data = dw_detail.object.unitfee2[i]
	 If IsNull(lc_data) Then dw_detail.object.unitfee2[i] = 0
	 lc_data = dw_detail.object.tmrange2[i]
	 If IsNull(lc_data) Then dw_detail.object.tmrange2[i] = 0
	 lc_data = dw_detail.object.unitsec2[i]
	 If IsNull(lc_data) Then dw_detail.object.unitsec2[i] = 0
	 lc_data = dw_detail.object.unitfee3[i]
	 If IsNull(lc_data) Then dw_detail.object.unitfee3[i] = 0
	 lc_data = dw_detail.object.tmrange3[i]
	 If IsNull(lc_data) Then dw_detail.object.tmrange3[i] = 0
	 lc_data = dw_detail.object.unitsec3[i]
	 If IsNull(lc_data) Then dw_detail.object.unitsec3[i] = 0
	 lc_data = dw_detail.object.unitfee4[i]
	 If IsNull(lc_data) Then dw_detail.object.unitfee4[i] = 0
	 lc_data = dw_detail.object.tmrange4[i]
	 If IsNull(lc_data) Then dw_detail.object.tmrange4[i] = 0
	 lc_data = dw_detail.object.unitsec4[i]
	 If IsNull(lc_data) Then dw_detail.object.unitsec4[i] = 0
	 lc_data = dw_detail.object.unitfee5[i]
	 If IsNull(lc_data) Then dw_detail.object.unitfee5[i] = 0
	 lc_data = dw_detail.object.tmrange5[i]
	 If IsNull(lc_data) Then dw_detail.object.tmrange5[i] = 0
	 lc_data = dw_detail.object.unitsec5[i]
	 If IsNull(lc_data) Then dw_detail.object.unitsec5[i] = 0
	 lc_data = dw_detail.object.munitfee1[i]
	 If IsNull(lc_data) Then dw_detail.object.munitfee1[i] = 0
	 lc_data = dw_detail.object.mtmrange1[i]
	 If IsNull(lc_data) Then dw_detail.object.mtmrange1[i] = 0
	 lc_data = dw_detail.object.munitsec1[i]
	 If IsNull(lc_data) Then dw_detail.object.munitsec1[i] = 0
	 lc_data = dw_detail.object.munitfee2[i]
	 If IsNull(lc_data) Then dw_detail.object.munitfee2[i] = 0
	 lc_data = dw_detail.object.mtmrange2[i]
	 If IsNull(lc_data) Then dw_detail.object.mtmrange2[i] = 0
	 lc_data = dw_detail.object.munitsec2[i]
	 If IsNull(lc_data) Then dw_detail.object.munitsec2[i] = 0
	 lc_data = dw_detail.object.munitfee3[i]
	 If IsNull(lc_data) Then dw_detail.object.munitfee3[i] = 0
	 lc_data = dw_detail.object.mtmrange3[i]
	 If IsNull(lc_data) Then dw_detail.object.mtmrange3[i] = 0
	 lc_data = dw_detail.object.munitsec3[i]
	 If IsNull(lc_data) Then dw_detail.object.munitsec3[i] = 0
	 lc_data = dw_detail.object.munitfee4[i]
	 If IsNull(lc_data) Then dw_detail.object.munitfee4[i] = 0
	 lc_data = dw_detail.object.mtmrange4[i]
	 If IsNull(lc_data) Then dw_detail.object.mtmrange4[i] = 0
	 lc_data = dw_detail.object.munitsec4[i]
	 If IsNull(lc_data) Then dw_detail.object.munitsec4[i] = 0
	 lc_data = dw_detail.object.munitfee5[i]
	 If IsNull(lc_data) Then dw_detail.object.munitfee5[i] = 0
	 lc_data = dw_detail.object.mtmrange5[i]
	 If IsNull(lc_data) Then dw_detail.object.mtmrange5[i] = 0
	 lc_data = dw_detail.object.munitsec5[i]
	 If IsNull(lc_data) Then dw_detail.object.munitsec5[i] = 0	 
Next

ls_parttype = dw_cond.object.parttype[1]

//If is_svccod_control = 'Y' Then
	If ls_parttype = "P" Then
		ls_priceplan = dw_master.object.priceplan[dw_master.Getrow()]
		
		select svccod 
		  into :ls_svccod 
		  from priceplanmst
		 where priceplan = :ls_priceplan ;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Select priceplanmst Table")
			Return
		End If	
		
		//ls_svccod    = dw_master.object.svccod[dw_master.Getrow()]
		
	Else		
		ls_svccod    = dw_cond.object.svccod[1]
		ls_priceplan = 'ALL'
	End If
	
	Modify("zoncod.dddw.name=''")
	Modify("zoncod.dddw.DataColumn=''")
	Modify("zoncod.dddw.DisplayColumn=''")

	Modify("zoncod.dddw.name=b0dc_dddw_zoncod_svccod_v20")
	Modify("zoncod.dddw.DataColumn='zoncod'")
	Modify("zoncod.dddw.DisplayColumn='zonnm'")	

	ll_row = dw_detail.GetChild("zoncod", ldc_zoncod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	ls_filter = "svccod = '" + ls_svccod + "' "
	ldc_zoncod.SetFilter(ls_filter)			//Filter정함
	ldc_zoncod.Filter()
	ldc_zoncod.SetTransObject(SQLCA)
	ll_row =ldc_zoncod.Retrieve()
	
	Modify("tmcod.dddw.name=''")
	Modify("tmcod.dddw.DataColumn=''")
	Modify("tmcod.dddw.DisplayColumn=''")

	Modify("tmcod.dddw.name=b0dc_dddw_tmcod_v20")
	Modify("tmcod.dddw.DataColumn='tmcod'")
	Modify("tmcod.dddw.DisplayColumn='codenm'")	
	
	ll_row = dw_detail.GetChild("tmcod", ldc_tmcod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	ls_filter = "svccod = '" + ls_svccod + "' and priceplan = '" +ls_priceplan+"'"

	ldc_tmcod.SetFilter(ls_filter)			//Filter정함
	ldc_tmcod.Filter()
	ldc_tmcod.SetTransObject(SQLCA)
	ll_row =ldc_tmcod.Retrieve()	

	//svccod 별 item가져오기
	ll_row = dw_detail.GetChild("itemcod", ldc_itemcod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
	ls_filter = "svccod = '" + ls_svccod + "' "
	ldc_itemcod.SetFilter(ls_filter)			//Filter정함
	ldc_itemcod.Filter()
	ldc_itemcod.SetTransObject(SQLCA)
	ll_row =ldc_itemcod.Retrieve()


//ElseIf is_svccod_control = 'N' Then
//	Modify("zoncod.dddw.name=''")
//	Modify("zoncod.dddw.DataColumn=''")
//	Modify("zoncod.dddw.DisplayColumn=''")
//
//	Modify("zoncod.dddw.name=b0dc_dddw_zoncod")
//	Modify("zoncod.dddw.DataColumn='zoncod'")
//	Modify("zoncod.dddw.DisplayColumn='zonnm'")	
//
//	Modify("tmcod.dddw.name=''")
//	Modify("tmcod.dddw.DataColumn=''")
//	Modify("tmcod.dddw.DisplayColumn=''")
//
//	Modify("tmcod.dddw.name=b0dc_dddw_tmcod")
//	Modify("tmcod.dddw.DataColumn='tmcod'")
//	Modify("tmcod.dddw.DisplayColumn='codenm'")	
//	
//End If

end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_particular_zoncst_v20
integer y = 1660
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_particular_zoncst_v20
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_particular_zoncst_v20
integer x = 617
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_particular_zoncst_v20
integer x = 1353
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_particular_zoncst_v20
integer y = 768
end type

type p_new from u_p_new within b0w_reg_particular_zoncst_v20
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

