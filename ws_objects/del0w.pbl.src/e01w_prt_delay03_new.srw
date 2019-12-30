$PBExportHeader$e01w_prt_delay03_new.srw
$PBExportComments$[parkkh] 연체자 리스트
forward
global type e01w_prt_delay03_new from w_a_print
end type
type dw_saveas from datawindow within e01w_prt_delay03_new
end type
type hpb_1 from hprogressbar within e01w_prt_delay03_new
end type
type gb_2 from groupbox within e01w_prt_delay03_new
end type
end forward

global type e01w_prt_delay03_new from w_a_print
dw_saveas dw_saveas
hpb_1 hpb_1
gb_2 gb_2
end type
global e01w_prt_delay03_new e01w_prt_delay03_new

forward prototypes
public subroutine wf_progress (any wfl_cnt, long wfl_rowcnt)
end prototypes

public subroutine wf_progress (any wfl_cnt, long wfl_rowcnt);Long ll_pcc

ll_pcc =  Truncate(wfl_cnt/wfl_rowcnt * 100 , 0)
IF ll_pcc > 100 then ll_pcc = 100
hpb_1.Position = ll_pcc
Yield()
return
end subroutine

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_module,  ls_ref_no, 		ls_ref_desc, &
			ls_last_reqdtfr, 	ls_last_reqdtto, 	ls_dlyamt,  ls_chargeby, &
			ls_base,				ls_customerid,		ls_service, ls_suspend_dt,	ls_standard
Long   	li_from, 	li_to
String   ls_from, ls_to

//연체개월수 0개월도 화면상세 나타내주길 바람.(from 박자연)
//2011.09.22 kem
ls_from 				= dw_cond.object.from_month[1]
ls_to 				= dw_cond.object.to_month[1]
ls_suspend_dt		= String(dw_cond.object.suspend_dt[1], "yyyymmdd")
//ls_last_reqdtfr 	= String(dw_cond.Object.last_reqdtfr[1], "yyyymm")
//ls_last_reqdtto 	= String(dw_cond.Object.last_reqdtto[1], "yyyymm")
ls_dlyamt 			= String(dw_cond.Object.dlyamt[1])
//ls_chargeby 		= Trim(dw_cond.Object.chargeby[1])
ls_base 				= Trim(dw_cond.Object.base[1])
ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_service 			= Trim(dw_cond.Object.service[1])

If IsNull(ls_dlyamt) 		Then ls_dlyamt 		= ""
//If IsNull(ls_chargeby) 		Then ls_chargeby 		= ""
If IsNull(ls_base) 			Then ls_base 			= ""
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_service) 		Then ls_service 		= ""

If IsNull( ls_from ) Then			ls_from	= '0'

li_from = Long(ls_from)
li_to   = Long(ls_to)

If isnull( ls_to ) Then
	MessageBox( "알림", "연체개월수를 입력해 주십시오 " )
	dw_cond.Setcolumn("to_month")
	dw_cond.Setfocus()
	return
end If

If ( li_from > li_to ) then
	MessageBox("알림", "연체개월수 입력이 잘못되었습니다 ")
	dw_cond.Setcolumn("to_month")
	dw_cond.Setfocus()
	return
end if
// 최종청구월
//If ls_last_reqdtfr = '' Then
//	MessageBox( "알림", "최종청구월을 입력해 주십시오 " )
//	dw_cond.Setcolumn("last_reqdtfr")
//	dw_cond.Setfocus()
//	return
//end If
//If ( ls_last_reqdtfr > ls_last_reqdtto ) then
//	MessageBox("알림", "최종청구월 입력이 잘못되었습니다 ")
//	dw_cond.Setcolumn("last_reqdtto")
//	dw_cond.Setfocus()
//	return
//end if

//미납금액
If  ls_dlyamt = '' Then
	MessageBox( "알림", "미납금액를 입력해 주십시오 " )
	dw_cond.Setcolumn("dlyamt")
	dw_cond.Setfocus()
	return
end If

//마지막 연체추출일 
ls_module 	= "E2"
ls_ref_no 	= "A102"
ls_ref_desc = ""
ls_temp 		= fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
ls_standard = ls_temp

ls_temp 		= "기준일 : " + string(ls_temp, "@@@@-@@-@@")
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

//If ls_chargeby <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " b.pay_method = '" + ls_chargeby + "' "
//End If

If ls_dlyamt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " (a.retry_int_amt >= " + ls_dlyamt + " OR a.retry_mob_amt >= " + ls_dlyamt + ") "
End If


