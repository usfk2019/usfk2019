$PBExportHeader$ssrt_reg_schedule_management.srw
$PBExportComments$[1hera]  스케쥴 관리
forward
global type ssrt_reg_schedule_management from w_a_reg_m_m
end type
type p_new from u_p_new within ssrt_reg_schedule_management
end type
type dw_temp from u_d_base within ssrt_reg_schedule_management
end type
end forward

global type ssrt_reg_schedule_management from w_a_reg_m_m
integer height = 2356
event ue_new ( )
p_new p_new
dw_temp dw_temp
end type
global ssrt_reg_schedule_management ssrt_reg_schedule_management

type variables
String 	is_customerid, 	is_reqdt, 	is_userid, 	is_pgm_id, &
			is_basecod, 		is_control,	is_time[], &
			is_worktype[]
String 	is_emp_grp, is_old_time, is_old_ymd, is_old_reqdt
INTEGER	ii_maxnum, &
			ii_time =  48 //Time의 간격수
Boolean 	ib_order
date		idt_reqdt, idt_old_reqdt

end variables

forward prototypes
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
public function integer wfi_get_itemcod (ref string as_itemcod[])
public function integer wfi_check_value (string as_parttype, string as_partcod)
end prototypes

event ue_new();// dw_cond의 그룹선택에 따라 popup 창을 띄우고 선택하면
// dw_master에 새로운 행을 insert하고 선택한 ID와 명을 셋팅한다.
String ls_parttype, ls_partcod
String ls_partner, ls_partnernm, ls_levelcod, ls_logid1, ls_phone, ls_prefixno, ls_credit_yn
String ls_customernm, ls_customerid, ls_ssno, ls_status, ls_ctype1, ls_payid, ls_logid
Date   ld_enterdt
Long   ll_row, ll_cnt, ll_result
String ls_contno, ls_pid, ls_lotno, ls_status1, ls_partner_prefix
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
				 ISSUEDT, PARTNER_PREFIX, OPENUSEDT
		  INTO :ls_contno, :ls_pid, :ls_lotno,
		       :ls_status1, :lc_balance, :ld_enddt,
	   	    :ld_issuedt, :ls_partner_prefix, :ld_openusedt
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

on ssrt_reg_schedule_management.create
int iCurrent
call super::create
this.p_new=create p_new
this.dw_temp=create dw_temp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
this.Control[iCurrent+2]=this.dw_temp
end on

on ssrt_reg_schedule_management.destroy
call super::destroy
destroy(this.p_new)
destroy(this.dw_temp)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	스케쥴관리
	Desc.	: 	
	Ver.	:	1.0
	Date	: 	2006-8-17
	Programer : K.B.Cho(1hera)
--------------------------------------------------------------------------*/
//dw_cond.object.partcod_t.Text = '그룹'

p_new.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

Long 					ll_row
DataWindowChild 	ldwc
String 				ls_temp, ls_control, ls_ref_desc


//dw_detail.object.priceplan.Protect 	   = 1



end event

event ue_ok;call super::ue_ok;long	ll_cnt,	ll_row,	ll_insert_cnt, ll, jj
String	ls_partner, ls_time, ls_svc, ls_price, ls_work, &
			ls_customerid, 	ls_base,		ls_service, ls_status, &
			ls_org, ls_where1, ls_where, ls_partner_req, is_crtdt, ls_crt_user


//----------------------------
// Time Define
is_time[1]  = '0000'
is_time[2] 	= '0030'
is_time[3] 	= '0100'
is_time[4] 	= '0130'
is_time[5] 	= '0200'
is_time[6] 	= '0230'
is_time[7] 	= '0300'
is_time[8] 	= '0330'
is_time[9] 	= '0400'
is_time[10] = '0430'
is_time[11] = '0500'
is_time[12] = '0530'
is_time[13] = '0600'
is_time[14] = '0630'
is_time[15] = '0700'
is_time[16] = '0730'
is_time[17] = '0800'
is_time[18] = '0830'
is_time[19] = '0900'
is_time[20] = '0930'
is_time[21] = '1000'
is_time[22] = '1030'
is_time[23] = '1100'
is_time[24] = '1130'
is_time[25] = '1200'
is_time[26] = '1230'
is_time[27] = '1300'
is_time[28] = '1330'
is_time[29] = '1400'
is_time[30] = '1430'
is_time[31] = '1500'
is_time[32] = '1530'
is_time[33] = '1600'
is_time[34] = '1630'
is_time[35] = '1700'
is_time[36] = '1730'
is_time[37] = '1800'
is_time[38] = '1830'
is_time[39] = '1900'
is_time[40] = '1930'
is_time[41] = '2000'
is_time[42] = '2030'
is_time[43] = '2100'
is_time[44] = '2130'
is_time[45] = '2200'
is_time[46] = '2230'
is_time[47] = '2300'
is_time[48] = '2330'

ls_partner =  trim(dw_cond.Object.partner[1])
ls_Customerid 	= trim(dw_cond.Object.customerid[1])
ls_base 			= trim(dw_cond.Object.base[1])
ls_service 		= trim(dw_cond.Object.service[1])
ls_partner_req = trim(dw_cond.Object.partner_req[1])
ls_crt_user    = trim(dw_cond.Object.crt_user[1])

//2013.01.11 SUNZU KIM ADD,  Tech Shop 선택을 안하면, 전체가 조회되도록 '%'로 수정 
/*If IsNull(ls_partner) 		then ls_partner 		= '' 2013.01.11 SUNZU KIM 막음 */
If IsNull(ls_partner) 		then ls_partner 		= '%'
If IsNull(ls_Customerid) 	then ls_Customerid 	= ''
If IsNull(ls_base) 			then ls_base 			= ''
If IsNull(ls_service) 		then ls_service 		= ''
If IsNull(ls_partner_req)  then ls_partner_req  = ''
If IsNull(ls_crt_user)		then ls_crt_user		= ''


//2013.01.10 SUNZU KIM, TECH SHOP필수조건 값이 없어도 조회되도록 요청하여, 아래 부분을 막음 
/*FROM 
  If ls_partner = "" Then
	f_msg_info(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If */


/* 2013.01.11 SUNZU KIM 막음 */
/*SELECT WORKERNUM INTO :ii_maxnum FROM SCHEDULE_FRAME
WHERE PARTNER =  :ls_partner ; */

/*2013.01.11 SUNZU KIM  Tech Shop이 전체인 경우의 조건이 추가되면서 전체값을 가져올수 있도록 수정 */
SELECT MAX(WORKERNUM) INTO :ii_maxnum FROM SCHEDULE_FRAME
WHERE PARTNER LIKE  NVL(:ls_partner,0) ;


IF IsNull(ii_maxnum) THEN ii_maxnum = 0
	
/* 2013.01.11 SUNZU KIM ADD */
/* TECH SHOP의 값이 있을 경우만 Check하도록 조건 추가하고 메시지 수정 */
IF ls_partner <> "" Then	
	IF sqlca.sqlcode < 0 OR ii_maxnum = 0 THEN
		f_msg_usr_err(9000, Title, "선택하신 Tech의 처리가능 건수 설정이 되어 있지 않습니다!!."+'  '+ &
		                       "Shop설정값을 확인하도록 관리자에게 문의하여 주세요~.")
		Return 
	END IF
END IF

dw_master.Reset()
is_reqdt = String(dw_cond.Object.reqdt[1], 'yyyymmdd')
is_crtdt = String(dw_cond.Object.crtdt[1], 'yyyymmdd')

ls_where = ""
If is_crtdt <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(a.crtdt,'yyyymmdd') = '" + is_crtdt + "' "
End If
If is_reqdt <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.yyyymmdd = '" + is_reqdt + "' "
End If
/*2013.01.11 SUNZU KIM MODIFY. '='조건을 'LIKE'로 수정*/
/*ls_where += "a.partner_work = '" + ls_partner + "' "  ==> like로 수정(전체 Tech Shop조건이 추가되면서) */
If ls_partner <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.partner_work like '" + ls_partner + "' "
End If
If ls_service <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.svccod 		= '" + ls_service + "' "
End If
If ls_base <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "b.basecod 		= '" + ls_base + "' "
End If
If ls_customerid <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.customerid 		= '" + ls_customerid + "' "
End If
If ls_partner_req <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.partner_req 		= '" + ls_partner_req + "' "
End If
If ls_crt_user <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.crt_user 		= '" + ls_crt_user + "' "
End If
ls_where1 =  ls_where 

FOR ll =  1 to ii_time

//FOR ll =  1 to 1
	ls_time 	= is_time[ll]
	ls_where = ls_where1 + " And a.worktime 		= '" + ls_time + "' "
	dw_temp.is_where = ls_where
	ll_cnt = dw_temp.Retrieve()