//If ls_last_reqdtfr <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " to_char(a.lastreqdt,'yyyymm') >= '" + ls_last_reqdtfr + "' "
//End If
//If ls_last_reqdtto <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " to_char(a.lastreqdt, 'yyyymm') <= '" + ls_last_reqdtto + "' "
//End If
//If Not IsNull(ls_from) AND IsNull(ls_to) Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " (a.DLY_INT_MONTH >= TO_NUMBER(" + ls_from + ") OR a.DLY_MOB_MONTH >= TO_NUMBER(" + ls_from + ")) "
//End If
//
//If Not IsNull(ls_to) Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " (a.DLY_INT_MONTH <= TO_NUMBER(" + ls_to + ") OR a.DLY_MOB_MONTH <= TO_NUMBER(" + ls_to + "))"
//End If

//연체개월수 where 로직 이상으로 수정 처리(from 박자연)
//2011.09.30 kem
If Not IsNull(ls_from) AND Not IsNull(ls_to) Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " (CASE WHEN a.DLY_INT_MONTH >= A.DLY_MOB_MONTH THEN A.DLY_INT_MONTH ELSE A.DLY_MOB_MONTH END) >= TO_NUMBER(" + ls_from + ") " +&
	            " AND (CASE WHEN a.DLY_INT_MONTH >= A.DLY_MOB_MONTH THEN A.DLY_INT_MONTH ELSE A.DLY_MOB_MONTH END) <= TO_NUMBER(" + ls_to + ") "
End If


//검색조건 추가  
// 2006-12-06 ( from 정희찬)
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " c.basecod = '" + ls_base + "' "
End If
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.PAYID = '" + ls_customerid + "' "
End If
If ls_suspend_dt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.SUSPEND_DATE = TO_DATE('" + ls_suspend_dt + "', 'YYYYMMDD') "
End If

If ls_where <> "" Then ls_where += " AND "
ls_where += " a.STDMONTH = TO_DATE('" + ls_standard + "', 'YYYYMMDD') "
//If ls_service <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " cts.status = '20' AND  cts.svccod = '" + ls_service + "' "
//End If
// Add End......................


dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If


end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on e01w_prt_delay03_new.create
int iCurrent
call super::create
this.dw_saveas=create dw_saveas
this.hpb_1=create hpb_1
this.gb_2=create gb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_saveas
this.Control[iCurrent+2]=this.hpb_1
this.Control[iCurrent+3]=this.gb_2
end on

on e01w_prt_delay03_new.destroy
call super::destroy
destroy(this.dw_saveas)
destroy(this.hpb_1)
destroy(this.gb_2)
end on

event ue_init;call super::ue_init;ii_orientation = 1
ib_margin = False

hpb_1.Hide()
gb_2.Hide()

end event

event ue_saveas;datawindow	ldw

ldw = dw_list

f_excel(ldw)