//	dw_temp.Retrieve(is_reqdt, ls_time, ls_partner, ls_service, ls_base, ls_customerid)
	IF ll_cnt > 0 then
		FOR jj =  1 to ll_cnt
			ls_svc 		= dw_temp.describe("Evaluate('LookUpDisplay(svccod)'," + string(jj) +")") 
			ls_price 	= dw_temp.describe("Evaluate('LookUpDisplay(priceplan)'," + string(jj) +")") 
			ls_work 		= dw_temp.describe("Evaluate('LookUpDisplay(worktype)'," + string(jj) +")") 
			dw_temp.Object.svccod[jj] 		= ls_svc
			dw_temp.Object.priceplan[jj] 	= ls_price
			dw_temp.Object.worktype[jj] 	= ls_work
		NEXT
		dw_temp.RowsCopy(1, dw_temp.RowCount(), Primary!, dw_master, dw_master.RowCount() + 1, Primary!)
	END IF
	
		
	ll_insert_cnt	= ii_maxnum - ll_cnt
	IF ll_insert_cnt < 0 then ll_insert_cnt = 0
		IF ll_insert_cnt > 0 then
		for jj = 1 to ll_insert_cnt
			ll_row = dw_master.InsertRow(0)
			dw_master.Object.yyyymmdd[ll_row] 		= is_reqdt
			dw_master.Object.worktime[ll_row] 		= ls_time
			dw_master.Object.partner_work[ll_row] 	= ls_partner
			dw_master.Object.buildingno[ll_row] 	= ""
		NEXT
	END IF
NEXT	
IF dw_master.RowCount() > 0 then
	dw_master.selectRow(0, false)
	dw_master.selectRow(1, True)
	dw_detail.Trigger Event ue_retrieve(1)
END IF
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
return

end event

event type integer ue_extra_save();// 2008.02.15 hcjung : 고객번호 입력 받도록 수정. customerid와 orderno 비교체크 구분 추가

INTEGER	li_worknum, 	li_count, 		li_cnt
Long		ll_orderno, 	ll_troubleno,	ll_SEQ
String 	ls_time,			ls_partner, 	ls_descript, 	ls_service, 	ls_priceplan, &
			ls_worktype,	ls_reqdt, 		ls_customerid, ls_orderno,		ls_today
date     ldt_reqdt

dw_detail.AcceptText()
ldt_reqdt		= dw_cond.Object.reqdt[1]
ll_orderno		= dw_detail.Object.orderno[1]
ls_orderno     = trim(String(dw_detail.Object.orderno[1]))
ll_troubleno	= dw_detail.Object.troubleno[1]
ls_customerid	= dw_detail.Object.customerid[1]
ll_seq			= dw_detail.Object.scheduleseq[1]

ls_partner		= trim(dw_cond.Object.partner[1])

ls_time 			= trim(dw_detail.Object.worktime[1])
ls_worktype 	= trim(dw_detail.Object.worktype[1])
ls_service 		= trim(dw_detail.Object.svccod[1])
ls_priceplan	= trim(dw_detail.Object.priceplan[1])
ls_descript		= trim(dw_detail.Object.description[1])

//  =========================================================================================
//  2008-03-19 hcjung   
//  스케쥴 수정할때 날짜도 수정할 수 있도록 변경하면서 날짜를 dw_cond에서 읽어오던걸
//  dw_detail 에서 읽어오도록 수정
//  =========================================================================================
//ls_reqdt 		= String(dw_cond.Object.reqdt[1], 'yyyymmdd')
ls_reqdt 		= String(dw_detail.Object.yyyymmdd[1], 'yyyymmdd')

IF IsNull(ls_reqdt)			THEN ls_reqdt	= ""

IF IsNull(ll_seq) 			THEN ll_seq 				= 0
IF IsNull(ls_partner) 		THEN ls_partner 			= ""
IF IsNull(ls_customerid) 	THEN ls_customerid 		= ""

IF IsNull(ls_time) 		THEN ls_time 		= ""
IF IsNull(ls_worktype) 	THEN ls_worktype 	= ""
IF IsNull(ls_service) 	THEN ls_service 	= ""
IF IsNull(ls_priceplan)	THEN ls_priceplan	= ""
IF IsNull(ls_descript) 	THEN ls_descript 	= ""
IF IsNull(ls_orderno)   THEN ls_orderno   = ""

IF ls_time = "" THEN
	f_msg_info(200, Title, "TIME")
	dw_detail.SetFocus()
	dw_detail.SetColumn("worktime")
	RETURN -1