//
//
//
//
//
//
//
//
//Long	lp, ll_row,	ll_cnt, jj, ll_rowcnt
//DEC{2} ldc_amt
//String ls_payid, 	ls_tmp,	ls_ref_desc, ls_cod[], ls_val[]	
//String 	ls_eval
//
//
//ll_rowcnt = dw_list.RowCount()
//IF ll_rowcnt <= 0 then return
//
//
////파일로 저장 할 수있게
//
//ib_saveas = True
//idw_saveas = dw_saveas
//
//ls_tmp = fs_get_control("R1", "A100", ls_ref_desc)
//ll_cnt = fi_cut_string(ls_tmp, ";", ls_cod[])
//
//gb_2.Show()
//hpb_1.Show()
//
//hpb_1.Position = 0 
//Yield()
//
//dw_saveas.Reset()
//dw_list.RowsCopy(1, dw_list.RowCount(), Primary!, dw_Saveas, 1, Primary!)
//
////dw_Saveas.object.company_name.alignment = 0
////dw_Saveas.object.company_name.width = len( is_company_name ) * 40
////dw_Saveas.object.company_name.text = is_company_name
//
//
//FOR lp =  1 to ll_rowcnt
//	wf_progress(lp, ll_rowcnt)
//
//	ls_eval = dw_list.describe("Evaluate('LookUpDisplay(customerm_basecod)'," + string(lp) +")") 
//	dw_saveas.Object.customerm_basecod[lp] = ls_eval
//	
//	ls_eval = dw_list.describe("Evaluate('LookUpDisplay(customerm_status)'," + string(lp) +")") 
//	dw_saveas.Object.customerm_status[lp] = ls_eval
//	
//	ls_eval = dw_list.describe("Evaluate('LookUpDisplay(customerm_partner)'," + string(lp) +")") 
//	dw_saveas.Object.customerm_partner[lp] = ls_eval
//	
//
//	ls_payid =  dw_saveas.Object.dlymst_payid[lp]
//	//1. Balance 
//   SELECT SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) +  SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)) 
//	  INTO :ldc_amt
//     FROM REQDTL A, TRCODE B 
//    WHERE ( A.TRCOD = B.TRCOD )
//	   AND ( A.payid = :ls_payid );
//	
//	IF sqlca.sqlcode <> 0 OR IsNull(ldc_amt) then ldc_amt = 0
//	dw_saveas.Object.balance[lp] =  ldc_amt
//	
//	//2. 장비정보
//	FOR jj =  1 to 5
//		ls_val[jj] =  ''
//	NEXT
//	
//	FOR jj =  1 to ll_cnt
//		select trim(remark)   INTO :ls_tmp		  from customer_hw 
//		  where customerid 	= :ls_payid 
//		    and adtype 		= :ls_cod[jj]
//			 AND rownum 		= 1 ;
//		IF SQLCA.sqlcode <> 0 OR IsNUll(ls_tmp) then ls_tmp = ''
//		ls_val[jj] =  ls_tmp
//	NEXT
//	dw_saveas.Object.modemno[lp] 			= ls_val[1]
//	dw_saveas.Object.cableno[lp] 			= ls_val[2]
//	dw_saveas.Object.macaddr_cm[lp] 		= ls_val[3]
//	dw_saveas.Object.macaddr_vocm[lp] 	= ls_val[4]
//	dw_saveas.Object.portno[lp] 			= ls_val[5]
//	
//	
//	
//Next
//	
////IF	 is_pgm_id1 <> '' Then				
////	string ls_pgm_id
//dw_Saveas.object.date_time.alignment = 1
//dw_Saveas.object.date_time.text = is_date_time
////	
//dw_Saveas.object.title.alignment = 2
//dw_Saveas.object.title.text = is_title
////	
////	If Not Isnull( is_condition ) Then
////		If is_condition <> '' Then
////			dw_Saveas.object.condition.alignment = 2
////			dw_Saveas.object.condition.text = is_condition
////		End If			
////	End If		
////End If
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////ll_rowcnt = dw_saveas.RowCount()
////FOR lp =  1 to ll_rowcnt
////	wf_progress(lp, ll_rowcnt)
////
////	ls_payid =  dw_saveas.Object.dlymst_payid[lp]
////	//1. Balance 
////   SELECT SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) +  SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)) 
////	  INTO :ldc_amt
////     FROM REQDTL A, TRCODE B 
////    WHERE ( A.TRCOD = B.TRCOD )
////	   AND ( A.payid = :ls_payid );
////	
////	IF sqlca.sqlcode <> 0 OR IsNull(ldc_amt) then ldc_amt = 0
////	dw_saveas.Object.balance[lp] =  ldc_amt
////	
////	//2. 장비정보
////	FOR jj =  1 to 5
////		ls_val[jj] =  ''
////	NEXT
////	
////	FOR jj =  1 to ll_cnt
////		select trim(remark)   INTO :ls_tmp		  from customer_hw 
////		  where customerid 	= :ls_payid 
////		    and adtype 		= :ls_cod[jj]
////			 AND rownum 		= 1 ;
////		IF SQLCA.sqlcode <> 0 OR IsNUll(ls_tmp) then ls_tmp = ''
////		ls_val[jj] =  ls_tmp
////	NEXT
////	dw_saveas.Object.modemno[lp] 			= ls_val[1]
////	dw_saveas.Object.cableno[lp] 			= ls_val[2]
////	dw_saveas.Object.macaddr_cm[lp] 		= ls_val[3]
////	dw_saveas.Object.macaddr_vocm[lp] 	= ls_val[4]
////	dw_saveas.Object.portno[lp] 			= ls_val[5]
////Next
//gb_2.Hide()
//hpb_1.Hide()
//
//f_excel_ascii1(dw_saveas,'e01d_prt_delay03_saveas')
//
end event

type dw_cond from w_a_print`dw_cond within e01w_prt_delay03_new
integer x = 50
integer y = 36
integer width = 1742
integer height = 316
string dataobject = "e01d_cnd_prt_delay03_new"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;String ls_emp_grp,		ls_basecod
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


String ls_ref_desc
String ls_filter
INTEGER  li_exist
DataWindowChild ldwc
date	ldt_saledt


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

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm, ls_memberid

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select memberid, 		customernm
		  INTO :ls_memberid, :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_memberid) 	OR sqlca.sqlcode <> 0 	then ls_memberid 		= ""
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		 IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			return 1
		ELSE
			This.Object.customernm[1] 	=  ls_customernm
		END IF
End Choose

end event

type p_ok from w_a_print`p_ok within e01w_prt_delay03_new
integer x = 1879
integer y = 36
end type