END IF

IF ls_partner = "" THEN
	f_msg_info(200, Title, "PARTNER")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	RETURN -1
END IF
IF ls_worktype = "" THEN
	f_msg_info(200, Title, "Work Type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("worktype")
	RETURN -1
END IF

IF ls_customerid = "" THEN
	f_msg_info(200, Title, "Customer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	RETURN -1
ELSE
	li_cnt = 0
	SELECT count(*) INTO :li_cnt FROM CUSTOMERM WHERE CUSTOMERID = :ls_customerid;
	
	IF li_cnt = 0 THEN
		f_msg_usr_err(9000, Title, "Customerid가 존재하지 않습니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("customerid")
		RETURN -1 
	END IF
END IF

IF ls_reqdt = "" THEN
	f_msg_info(200, Title, "Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("Date")
	RETURN -1
END IF

IF ls_orderno <> "" THEN
	li_cnt = 0
   
	SELECT count(*) INTO :li_cnt FROM svcorder WHERE customerid = :ls_customerid AND orderno = :ls_orderno;
	
	IF li_cnt = 0 THEN
	    f_msg_info(200, Title, "Order No. and CustomerID Not Matched")
	    dw_cond.SetFocus()
	    dw_cond.SetColumn("customerid")
       RETURN -1
   END IF
END IF

//최대직원수 및 스케쥴수 read
SELECT workernum   INTO :li_worknum   FROM schedule_frame
 WHERE partner = :ls_partner
   AND fromdt 	= ( SELECT MAX(fromdt) FROM schedule_frame WHERE partner = :ls_partner)  ;
 
IF IsNull(li_worknum)  THEN li_worknum = 0
IF sqlca.sqlcode < 0 THEN
	ROLLBACK ;
	f_msg_sql_err('Schedule Management', " schedule_frame - workernum")
	RETURN -1
END IF

//  =========================================================================================
//  2008-03-18 hcjung   
//  스케쥴 갯수 가져오는 대상 테이블을 schedule_amount => schedule_detail 로 변경
//  schedule_amont 하는 곳 주석 처리
//  =========================================================================================
//SELECT count(*)   INTO :li_count  FROM schedule_amount
// WHERE partner 	= :ls_partner 
//   AND yyyymmdd 	= :ls_reqdt
//	AND worktime 	= :ls_time 	;

SELECT COUNT(*) INTO :li_count FROM schedule_detail
 WHERE partner_work	= :ls_partner
   AND yyyymmdd		= :ls_reqdt
	AND worktime		= :ls_time;

IF IsNull(li_count)  THEN li_count = 0
IF sqlca.sqlcode < 0 THEN
	f_msg_sql_err('Schedule Management', " schedule_amount - Count")
	RETURN -1
END IF
//  =========================================================================================
//  2008-03-25 hcjung   
//  스케쥴이 꽉 찼을때 수정하면서 저장하면 스케쥴 Full이라고 나오는 버그 수정
//  알고리즘은 다음과 같다.
//  IF schedule_seq = 0 THEN
//		  IF worker_num > schedule_count THEN
//          schedule insert();
//      ELSE
//          error(schedule full);
//      END IF;
//  ELSE
//      schedule update();
//  END IF; 
//  =========================================================================================

ls_today	= String (fdt_get_dbserver_now(),'yyyymmdd')

IF ll_seq = 0 THEN
//	IF li_worknum > li_count THEN
		SELECT seq_schedule_detail.nextval INTO :ll_seq  FROM dual;
		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err('Schedule Management', "  seq_schedule_detail - Sequence Error")
			ROLLBACK ;
			RETURN -1
		END IF
		
		//partner_req 항목에 로그인샵으로 변경 요청함 - 이윤주 대리(2011.09.21)
		//현재는 파라미터로 open시 전달받은 user를 sysusr1t의 emp_group으로 처리하고 있었음.
		//2011.09.22 kem modify ( ***** )
		IF ls_reqdt >= ls_today THEN
			INSERT INTO schedule_detail ( 
						SCHEDULESEQ,  	YYYYMMDD,  		WORKTIME,  		REQUESTDT,  CUSTOMERID,
						DESCRIPTION,  	WORKTYPE,  		ORDERNO,  		TROUBLENO,  SVCCOD,
						PRICEPLAN,  	PARTNER_WORK,  PARTNER_REQ,  	CRT_USER, 	CRTDT    	
						)
			VALUES ( 
					  :ll_seq, 			:ls_reqdt, 		:ls_time, 		:ldt_reqdt,		:ls_customerid,
					  :ls_descript,   :ls_worktype,	:ll_orderno,	:ll_troubleno,	:ls_service,
//					  :ls_priceplan,	:ls_partner,   :is_emp_grp,  	:gs_user_id, 	SYSDATE     ( ***** )
					  :ls_priceplan,	:ls_partner,   :GS_ShopID,  	:gs_user_id, 	SYSDATE
					  );
					  
			li_count += 1	
			
			IF SQLCA.SQLCode < 0 THEN
				f_msg_sql_err(Title, "SCHEDULE_DETAIL TABLE INSERT Error")
				ROLLBACK ;
				RETURN -1
			END IF;		
		ELSE
			f_msg_info(9000, Title, "Work Date Check")
			ROLLBACK ;
			GL_SCHEDULSEQ = 0
			RETURN -1
		END IF;
//	ELSE
//		f_msg_info(9000, Title, "SCHEDULE IS FULL")
//		ROLLBACK ;
//		GL_SCHEDULSEQ = 0
//		RETURN -1	
//	END IF;
ELSE	
	//  =========================================================================================
	//  2008-03-26 hcjung   
	//  이전 날짜에 대한 스케쥴 변경은 안되도록
	//  =========================================================================================
	IF is_old_ymd >= ls_today AND ls_reqdt >= ls_today THEN
		UPDATE schedule_detail 
		   SET YYYYMMDD 		= :ls_reqdt,  		
				 WORKTIME 		= :ls_time,  		
				 REQUESTDT 		= :ldt_reqdt,  
				 CUSTOMERID 	= :ls_customerid,
				 DESCRIPTION 	= :ls_descript,  	
				 WORKTYPE 		= :ls_worktype,   		
				 ORDERNO 		= :ll_orderno,  		
				 TROUBLENO 		= :ll_troubleno,  
				 SVCCOD 			= :ls_service,
				 PRICEPLAN 		= :ls_priceplan,  	
				 PARTNER_WORK 	= :ls_partner,  
//				 PARTNER_REQ 	= :is_emp_grp  	  ( ***** )
				 PARTNER_REQ 	= :GS_ShopID
		 WHERE SCHEDULESEQ = :ll_seq;	

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(Title, "SCHEDULE_AMOUNT TABLE UPDATE Error")
			GL_SCHEDULSEQ = 0
			ROLLBACK ;
			RETURN -1
		END IF;
	ELSE
		f_msg_info(9000, Title, "Work Date Check")
		ROLLBACK ;
		GL_SCHEDULSEQ = 0
		RETURN -1
	END IF;

END IF;
	
COMMIT ;
dw_detail.SetitemStatus(1, 0, Primary!, NotModIFied!)

RETURN 0
	
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

event ue_reset;Long 					ll_row
Int               li_cnt
DataWindowChild 	ldwc
String 				ls_temp


is_customerid	= ""
is_reqdt 		= ""
is_userid 		= ""
is_pgm_id 		= ""


dw_cond.reset()
dw_cond.InsertRow(0)
dw_cond.Object.reqdt[1] 	= date(fdt_get_dbserver_now())
// ====================================================================================================
// 2012-12-13 HCJUNG
// 로그인한 TECH이 TECH Shop 항목에 기본값으로 나오도록 수정
// 그러나, 로그인한 샵이 TECH이 아닐 경우, Regist Shop에 로그인한 shop이 나오도록.
// 로그인한 Shop이 TECH Shop인지 체크
li_cnt = 0;

SELECT COUNT(*)
INTO   :li_cnt
FROM   PARTNERMST
WHERE  GROUP_ID = ( SELECT REF_CONTENT FROM SYSCTL1T WHERE MODULE = 'PI' AND REF_NO = 'A101' )
AND    USE_YN = 'Y'
AND    PARTNER = :GS_SHOPID;

IF li_cnt = 0 THEN
	dw_cond.Object.partner_req[1] = GS_SHOPID
ELSE
	dw_cond.Object.partner[1]     = GS_SHOPID
END IF
// ====================================================================================================

dw_detail.Reset()
dw_detail.InsertRow(0)

//2013.01.10 SUNZU KIM ADD -Reset시에 Clear되도록 ADD 
dw_detail.object.t_customernm.text = ''; 

select emp_group 
  into :is_emp_grp
  from sysusr1t 
 where emp_id =  :gs_user_id ;

IF IsNull(is_emp_grp) then is_emp_grp = ''

dw_detail.object.priceplan.Protect 	   = 1

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

li_return = Trigger Event ue_extra_save()
If li_return <0  Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

f_msg_info(3000,This.Title,"Save")
TriggerEvent("ue_ok")
return 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row,	ll_cnt

dw_master.AcceptText()

ll_cnt = dw_master.RowCount()

dw_detail.Reset()
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

event type integer ue_delete();Constant Int LI_ERROR = -1


If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

f_msg_info(3000,This.Title,"Delete")
TriggerEvent("ue_ok")
Return 0

end event

event ue_extra_delete;// 하게 되면 해당 처리 
Long		ll_seq, 			ll_cnt,		ll_troubleno,	ll_orderno,			ll_valid_cnt,	&
			ll_cnt_equip
String 	ls_partner,		ls_time, 	ls_ymd,			ls_worktype,		ls_svccod,		&
			ls_priceplan,	ls_check,	ls_contractseq


If dw_detail.RowCount()= 0 Then return -1

ll_seq		= dw_detail.Object.scheduleseq[1]
ls_partner 	= Trim(dw_detail.Object.partner_work[1])
ls_ymd 		= Trim(String(dw_detail.Object.yyyymmdd[1], 'yyyymmdd'))
ls_time 		= Trim(dw_detail.Object.worktime[1])
ls_worktype = Trim(dw_detail.Object.worktype[1])    //100:신규, 200:장애, 400:auto
ll_troubleno = dw_detail.Object.troubleno[1]
ll_orderno   = dw_detail.Object.orderno[1]
ls_svccod	 = dw_detail.Object.svccod[1]
ls_priceplan = dw_detail.Object.priceplan[1] 

IF ls_worktype = '400' THEN
	F_MSG_INFO(200, Title, "자동 스케줄은 삭제할 수 없습니다.")
	ROLLBACK;
	RETURN -1	
END IF

IF ls_worktype = '100' OR ls_worktype = '200' THEN				//신규 또는 장애(변경)
	SELECT COUNT(*) INTO :ll_valid_cnt
	FROM   SYSCOD2T
	WHERE  GRCODE = 'BOSS03'
	AND    USE_YN = 'Y'
	AND    CODE   = :ls_svccod;
		
	IF ll_valid_cnt > 0 THEN
		IF ls_priceplan = "PRCM06" OR ls_priceplan = "PRCM08" OR ls_priceplan = "PRCM18" OR ls_priceplan = "PRCM19" THEN
			ls_check = 'N'
		ELSE
			ls_check = 'Y'
		END IF
	ELSE
		ls_check = 'N'
	END IF
		
	IF ls_check = 'Y' THEN
		IF ls_worktype = '200' THEN
			SELECT TO_CHAR(CONTRACTSEQ) INTO :ls_contractseq 
			FROM   CUSTOMER_TROUBLE 
			WHERE  TROUBLENO = :ll_troubleno);	
			
			SELECT COUNT(*) INTO :ll_cnt_equip
			FROM   EQUIPMST
			WHERE  CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
			AND    VALID_STATUS IN ('200', '300');	
		ELSE
			SELECT COUNT(*) INTO :ll_cnt_equip
			FROM   EQUIPMST
			WHERE  ORDERNO = :ll_orderno
			AND    VALID_STATUS IN ('200', '300');	
		END IF
	ELSE
		ll_cnt_equip = 0
	END IF
			
	IF ll_cnt_equip > 0 THEN
		F_MSG_INFO(200, Title, "장비인증중 또는 장비인증완료 상태라 삭제가 불가합니다.")
		ROLLBACK;
		RETURN -1
	END IF
END IF		

select count INTO :ll_cnt FROM schedule_amount
 WHERE partner 	= :ls_partner 
	AND yyyymmdd 	= :ls_ymd
	AND worktime 	= :ls_time 	;

IF IsNull(ll_cnt) THEN ll_cnt = 0
IF ll_cnt > 0 then ll_cnt -= 1

UPDATE schedule_amount
   SET count = :ll_cnt
 where partner 	= :ls_partner 
   AND yyyymmdd 	= :ls_ymd
   AND worktime 	= :ls_time 	;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err('Schedule Management', "  schedule_amount - Update Error")
	Rollback ;
	Return -1
End If			
//
//  DELETE FROM SCHEDULE_DETAIL  
//   WHERE SCHEDULESEQ = :ll_seq;
//삭제 할때 전체 삭제가 아니라 해당 스케줄만 삭제한다. 
DELETE FROM SCHEDULE_DETAIL  
WHERE  SCHEDULESEQ = :ll_seq
AND    YYYYMMDD    = :ls_ymd
AND    WORKTIME    = :ls_time;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err('Schedule Management', "  SCHEDULE_DETAIL - Delete Error")
	Rollback ;
	Return -1
End If	

dw_detail.DeleteRow(0)
dw_detail.SetFocus()

Commit ;
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within ssrt_reg_schedule_management
integer x = 46
integer y = 52
integer width = 2455
integer height = 432
string dataobject = "ssrt_cnd_reg_schedule_management"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;String ls_emp_grp,		ls_basecod
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

select emp_group 
  into :ls_emp_grp
  from sysusr1t 
 where emp_id =  :gs_user_id ;
//
IF IsNull(ls_emp_grp) then ls_emp_grp = ''

IF ls_emp_grp <> '' then
	select basecod 
	  INTO :ls_basecod
	  FROM partnermst
	 WHERE basecod = :ls_emp_grp    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(ls_basecod) then ls_basecod = '000000'
EnD IF

dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemerror;call super::itemerror;return 1
end event

event dw_cond::itemchanged;call super::itemchanged;STRING	ls_customernm

IF row <= 0 THEN RETURN -1

IF dwo.name = 'customerid' THEN
	SELECT CUSTOMERNM INTO :ls_customernm
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :data;
	
	This.Object.customernm[row] = ls_customernm
END IF

RETURN 0
	
end event

type p_ok from w_a_reg_m_m`p_ok within ssrt_reg_schedule_management
integer x = 2546
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within ssrt_reg_schedule_management
integer x = 2853
integer y = 40
end type

type gb_cond from w_a_reg_m_m`gb_cond within ssrt_reg_schedule_management
integer x = 23
integer y = 4
integer width = 2505
integer height = 512
end type

type dw_master from w_a_reg_m_m`dw_master within ssrt_reg_schedule_management
integer x = 23
integer y = 532
integer height = 908
string dataobject = "ssrt_reg_schedule_management_list"
end type

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
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
	
End If
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = this.Object.worktime_t
uf_init(ldwo_SORT)
end event

type dw_detail from w_a_reg_m_m`dw_detail within ssrt_reg_schedule_management
integer x = 23
integer y = 1472
integer width = 1001
integer height = 568
string dataobject = "ssrt_reg_schedule_management_detail"
boolean hsplitscroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_retrieve;//dw_master click시 Retrieve
String ls_where, ls_parttype, ls_partcod, ls_filter, ls_method, ls_customernm, ls_customerid
String ls_type,			ls_time
Long ll_row, i, ll_seq
Integer li_cnt
Dec{0} lc_data
DataWindowChild ldc

dw_master.AcceptText()

If dw_master.RowCount() > 0 Then
	ll_seq = 	dw_master.object.SCHEDULESEQ[al_select_row]
	ls_time = 	dw_master.object.worktime[al_select_row]
	
	IF IsNull(ll_seq) then ll_seq =	0
	ls_where = ""

	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(SCHEDULESEQ) = '" + String(ll_seq ) + "' "

	//dw_detail 조회
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve();
	dw_detail.object.t_customernm.text = '';  

   /* 2013.01.10 SUNZU KIM 이름 가져오는 부분을 막고, dw_master에서 가져오는 것으로 변경 */
	/*Select customernm 
	  Into :ls_customernm
	  From Customerm
	Where  customerid = dw_detail.object.customerid[1]; */

   /* 2013.01.10 SUNZU KIM ADD */ 
	/* 이미 dw_master에서 이름을 보여주므로, 그 이름을 그대로 가져오도록 추가함 */
	ls_customernm = trim(dw_master.object.customernm[al_select_row]) 
	                                                                                 
	dw_detail.object.t_customernm.text = ls_customernm;
		
	dw_detail.SetRedraw(False)
	If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
	ELSEIF ll_row = 0 then
		dw_detail.Reset()
		dw_detail.InsertRow(0)
		dw_detail.Object.yyyymmdd[1] = dw_cond.Object.reqdt[1] //date(fdt_get_dbserver_now())
		dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
		p_delete.TriggerEvent("ue_disable")
	ELSE
		is_old_time 	= this.Object.worktime[1]
		is_old_ymd		= String(this.Object.yyyymmdd[1], 'yyyymmdd')
		is_old_reqdt	= String(this.Object.requestdt[1], 'yyyymmdd')
		dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
	End If
	dw_detail.SetRedraw(true)
else
	is_old_time 	= ''
	is_old_ymd		= ''
End If


Return 0
	
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild 	ldc_priceplan, 	ldc_svcpromise, 		ldc_svccod,&
						ldc_vprice, 		ldc_validkey_type, 	ldc_wkflag2
Long 					li_exist, 			ll_i, 					ll_row, 		ll_svcctl_cnt, 	ll_contractseq
String 				ls_filter, 			ls_validkey_yn, 		ls_act_gu, 	ls_customerid, &
						ls_currency_type, ls_partner1, &
       				ls_customer_id, 	ls_svccode,				ls_svctype, &
						ls_svccod,			ls_priceplan,        ls_customernm
Boolean 				lb_check, 			lb_confirm
datetime 			ldt_date


SetNull(ldt_date)

This.AcceptText()

Choose Case dwo.name
	CASE "customerid"
		SELECT CUSTOMERNM INTO :ls_customernm
		FROM   CUSTOMERM
		WHERE  CUSTOMERID = :data;
	
		THIS.OBJECT.t_customernm.text = ls_customernm;

	Case "svccod"
			ls_customerid 	= Trim(This.object.customerid[1])
		
			SELECT svctype	  INTO :ls_svctype	  FROM svcmst
		 	 WHERE svccod = :data;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(parent.title, "SELECT svctype from svcmst")				
				Return 1
			END IF
				
			li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data  + "'"
//			   "'  And  String(auth_level) 	>= '"  	+ String(gi_auth) 	+ &
//				"'  And  partner 					= '" 		+ gs_shopid 		+ "' " 
//
			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
		
         this.Object.priceplan[1] 	= ""
			
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			//선택할수 있게
			This.object.priceplan.Protect = 0
		case 'orderno'
			select customerid, SVCCOD, PRICEPLAN 
			  INTO :ls_customerid,	:ls_svccod, :ls_priceplan
			  FROM svcorder
			 WHERE to_char(orderno) = :data ;
			 
			IF IsNull(ls_customerid) 		then ls_customerid 	= ''
			IF IsNull(ls_svccod) 			then ls_svccod 		= ''
			IF IsNull(ls_priceplan) 		then ls_priceplan 	= ''
			If ls_customerid = '' Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  

			this.Object.customerid[1] 	= ls_customerid
			this.Object.svccod[1] 		= ls_svccod
			this.Object.priceplan[1] 	= ls_priceplan
			
			
		case 'troubleno'
			select customerid, contractseq INTO :ls_customerid, :ll_contractseq FROM customer_trouble
			 WHERE to_char(troubleno) = :data ;
			 
			IF IsNull(ls_customerid) then ls_customerid = ''
			If ls_customerid = '' Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			
		   If IsNull(ll_contractseq) then ll_contractseq = 0
		
		   If ll_contractseq > 0 Then
				select svccod, priceplan INTO :ls_svccod, :ls_priceplan FROM contractmst
				where contractseq = :ll_contractseq;
				
				this.Object.svccod[1] 		= ls_svccod
				this.Object.priceplan[1] 	= ls_priceplan
				
		   END if
			this.Object.customerid[1] = ls_customerid
End Choose	
end event

event dw_detail::itemerror;call super::itemerror;RETURN 1
end event

event dw_detail::losefocus;call super::losefocus;AcceptText()
end event

type p_insert from w_a_reg_m_m`p_insert within ssrt_reg_schedule_management
boolean visible = false
integer y = 1660
end type

type p_delete from w_a_reg_m_m`p_delete within ssrt_reg_schedule_management
integer x = 18
integer y = 2056
end type

type p_save from w_a_reg_m_m`p_save within ssrt_reg_schedule_management
integer x = 352
integer y = 2056
end type

type p_reset from w_a_reg_m_m`p_reset within ssrt_reg_schedule_management
integer x = 686
integer y = 2056
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ssrt_reg_schedule_management
integer y = 1440
end type

type p_new from u_p_new within ssrt_reg_schedule_management
boolean visible = false
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean enabled = false
boolean originalsize = false
end type

type dw_temp from u_d_base within ssrt_reg_schedule_management
boolean visible = false
integer x = 1957
integer y = 188
integer width = 1070
integer height = 80
integer taborder = 11
boolean bringtotop = true
boolean enabled = false
string dataobject = "ssrt_reg_schedule_management_temp"
end type