type p_close from w_a_print`p_close within e01w_prt_delay03_new
integer x = 2190
integer y = 36
end type

type dw_list from w_a_print`dw_list within e01w_prt_delay03_new
integer x = 23
integer y = 380
integer height = 1240
string dataobject = "e01d_prt_delay03_new"
end type

event dw_list::retrieveend;call super::retrieveend;//Long 		kk
//String 	ls_val
//IF rowcount <= 0 then return
//
//FOR kk =  1 to rowcount
//	ls_val = this.describe("Evaluate('LookUpDisplay(customerm_basecod)'," + string(kk) +")") 
//	dw_list.Object.customerm_basecod[kk] = ls_val
//	
//	ls_val = this.describe("Evaluate('LookUpDisplay(customerm_status)'," + string(kk) +")") 
//	dw_list.Object.customerm_status[kk] = ls_val
//	
//	ls_val = this.describe("Evaluate('LookUpDisplay(customerm_partner)'," + string(kk) +")") 
//	dw_list.Object.customerm_partner[kk] = ls_val
//Next
//dw_saveas.Reset()
//dw_list.RowsCopy(dw_list.GetRow(), dw_list.RowCount(), Primary!, dw_Saveas, 1, Primary!)
//
//dw_Saveas.object.company_name.alignment = 0
//dw_Saveas.object.company_name.width = len( is_company_name ) * 40
//dw_Saveas.object.company_name.text = is_company_name
//	
//IF	 is_pgm_id1 <> '' Then				
//	string ls_pgm_id
//	dw_Saveas.object.date_time.alignment = 1
//	dw_Saveas.object.date_time.text = is_date_time
//	
//	dw_Saveas.object.title.alignment = 2
//	dw_Saveas.object.title.text = is_title
//	
//	If Not Isnull( is_condition ) Then
//		If is_condition <> '' Then
//			dw_Saveas.object.condition.alignment = 2
//			dw_Saveas.object.condition.text = is_condition
//		End If			
//	End If		
//End If
//
//
end event

event dw_list::constructor;//If IsNull(itrans_connect) Then
	SetTransObject(SQLCA)
//	f_modify_dw_title(this)
	
//Else
//	SetTransObject(itrans_connect)
//End If

end event

type p_1 from w_a_print`p_1 within e01w_prt_delay03_new
end type

type p_2 from w_a_print`p_2 within e01w_prt_delay03_new
end type

type p_3 from w_a_print`p_3 within e01w_prt_delay03_new
end type

type p_5 from w_a_print`p_5 within e01w_prt_delay03_new
end type

type p_6 from w_a_print`p_6 within e01w_prt_delay03_new
end type

type p_7 from w_a_print`p_7 within e01w_prt_delay03_new
end type

type p_8 from w_a_print`p_8 within e01w_prt_delay03_new
end type

type p_9 from w_a_print`p_9 within e01w_prt_delay03_new
end type

type p_4 from w_a_print`p_4 within e01w_prt_delay03_new
end type

type gb_1 from w_a_print`gb_1 within e01w_prt_delay03_new
end type

type p_port from w_a_print`p_port within e01w_prt_delay03_new
end type

type p_land from w_a_print`p_land within e01w_prt_delay03_new
end type

type gb_cond from w_a_print`gb_cond within e01w_prt_delay03_new
integer width = 1801
integer height = 364
end type

type p_saveas from w_a_print`p_saveas within e01w_prt_delay03_new
end type

type dw_saveas from datawindow within e01w_prt_delay03_new
boolean visible = false
integer x = 1870
integer y = 336
integer width = 571
integer height = 68
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "e01d_prt_delay03_saveas"
boolean livescroll = true
end type

event constructor;This.SetTransObject(SQLCA)
end event

type hpb_1 from hprogressbar within e01w_prt_delay03_new
integer x = 1865
integer y = 236
integer width = 1102
integer height = 60
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 50
integer setstep = 10
end type

type gb_2 from groupbox within e01w_prt_delay03_new
integer x = 1847
integer y = 160
integer width = 1143
integer height = 160
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "자료변환 중....."
borderstyle borderstyle = stylelowered!
end type

