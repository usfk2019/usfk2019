$PBExportHeader$ssrt_inq_report_sams.srw
$PBExportComments$보고서-SAMS
forward
global type ssrt_inq_report_sams from w_a_inq_m
end type
type cb_dr from commandbutton within ssrt_inq_report_sams
end type
type cb_xr from commandbutton within ssrt_inq_report_sams
end type
type dw_regcod from datawindow within ssrt_inq_report_sams
end type
type cb_zr from commandbutton within ssrt_inq_report_sams
end type
type p_1 from u_p_saveas within ssrt_inq_report_sams
end type
end forward

global type ssrt_inq_report_sams from w_a_inq_m
integer width = 3104
integer height = 2000
event ue_saveas ( )
cb_dr cb_dr
cb_xr cb_xr
dw_regcod dw_regcod
cb_zr cb_zr
p_1 p_1
end type
global ssrt_inq_report_sams ssrt_inq_report_sams

type variables
String is_partner, is_trdt, is_memberid, is_approvalno, &
			is_receipt,		is_operator, 	is_crtdt, is_report, &
			is_control,		is_cutoffdt, &
			is_fromdt, 		is_todt
date   idat_trdt, 		idat_crtdt, 		idt_cutoffdt, &
		 idat_fromdt,		idat_todt

end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function string wf_fill_space (string wfs_buf, string wfs_sw)
end prototypes

event ue_saveas;STRING	ls_file_name,	ls_sysdate
datawindow	ldw

ldw = dw_detail

SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') INTO :ls_sysdate
FROM   DUAL;

ls_file_name =  "Daily Report_" + ls_sysdate

f_excel_new(ldw, ls_file_name)

end event

public function integer wfi_get_customerid (string as_customerid);String ls_customernm

Select customernm
Into :ls_customernm
From customerm
Where memeberid = :as_customerid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.customernm[1] = ""
	Return -1
	
Else
	dw_cond.object.customernm[1] = ls_customernm
End If

Return 0
end function

public function string wf_fill_space (string wfs_buf, string wfs_sw);INTEGER li_len, li_lgt, li_spc, li_pre, li_next
String ls_dat

li_len = 43
li_lgt = LenA(wfs_buf)
IF wfs_sw = 'C' THEN
	IF li_lgt < li_len THEN
		li_pre = Truncate((li_len - li_lgt ) / 2, 0)
		IF li_pre > 0 THEN	ls_dat = Space(li_pre) + wfs_buf
		li_next = li_len - LenA(ls_dat)
		IF li_next > 0 then	ls_dat = ls_dat + space(li_next)
	END IF
ELSE
	li_next = li_len - li_lgt
	IF li_next > 0 then	ls_dat = wfs_buf + space(li_next)
END IF

return ls_dat
end function

on ssrt_inq_report_sams.create
int iCurrent
call super::create
this.cb_dr=create cb_dr
this.cb_xr=create cb_xr
this.dw_regcod=create dw_regcod
this.cb_zr=create cb_zr
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_dr
this.Control[iCurrent+2]=this.cb_xr
this.Control[iCurrent+3]=this.dw_regcod
this.Control[iCurrent+4]=this.cb_zr
this.Control[iCurrent+5]=this.p_1
end on

on ssrt_inq_report_sams.destroy
call super::destroy
destroy(this.cb_dr)
destroy(this.cb_xr)
destroy(this.dw_regcod)
destroy(this.cb_zr)
destroy(this.p_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: ssrt_prt_report_sams
	Desc.	: Report
	Ver.	: 1.0
	Date	: 2006.5.7
	Programer : Cho Kyung Bok(1hera)
-------------------------------------------------------------------------*/
dw_cond.object.PARTNER[1] 	= gs_shopid
dw_cond.object.issuedt[1] 	= date(fdt_get_dbserver_now())
dw_cond.object.crtdt[1] 	= date(fdt_get_dbserver_now())

dw_cond.object.fromdt[1] 	= date(fdt_get_dbserver_now())
dw_cond.object.todt[1] 	= date(fdt_get_dbserver_now())



end event

event ue_ok();String 	ls_customerid, 	ls_validkey, 	ls_worktype, 	ls_result, &
			ls_shoptype
String 	ls_fromdt, 			ls_todt, 		ls_where
Date 		ld_fromdt, 			ld_todt
Long 		ll_row
Integer 	li_check

dw_cond.AcceptText()

is_report 			= Trim(dw_cond.object.report[1])
is_memberid 		= Trim(dw_cond.object.memberid[1])
is_partner 			= Trim(dw_cond.object.partner[1])
is_approvalno 		= Trim(dw_cond.object.approvalno[1])
is_operator 		= Trim(dw_cond.object.operator[1])
is_receipt 			= Trim(dw_cond.object.receipt[1])
ls_shoptype 		= Trim(dw_cond.object.shoptype[1])

idat_trdt 			= dw_cond.object.issuedt[1]
idat_crtdt 			= dw_cond.object.crtdt[1]
idat_fromdt 		= dw_cond.object.fromdt[1]
idat_todt 			= dw_cond.object.todt[1]
is_trdt 				= String(idat_trdt, 'yyyymmdd')
is_crtdt				= String(idat_crtdt, 'yyyymmdd')
is_fromdt			= String(idat_fromdt, 'yyyymmdd')
is_todt				= String(idat_todt, 'yyyymmdd')

select max(cutoff_dt) + 1
  INTO :idt_cutoffdt
  from cutoff 
 where to_char(cutoff_dt, 'yyyymmdd') < :is_trdt ;

//IF sqlca.sqlcode < 0 THEN
//	RETURN 
//END IF
//
If IsNull(ls_shoptype) 		Then ls_shoptype 		= ""
If IsNull(is_report) 		Then is_report 		= ""
If IsNull(is_memberid) 		Then is_memberid 		= ""
If IsNull(is_partner) 		Then is_partner 		= ""
If IsNull(is_approvalno) 	Then is_approvalno 	= ""
If IsNull(is_operator) 		Then is_operator 		= ""
If IsNull(is_receipt) 		Then is_receipt 		= ""
If IsNull(is_trdt) 			Then is_trdt 			= ""
If IsNull(is_crtdt) 			Then is_crtdt 			= ""
If IsNull(is_fromdt) 		Then is_fromdt 		= ""
If IsNull(is_todt) 			Then is_todt 			= ""

IF is_partner = '' THEN
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return 
END IF
	
CHOOSE CASE is_report
	CASE '1'
		IF is_trdt = '' THEN
			dw_cond.SetFocus()
			dw_cond.SetColumn("issuedt")
			Return 
		END IF
		// 2006-12-12 수정(FROM 정희찬)
//		IF ls_shoptype = '' THEN
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("shoptype")
//			Return 
//		END IF
	CASE '2'
		IF is_fromdt = '' THEN
			dw_cond.SetFocus()
			dw_cond.SetColumn("fromdt")
			Return 
		END IF
		IF is_todt = '' THEN
			dw_cond.SetFocus()
			dw_cond.SetColumn("todt")
			Return 
		END IF
// 2006-12-12 수정 ( From 정희찬)
//		IF ls_shoptype = '' THEN
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("shoptype")
//			Return 
//		END IF
//		
	CASE '3'
		IF is_crtdt = '' THEN
			dw_cond.SetFocus()
			dw_cond.SetColumn("crtdt")
			Return 
		END IF
end choose

ls_shoptype = ls_shoptype + '%'

ls_where = ""
choose case is_report
	case '1'
		If is_partner <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "A.SHOPID = '" + is_partner + "' "
		End IF
		If is_trdt <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(A.PAYDT, 'yyyymmdd') = '" + is_trdt + "' "
		End IF
		If is_memberid <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "B.MEMBERID = '" + is_memberid + "' "
		End IF
		If ls_shoptype <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "d.regtype Like '" + ls_shoptype + "' "
		End IF
			
	case '2'
		If is_partner <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "A.SHOPID = '" + is_partner + "' "
		End IF
		If is_fromdt <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(A.PAYDT, 'yyyymmdd') >= '" + is_fromdt + "' "
		End IF
		If is_todt <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(A.PAYDT, 'yyyymmdd') <= '" + is_todt + "' "
		End IF
		If ls_shoptype <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "d.regtype Like '" + ls_shoptype + "' "
		End IF
		
	case '3'
		If is_partner <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "partner = '" + is_partner + "' "
		End IF
		If is_crtdt <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(actiondt, 'yyyymmdd') = '" + is_crtdt + "' "
		End IF
		If is_operator <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "operator = '" + is_operator + "' "
		End IF
end choose


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m`dw_cond within ssrt_inq_report_sams
integer x = 55
integer y = 44
integer width = 2167
integer height = 424
integer taborder = 0
string dataobject = "ssrt_cnd_prt_report_sams"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_rpt
dwObject ldwo_SORT


choose case dwo.name
	case 'report'
		ls_rpt = trim(data)
		choose case ls_rpt
		case '1'
			dw_detail.Reset()
			dw_detail.dataobject = 'ssrt_inq_report_daily'
			dw_detail.SetTransObject(sqlca)
			cb_dr.Visible =  True
			cb_xr.Visible =  True
			cb_dr.ENABLEd =  True
			cb_xr.Enabled =  True
			cb_zr.Visible =  False
			
		case '2'
			dw_detail.dataobject = 'ssrt_inq_report_daily'
			dw_detail.SetTransObject(sqlca)
			cb_zr.Visible =  True
			cb_zr.Enabled =  True
			cb_dr.Visible =  False
			cb_xr.Visible =  False
		case '3'
			dw_detail.dataobject = 'ssrt_inq_report_zlog'
			dw_detail.SetTransObject(sqlca)
			ldwo_SORT = Object.partner_t
			dw_detail.TriggerEvent("uf_init(ldwo_SORT)")
			cb_zr.Visible =  False
			cb_dr.Visible =  False
			cb_xr.Visible =  False
		end choose
		dw_detail.TriggerEvent("ue_init")
	case "memberid"
		wfi_get_customerid(data)
end choose

end event

event dw_cond::constructor;this.SetTransObject(sqlca)
this.InsertRow(0)
end event

event dw_cond::doubleclicked;return
end event

type p_ok from w_a_inq_m`p_ok within ssrt_inq_report_sams
integer x = 2272
integer y = 36
end type

type p_close from w_a_inq_m`p_close within ssrt_inq_report_sams
integer x = 2592
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within ssrt_inq_report_sams
integer width = 2213
integer height = 504
end type

type dw_detail from w_a_inq_m`dw_detail within ssrt_inq_report_sams
integer x = 32
integer y = 512
integer height = 1260
string dataobject = "ssrt_inq_report_daily"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT

choose case this.dataobject
	case 'ssrt_inq_report_daily'
		ldwo_SORT = Object.memberid_t
	case 'ssrt_inq_report_receipt'
		ldwo_SORT = Object.approvalno_t
	case 'ssrt_inq_report_zlog'
		ldwo_SORT = Object.partner_t
end choose

uf_init(ldwo_SORT)
end event

event dw_detail::clicked;call super::clicked;

String ls_type

ls_type = dwo.Type


end event

type cb_dr from commandbutton within ssrt_inq_report_sams
integer x = 2267
integer y = 260
integer width = 617
integer height = 112
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Daily Report"
end type

event clicked;
String ls_partner, ls_trdt, ls_memberid, ls_approval, ls_shoptype
date		ldt_trdt

//f_msg_info(9000, PARENT.Title, '자료처리 준비중이 입니다...... ')
//return


IF dw_detail.rowCount() = 0 then return

iu_cust_msg = Create u_cust_a_msg
//
ls_shoptype 	= Trim(dw_cond.object.shoptype[1]) 

iu_cust_msg.is_pgm_name = "Daily Report"
iu_cust_msg.is_grp_name = "Report"
iu_cust_msg.ib_data[1]  = True

iu_cust_msg.id_data[1] = idat_trdt
iu_cust_msg.is_data[1] = is_partner	
iu_cust_msg.is_data[2] = is_trdt		
iu_cust_msg.is_data[3] = is_memberid
iu_cust_msg.is_data[4] = ls_shoptype


 
OpenWithParm(ssrt_prt_report_daily, iu_cust_msg)
end event

type cb_xr from commandbutton within ssrt_inq_report_sams
integer x = 2267
integer y = 384
integer width = 617
integer height = 112
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "X-Reading"
end type

event clicked;Long		ll_seq, 			ll_keynum, 				ll_cnt, 			ll_cnt2, 		ll, &
			ll_acount, 		ll_totcnt_d, 			ll_totcnt_c, 	ll_shopcount, &
			jj, 				i, 						ll_row
dec{2}	ldec_payamt, 	ldec_totpayamt_d, 	ldec_totpayamt_c, ldec_total, &
			ldec_saleamt, 	ldec_grand_tot,		ldc_sum,				ldc_daily_total, &
			ldec_payamt2
DEC	 	ldc_shopCount

String 	ls_temp,			ls_seq,			ls_regtype
String	ls_shopcode,	ls_regcod, 	ls_facnum, 	ls_descript, &
			ls_lin1, 		ls_lin2, 	LS_LIN3, &
			ls_code, 		ls_codenm, &
			ls_type, 		ls_ref_desc, ls_name[], &
			ls_empnm, 		ls_approvalno,	&
			ls_itemcod,		ls_itemnm,		ls_val
Date		ldt_trdt,		ldt_shop_closedt
Integer	li_rtn,			li_reg_cnt
datetime ldt_now


//42 Column
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

IF dw_detail.RowCount() = 0 then return
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ldt_trdt 			= dw_cond.Object.issuedt[1]
is_trdt				= String(dw_cond.Object.issuedt[1], 'yyyymmdd')
ldt_shop_closedt 	= f_find_shop_closedt(is_Partner)
ls_regtype 			= trim(dw_cond.Object.shoptype[1]) + '%'
//----------------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :ll_shopcount	  From partnermst
 WHERE partner = :is_partner ;

IF IsNull(ll_shopcount) OR sqlca.sqlcode <> 0 THEN ll_shopcount = 0
ll_shopcount += 1

//1. Receipt Mater  Insert
//SEQ 
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])
ls_type 			= Trim(ls_name[4])

ldec_total 		= dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_total")

Select seq_app.nextval		  Into :ls_seq	  From dual;
insert into RECEIPTMST
				( approvalno,		shopcount,		receipttype,	shopid,			posno,
				  workdt,			trdt,				memberid,		operator,		total,
				  cash,				change,
				  customerid,		prt_yn,			seq_app)
			values 
			   ( seq_receipt.nextval,	:ll_shopcount,	:ls_type, :is_partner, 	NULL,
				  :ldt_shop_closedt,		:idat_trdt,		null,		 :gs_user_id,	:ldec_total,
				  0,					0,
				  Null, 			  'Y',	:ls_seq
				  )	 ;


//저장 실패 
If SQLCA.SQLCode < 0 Then
	f_msg_info(9000, PARENT.Title, 'RECEIPTMST 테이블에  Insert시 오류발생. 확인바랍니다.')
	RollBack;
	Return 
End If

//partnermst Update
Update partnermst
	Set shopcount 	= :ll_shopcount
	Where partner  = :is_partner ;

If SQLCA.SQLCode < 0 Then
	f_msg_info(9000, PARENT.Title, 'partnermst 테이블에  Update시 오류발생. 확인바랍니다.')
	RollBack;
	Return 
End If

//마지막으로 영수증 출력........
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

select trim(EMPNM)   into :ls_empnm  from sysusr1t 
 where emp_id =  :gs_user_id ;
IF IsNull(ls_empnm) or sqlca.sqlcode <> 0  then ls_empnm = ''

li_rtn = f_pos_header(is_partner, 'D', ll_shopcount, 1)
IF li_rtn < 0 then
	f_msg_info(9000, PARENT.Title, '영수증 출력기에 문제 발생.')
	Rollback ;
	PRN_ClosePort()
	return
END IF

ls_temp = 'Closed Date : ' + String( ldt_trdt, 'MM-DD-YYYY' ) 
F_POS_PRINT(ls_temp, 1)
F_POS_PRINT("==========================================", 1)
F_POS_PRINT("NO.           Item           Qty    Amount", 1)
F_POS_PRINT("==========================================", 1)


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//2. Item List 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ll_acount 			= 0
ll_totcnt_D			= 0
ll_totcnt_C			= 0
ldec_totpayamt_D 	= 0
ldec_totpayamt_C 	= 0

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//REGLIST read --- (+)값 인 것들
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
li_reg_cnt = dw_regcod.Retrieve(is_trdt , is_partner, ls_regtype, 'D', is_trdt)
FOR ll = 1 to li_reg_cnt
	ls_regcod = trim(dw_regcod.Object.regcod[ll])
	//regcode master read
	select keynum, 		trim(regdesc)
	  INTO :ll_keynum,	:ls_descript
	  FROM regcodmst
	 where regcod = :ls_regcod;
	 
	// Index Desciption 2008-05-06 hcjung
   SELECT indexdesc
     INTO :ls_facnum
     FROM SHOP_REGIDX
    WHERE regcod = :ls_regcod
		AND shopid = :is_partner;
	
	IF IsNull(ll_keynum) 	then ll_keynum 	= 0
	IF IsNull(ls_facnum) 	then ls_facnum 	= ""
	IF IsNull(ls_descript) 	then ls_descript 	= ""

	SELECT SUM(A.paycnt), SUM(A.PAYAMT)
	  INTO :ll_cnt,       :ldec_payamt
	  FROM DAILYPAYMENT A, REGCODMST B 
    WHERE ( A.REGCOD 							= B.REGCOD )
      AND ( A.SHOPID  							= :is_partner		)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	= :is_trdt 	 		)
	   AND ( A.regcod  							= :ls_regcod 	   )	
		AND ( A.DCTYPE 							= 'D'             ) 
		AND ( B.regtype 							Like :ls_regtype	 	);
	
	IF IsNUll(ldec_payamt) 	then ldec_payamt	= 0.0
	
	SELECT SUM(A.paycnt), SUM(A.PAYAMT)
	  INTO :ll_cnt2,       :ldec_payamt2
	  FROM DAILYPAYMENTH A, REGCODMST B 
    WHERE ( A.REGCOD 							= B.REGCOD )
      AND ( A.SHOPID  							= :is_partner		)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	= :is_trdt 	 		)
	   AND ( A.regcod  							= :ls_regcod 	   )	
		AND ( A.DCTYPE 							= 'D'             ) 
		AND ( B.regtype 							Like :ls_regtype	 	);
	
	IF IsNUll(ldec_payamt2) 	then ldec_payamt2	= 0.0
	ldec_payamt = ldec_payamt 	+ ldec_payamt2
	ll_cnt		= ll_cnt			+ ll_cnt2
	
	// 출력.....
	IF ldec_payamt <> 0 THEN
		ll_totcnt_D 		+= ll_cnt
		ldec_totpayamt_D 	+= ldec_payamt
		
		ll_acount += 1
		ls_temp = String(ll_acount, '000') + space(1) 							//순번
		ls_temp += LeftA(ls_descript + space(24), 24) + ' '   					//아이템
		ls_temp += RightA(Space(4) + String(ll_cnt, '###'), 3) + ' '   		//수량
		ls_temp += fs_convert_amt(ldec_payamt, 9)   		 						//금액
		f_printpos(ls_temp)
		
		ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
		f_printpos(ls_temp)
	END IF
Next

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
f_printpos(ls_lin1)
ls_temp = LeftA("Total" + space(28), 28) + &
          RightA(Space(3) + String(ll_totcnt_D, '###'), 3) + ' '  + &
			 fs_convert_sign(ldec_totpayamt_D, 9)
f_printpos(ls_temp)
f_printpos(ls_lin1)
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// (-) 인것들 조회
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Select Count(A.payseq) INTO :ll_cnt  
FROM DAILYPAYMENT A, REGCODMST B 
 WHERE ( A.REGCOD 							= B.REGCOD )
   AND ( A.SHOPID  							= :is_partner		)
	AND ( to_char(A.paydt, 'yyyymmdd') 	= :is_trdt 	 		)
	AND ( A.DCTYPE 							= 'C'             ) 
	AND ( b.regtype 							Like :ls_regtype 		);

IF IsNull(ll_cnt) OR SQLCA.SQLCODE <> 0  then ll_cnt = 0

Select Count(A.payseq) INTO :ll_cnt2  
FROM DAILYPAYMENTH A, REGCODMST B 
 WHERE ( A.REGCOD 							= B.REGCOD )
   AND ( A.SHOPID  							= :is_partner		)
	AND ( to_char(A.paydt, 'yyyymmdd') 	= :is_trdt 	 		)
	AND ( A.DCTYPE 							= 'C'             ) 
	AND ( b.regtype 							Like :ls_regtype 		);

IF IsNull(ll_cnt2) OR SQLCA.SQLCODE <> 0 then ll_cnt2 = 0
ll_cnt = ll_cnt + ll_cnt2

//=========================================
//환불 영수증 처리
IF ll_cnt <> 0 then
	f_printpos("Return ********************")
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//REGLIST read
	li_reg_cnt = dw_regcod.Retrieve(is_trdt , is_partner, ls_regtype, 'C', is_trdt)
	FOR ll =  1 to li_reg_cnt
		ls_regcod = trim(dw_regcod.Object.regcod[ll])
		
		//regcode master read
		SELECT keynum, 		trim(regdesc)
	  	  INTO :ll_keynum,	:ls_descript
	     FROM regcodmst
	 	 WHERE regcod = :ls_regcod;
	 
		// Index Desciption 2008-05-06 hcjung
	   SELECT indexdesc
   	  INTO :ls_facnum
	     FROM SHOP_REGIDX
	    WHERE regcod = :ls_regcod
			AND shopid = :is_partner;
		 
		IF IsNull(ll_keynum) 	then ll_keynum 	= 0
		IF IsNull(ls_facnum) 	then ls_facnum 	= ""
		IF IsNull(ls_descript) 	then ls_descript 	= ""
		
		SELECT sum(A.paycnt), 	SUM(A.PAYAMT)
		  INTO :ll_cnt, 			:ldec_payamt
		  FROM DAILYPAYMENT A, 	REGCODMST B 
       WHERE ( A.REGCOD 							= B.REGCOD )
         AND ( A.SHOPID  							= :is_partner		)
   	 	AND ( to_char(A.paydt, 'yyyymmdd')	= :is_trdt 	 		)
   	   AND ( A.regcod  							= :ls_regcod 	   )	
   		AND ( A.DCTYPE 							= 'C'             ) 
   		AND ( B.regtype 							Like :ls_regtype	 	);
		
		IF IsNUll(ldec_payamt) 	OR sqlca.sqlcode < 0 then ldec_payamt	= 0.0
		IF IsNUll(ll_cnt) 	OR sqlca.sqlcode < 0 then ll_cnt = 0
		
		
		SELECT sum(A.paycnt), 	SUM(A.PAYAMT)
		  INTO :ll_cnt2, 			:ldec_payamt2
		  FROM DAILYPAYMENTH A, 	REGCODMST B 
       WHERE ( A.REGCOD 							= B.REGCOD )
         AND ( A.SHOPID  							= :is_partner		)
   	 	AND ( to_char(A.paydt, 'yyyymmdd')	= :is_trdt 	 		)
   	   AND ( A.regcod  							= :ls_regcod 	   )	
   		AND ( A.DCTYPE 							= 'C'             ) 
   		AND ( B.regtype 							Like :ls_regtype	 	);
		
		IF IsNUll(ldec_payamt2) 	OR sqlca.sqlcode < 0 then ldec_payamt2	= 0.0
		IF IsNUll(ll_cnt2) 	OR sqlca.sqlcode < 0 then ll_cnt2 = 0
		
		ldec_payamt = ldec_payamt + ldec_payamt2
		ll_cnt = ll_cnt + ll_cnt2
		// 출력.....
		IF ldec_payamt <> 0 THEN
			ll_totcnt_C 		+= ll_cnt
			ldec_totpayamt_C 	+= ldec_payamt 
			
			ll_acount 	+= 1
			ls_temp 		= String(ll_acount, '000') 				+ ' '	//순번
			ls_temp 		+= LeftA(ls_descript + space(24), 24) 	+ ' '	//아이템
			ls_temp 		+= RightA(Space(3) + String(ll_cnt), 3) + ' ' //수량
			ls_temp 		+= fs_convert_amt(ldec_payamt, 9)				//금액
			f_printpos(ls_temp)
			
			ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
			f_printpos(ls_temp)
		END IF
	NEXT
	f_printpos(ls_lin1)
	ls_temp =  	LeftA("Return Total" + space(28), 28) + &
				  	RightA(Space(3) + String(ll_totcnt_C), 3) + ' ' + &
   				fs_convert_sign(ldec_totpayamt_C, 9)
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
END IF
//환불 영수증 END

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// Paymethod 별 합계
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 DECLARE read_Paymethod CURSOR FOR  
  SELECT code,      codenm
    FROM syscod2t
   WHERE ( grcode = 'B310' and use_yn = 'Y' ) 
ORDER BY code ASC  ;
//=============================================================
open read_Paymethod;
fetch read_Paymethod into :ls_code, :ls_codenm;

do while sqlca.sqlcode = 0 
	SELECT SUM(A.PAYAMT)  INTO :ldec_payamt	  
	  FROM DAILYPAYMENT A, REGCODMST B
    WHERE ( A.REGCOD								= B.REGCOD )
	   AND ( A.SHOPID  							= :is_partner	)
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :is_trdt 	 	)
		AND ( B.REGTYPE 							Like :ls_regtype )
	   AND ( A.paymethod							= :ls_code 	   )	 ;
	
	IF IsNUll(ldec_payamt) 	then ldec_payamt	= 0.0
	
	SELECT SUM(A.PAYAMT)  INTO :ldec_payamt2
	  FROM DAILYPAYMENTH A, REGCODMST B
    WHERE ( A.REGCOD								= B.REGCOD )
	   AND ( A.SHOPID  							= :is_partner	)
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :is_trdt 	 	)
		AND ( B.REGTYPE 							Like :ls_regtype )
	   AND ( A.paymethod							= :ls_code 	   )	 ;
	
	IF IsNUll(ldec_payamt2) 	then ldec_payamt2	= 0

	ldec_payamt = ldec_payamt + ldec_payamt2
	
	// 출력.....
	IF ldec_payamt <> 0 THEN
		ls_temp 	=  LeftA(ls_codenm + space(29), 29)  //Paymethod명
		ls_temp 	+= fs_convert_sign(ldec_payamt, 12) //금액
		f_printpos(ls_temp)
	END IF
	fetch read_Paymethod into :ls_code, :ls_codenm;
loop
close read_Paymethod ;
f_printpos(ls_lin1)


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//No Sale 건수
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])

ls_type = Trim(ls_name[3])
select Count(*) INTO :ll_Cnt FROM receiptmst
 where shopid 								= :is_partner
   AND to_char(paydt, 'yyyymmdd') 	= :is_trdt
	AND receipttype 						= :ls_type ;

IF IsNull(ll_cnt) 		then ll_cnt = 0
IF ll_cnt <> 0 then
	ls_temp = LeftA("No Sale" + space(28), 28)+ RightA(  space(3) + String(ll_cnt), 3)
	f_printpos(ls_temp)
END IF
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// Daily Sales  Total
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ldec_grand_tot =  ldec_totpayamt_D + ldec_totpayamt_C
IF ldec_grand_tot <> 0 THEN
	f_printpos(ls_lin3)
	ls_temp =  LeftA("Daily Sales Total" + space(29), 29) + &
				  fs_convert_sign(ldec_grand_tot, 12)
	f_printpos(ls_temp)
	f_printpos(ls_lin3)
END IF
//--------------------------------------------
//2007-7-29 add --> By 정희찬
//2007-8-26 Modify --> By Ojh & jung
ldt_now 	= fdt_get_dbserver_now()
ls_temp  = "Printing Date : " + String( Date( ldt_now ), 'MM-DD-YYYY' ) + '  ' + String( Time( ldt_now ), 'hh:mm:ss' )
f_printpos(ls_temp)

ls_temp  = "Approval No :     " + ls_seq
f_printpos(ls_temp)
ls_temp  = "Staff Name  :     " + ls_empnm
f_printpos(ls_temp)

PRN_LF(1)

//--------------------------------------------
//Grand Total add --2007-8-26
//--------------------------------------------
// ldec_grand_tot + 전날까지의 Summary
// Program Startting Date ==>> 2006-8-27 ==> System Default
// GS_STARTDT

	SELECT SUM(A.SUM) INTO :ldc_sum 
	  FROM DAILYPAYMENT_SUM A
	 WHERE TO_CHAR(A.PAYDT, 'YYYYMMDD')  	>= :GS_STARTDT
	   AND TO_CHAR(A.PAYDT, 'YYYYMMDD')  	< :is_trdt
	   AND A.SHOPID 								= :is_partner 
		AND A.regtype 								Like :ls_REGtype ;

IF sqlca.sqlcode < 0 OR IsNull(ldc_sum) then ldc_sum = 0

ldc_daily_total = ldec_grand_tot + ldc_sum

f_printpos(ls_lin3)
ls_temp =  LeftA("Grand Total" + space(29), 29) + &
			  fs_convert_sign(ldc_daily_total, 12)
f_printpos(ls_temp)
f_printpos(ls_lin3)
PRN_LF(1)
//===========================================================
f_printpos("CS : 0505-122-1891, 031-617-1891")
f_printpos("Toll Free : 080-850-1891")
f_printpos("Email : lgservicerep@chol.com")
PRN_LF(1)
F_POS_PRINT("http://i-mnet.uplus.co.kr", 2)
F_POS_PRINT("Thank you for using LG Uplus service", 2)

PRN_LF(4)
PRN_CUT()
PRN_ClosePort()
Commit ;
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//   출력 완료	
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
f_msg_info(9000, PARENT.Title, 'X-Report 처리 완료.')
Return 



end event

type dw_regcod from datawindow within ssrt_inq_report_sams
boolean visible = false
integer x = 2267
integer y = 428
integer width = 571
integer height = 72
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_inq_report_regcod"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;THIS.SetTransObject(sqlca)
end event

type cb_zr from commandbutton within ssrt_inq_report_sams
boolean visible = false
integer x = 2267
integer y = 252
integer width = 617
integer height = 112
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "Z-Report"
end type

event clicked;Long		ll_seq, 			ll_keynum, 				ll_cnt, ll_cnt2, ll, &
			ll_acount, 		ll_totcnt_d, 			ll_totcnt_c, ll_shopcount, &
			jj, 				i, 						ll_row
dec{2}	ldec_payamt, 	ldec_totpayamt_d, 	ldec_totpayamt_c, ldec_total, &
			ldec_saleamt, 	ldec_grand_tot,		ldc_sum,				ldc_daily_total, &
			ldec_payamt2
DEC	 ldc_shopCount

String 	ls_temp,			ls_seq,			ls_regtype
String	ls_shopcode,	ls_regcod, 	ls_facnum, 	ls_descript, &
			ls_lin1, 		ls_lin2, 	LS_LIN3, &
			ls_code, 		ls_codenm, &
			ls_type, 		ls_ref_desc, ls_name[], &
			ls_empnm, 		ls_approvalno,	&
			ls_itemcod,		ls_itemnm,		ls_val
Date		ldt_trdt,		ldt_shop_closedt
Integer	li_rtn,			li_reg_cnt
datetime ldt_now


//42 Column
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

IF dw_detail.RowCount() = 0 then return
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ldt_shop_closedt 	= f_find_shop_closedt(is_Partner)
ls_regtype 			= trim(dw_cond.Object.shoptype[1]) + '%'
//----------------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :ll_shopcount	  From partnermst
 WHERE partner = :is_partner ;

IF IsNull(ll_shopcount) OR sqlca.sqlcode <> 0 THEN ll_shopcount = 0
ll_shopcount += 1

//1. Receipt Mater  Insert
//SEQ 
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])
//ls_type 			= Trim(ls_name[5])

ls_type 			= '500'

ldec_total 		= dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_total")

Select seq_app.nextval		  Into :ls_seq	  From dual;
insert into RECEIPTMST
				( approvalno,		shopcount,		receipttype,	shopid,			posno,
				  workdt,			trdt,				memberid,		operator,		total,
				  cash,				change,
				  customerid,		prt_yn,			seq_app)
			values 
			   ( seq_receipt.nextval,	:ll_shopcount,	:ls_type, :is_partner, 	NULL,
				  :ldt_shop_closedt,		sysdate,		null,		 :gs_user_id,	:ldec_total,
				  0,					0,
				  Null, 			  'Y',	:ls_seq
				  )	 ;


//저장 실패 
If SQLCA.SQLCode < 0 Then
	f_msg_info(9000, PARENT.Title, 'RECEIPTMST 테이블에  Insert시 오류발생. 확인바랍니다.')
	RollBack;
	Return 
End If

//partnermst Update
Update partnermst
	Set shopcount 	= :ll_shopcount
	Where partner  = :is_partner ;

If SQLCA.SQLCode < 0 Then
	f_msg_info(9000, PARENT.Title, 'partnermst 테이블에  Update시 오류발생. 확인바랍니다.')
	RollBack;
	Return 
End If

//마지막으로 영수증 출력........
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

select trim(EMPNM)   into :ls_empnm  from sysusr1t 
 where emp_id =  :gs_user_id ;
IF IsNull(ls_empnm) or sqlca.sqlcode <> 0  then ls_empnm = ''

li_rtn = f_pos_header(is_partner, 'E', ll_shopcount, 1)
IF li_rtn < 0 then
	f_msg_info(9000, PARENT.Title, '영수증 출력기에 문제 발생.')
	Rollback ;
	PRN_ClosePort()
	return
END IF

ls_temp = 'Sales Period : ' + String( idat_fromdt, 'MM-DD-YYYY') + ' - ' +  String( idat_todt, 'MM-DD-YYYY')
F_POS_PRINT(ls_temp, 1)
F_POS_PRINT("==========================================", 1)
F_POS_PRINT("NO.           Item           Qty    Amount", 1)
F_POS_PRINT("==========================================", 1)


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//2. Item List 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ll_acount 			= 0
ll_totcnt_D			= 0
ll_totcnt_C			= 0
ldec_totpayamt_D 	= 0
ldec_totpayamt_C 	= 0

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//REGLIST read --- (+)값 인 것들
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
li_reg_cnt = dw_regcod.Retrieve(is_fromdt , is_partner, ls_regtype, 'D', is_todt)
FOR ll = 1 to li_reg_cnt
	ls_regcod = trim(dw_regcod.Object.regcod[ll])
	//regcode master read
	select keynum, 		trim(regdesc)
	  INTO :ll_keynum,	:ls_descript
	  FROM regcodmst
	 where regcod = :ls_regcod ;
	 
	// Index Desciption 2008-05-06 hcjung
   SELECT indexdesc
     INTO :ls_facnum
     FROM SHOP_REGIDX
    WHERE regcod = :ls_regcod
		AND shopid = :is_partner;	 
	 
	IF IsNull(ll_keynum) 	then ll_keynum 	= 0
	IF IsNull(ls_facnum) 	then ls_facnum 	= ""
	IF IsNull(ls_descript) 	then ls_descript 	= ""

	SELECT SUM(A.paycnt), SUM(A.PAYAMT)
	  INTO :ll_cnt,       :ldec_payamt
	  FROM DAILYPAYMENT A, REGCODMST B 
    WHERE ( A.REGCOD 							= B.REGCOD )
      AND ( A.SHOPID  							= :is_partner		)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	   AND ( A.regcod  							= :ls_regcod 	   )	
		AND ( A.DCTYPE 							= 'D'             ) 
		AND ( B.regtype 							Like :ls_regtype	 	)
		;
	
	IF IsNUll(ldec_payamt) 	then ldec_payamt	= 0.0
	
	SELECT SUM(A.paycnt), SUM(A.PAYAMT)
	  INTO :ll_cnt2,       :ldec_payamt2
	  FROM DAILYPAYMENTH A, REGCODMST B 
    WHERE ( A.REGCOD 							= B.REGCOD        )
      AND ( A.SHOPID  							= :is_partner		)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	   AND ( A.regcod  							= :ls_regcod 	   )	
		AND ( A.DCTYPE 							= 'D'             ) 
		AND ( B.regtype 							Like :ls_regtype	 	)
		;
	
	IF IsNUll(ldec_payamt2) 	then ldec_payamt2	= 0.0
	ldec_payamt = ldec_payamt 	+ ldec_payamt2
	ll_cnt		= ll_cnt			+ ll_cnt2
	
	// 출력.....
	IF ldec_payamt <> 0 THEN
		ll_totcnt_D 		+= ll_cnt
		ldec_totpayamt_D 	+= ldec_payamt
		
		ll_acount += 1
		ls_temp = String(ll_acount, '000') + space(1) 							//순번
		ls_temp += LeftA(ls_descript + space(24), 24) + ' '   					//아이템
		ls_temp += RightA(Space(4) + String(ll_cnt, '###'), 3) + ' '   		//수량
		ls_temp += fs_convert_amt(ldec_payamt, 9)   		 						//금액
		f_printpos(ls_temp)
		
		ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
		f_printpos(ls_temp)
	END IF
Next

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
f_printpos(ls_lin1)
ls_temp = LeftA("Total" + space(28), 28) + &
          RightA(Space(3) + String(ll_totcnt_D, '###'), 3) + ' '  + &
			 fs_convert_sign(ldec_totpayamt_D, 9)
f_printpos(ls_temp)
f_printpos(ls_lin1)
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// (-) 인것들 조회
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Select Count(A.payseq) INTO :ll_cnt  
FROM DAILYPAYMENT A, REGCODMST B 
 WHERE ( A.REGCOD 							= B.REGCOD )
   AND ( A.SHOPID  							= :is_partner		)
 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	AND ( A.DCTYPE 							= 'C'             ) 
	AND ( b.regtype 							Like :ls_regtype 		)
	;

IF IsNull(ll_cnt) OR SQLCA.SQLCODE <> 0  then ll_cnt = 0

Select Count(A.payseq) INTO :ll_cnt2  
FROM DAILYPAYMENTH A, REGCODMST B 
 WHERE ( A.REGCOD 							= B.REGCOD )
   AND ( A.SHOPID  							= :is_partner		)
 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	AND ( A.DCTYPE 							= 'C'             ) 
	AND ( b.regtype 							Like :ls_regtype 		)
	;

IF IsNull(ll_cnt2) OR SQLCA.SQLCODE <> 0 then ll_cnt2 = 0
ll_cnt = ll_cnt + ll_cnt2

////=========================================
////환불 영수증 처리
IF ll_cnt <> 0 then
	f_printpos("Refund ********************")
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//REGLIST read
	li_reg_cnt = dw_regcod.Retrieve(is_fromdt , is_partner, ls_regtype, 'C', is_todt)
	FOR ll =  1 to li_reg_cnt
		ls_regcod = trim(dw_regcod.Object.regcod[ll])
		
		//regcode master read
		select keynum, 		trim(regdesc)
		  INTO :ll_keynum,	:ls_descript
		  FROM regcodmst
		 where regcod = :ls_regcod ;
		 
		// Index Desciption 2008-05-06 hcjung
	   SELECT indexdesc
	     INTO :ls_facnum
	     FROM SHOP_REGIDX
	    WHERE regcod = :ls_regcod
			AND shopid = :is_partner;
		 
		IF IsNull(ll_keynum) 	then ll_keynum 	= 0
		IF IsNull(ls_facnum) 	then ls_facnum 	= ""
		IF IsNull(ls_descript) 	then ls_descript 	= ""
		
		SELECT sum(A.paycnt), 	SUM(A.PAYAMT)
		  INTO :ll_cnt, 			:ldec_payamt
		  FROM DAILYPAYMENT A, 	REGCODMST B 
       WHERE ( A.REGCOD 							= B.REGCOD )
         AND ( A.SHOPID  							= :is_partner		)
		 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
		 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
   	   AND ( A.regcod  							= :ls_regcod 	   )	
   		AND ( A.DCTYPE 							= 'C'             ) 
   		AND ( B.regtype 							Like :ls_regtype	 	);
		
		IF IsNUll(ldec_payamt) 	OR sqlca.sqlcode < 0 then ldec_payamt	= 0.0
		IF IsNUll(ll_cnt) 	OR sqlca.sqlcode < 0 then ll_cnt = 0
		
		
		SELECT sum(A.paycnt), 	SUM(A.PAYAMT)
		  INTO :ll_cnt2, 			:ldec_payamt2
		  FROM DAILYPAYMENTH A, 	REGCODMST B 
       WHERE ( A.REGCOD 							= B.REGCOD )
         AND ( A.SHOPID  							= :is_partner		)
		 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
 			AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
   	   AND ( A.regcod  							= :ls_regcod 	   )	
   		AND ( A.DCTYPE 							= 'C'             ) 
   		AND ( B.regtype 							Like :ls_regtype	 	);
		
		IF IsNUll(ldec_payamt2) 	OR sqlca.sqlcode < 0 then ldec_payamt2	= 0.0
		IF IsNUll(ll_cnt2) 	OR sqlca.sqlcode < 0 then ll_cnt2 = 0
		
		ldec_payamt = ldec_payamt + ldec_payamt2
		ll_cnt = ll_cnt + ll_cnt2
		// 출력.....
		IF ldec_payamt <> 0 THEN
			ll_totcnt_C 		+= ll_cnt
			ldec_totpayamt_C 	+= ldec_payamt 
			
			ll_acount 	+= 1
			ls_temp 		= String(ll_acount, '000') 				+ ' '	//순번
			ls_temp 		+= LeftA(ls_descript + space(24), 24) 	+ ' '	//아이템
			ls_temp 		+= RightA(Space(3) + String(ll_cnt), 3) + ' ' //수량
			ls_temp 		+= fs_convert_amt(ldec_payamt, 9)				//금액
			f_printpos(ls_temp)
			
			ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
			f_printpos(ls_temp)
		END IF
	NEXT
	f_printpos(ls_lin1)
	ls_temp =  	LeftA("Refund Total" + space(28), 28) + &
				  	RightA(Space(3) + String(ll_totcnt_C), 3) + ' ' + &
   				fs_convert_sign(ldec_totpayamt_C, 9)
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
END IF
//환불 영수증 END

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// Paymethod 별 합계
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
 DECLARE read_Paymethod CURSOR FOR  
  SELECT code,      codenm
    FROM syscod2t
   WHERE ( grcode = 'B310' and use_yn = 'Y' ) 
ORDER BY code ASC  ;
//=============================================================
open read_Paymethod;
fetch read_Paymethod into :ls_code, :ls_codenm;

do while sqlca.sqlcode = 0 
	SELECT SUM(A.PAYAMT)  INTO :ldec_payamt	  
	  FROM DAILYPAYMENT A, REGCODMST B
    WHERE ( A.REGCOD								= B.REGCOD )
	   AND ( A.SHOPID  							= :is_partner	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	   AND ( A.paymethod							= :ls_code 	   )	
		AND ( B.REGTYPE 							Like :ls_regtype );
	
	IF IsNUll(ldec_payamt) 	then ldec_payamt	= 0.0
	
	SELECT SUM(A.PAYAMT)  INTO :ldec_payamt2
	  FROM DAILYPAYMENTH A, REGCODMST B
    WHERE ( A.REGCOD								= B.REGCOD )
	   AND ( A.SHOPID  							= :is_partner	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	   AND ( A.paymethod							= :ls_code 	   )	 
		AND ( B.REGTYPE 							Like :ls_regtype ) ;
	
	IF IsNUll(ldec_payamt2) 	then ldec_payamt2	= 0

	ldec_payamt = ldec_payamt + ldec_payamt2
	
	// 출력.....
	IF ldec_payamt <> 0 THEN
		ls_temp 	=  LeftA(ls_codenm + space(29), 29)  //Paymethod명
		ls_temp 	+= fs_convert_sign(ldec_payamt, 12) //금액
		f_printpos(ls_temp)
	END IF
	fetch read_Paymethod into :ls_code, :ls_codenm;
loop
close read_Paymethod ;
f_printpos(ls_lin1)


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//No Sale 건수
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])

ls_type = Trim(ls_name[3])
select Count(*) INTO :ll_Cnt FROM receiptmst
 where shopid 								= :is_partner
 	AND ( to_char(A.paydt, 'yyyymmdd')	>= :is_fromdt 	 	)
 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	AND receipttype 							= :ls_type ;

IF IsNull(ll_cnt) 		then ll_cnt = 0
IF ll_cnt <> 0 then
	ls_temp = LeftA("No Sale" + space(28), 28)+ RightA(  space(3) + String(ll_cnt), 3)
	f_printpos(ls_temp)
END IF
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// Daily Sales  Total
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ldec_grand_tot =  ldec_totpayamt_D + ldec_totpayamt_C
IF ldec_grand_tot <> 0 THEN
	f_printpos(ls_lin3)
	ls_temp =  LeftA("Monthly Sales Total" + space(29), 29) + &
				  fs_convert_sign(ldec_grand_tot, 12)
	f_printpos(ls_temp)
	f_printpos(ls_lin3)
END IF
//--------------------------------------------
//2007-7-29 add --> By 정희찬
//2007-8-26 Modify --> By Ojh & jung
ldt_now 	= fdt_get_dbserver_now()
ls_temp  = "Printing Date : " + String( Date( ldt_now ), 'MM-DD-YYYY' ) + '  ' + String( Time( ldt_now ), 'hh:mm:ss' )
f_printpos(ls_temp)

ls_temp  = "Approval No :     " + ls_seq
f_printpos(ls_temp)
ls_temp  = "Staff Name  :     " + ls_empnm
f_printpos(ls_temp)

PRN_LF(1)

//--------------------------------------------
//Grand Total add --2007-8-26
//--------------------------------------------
// ldec_grand_tot + 전날까지의 Summary
// Program Startting Date ==>> 2006-8-27 ==> System Default
// GS_STARTDT

	SELECT SUM(A.SUM) INTO :ldc_sum 
	  FROM DAILYPAYMENT_SUM A
	 WHERE ( to_char(A.paydt, 'yyyymmdd')	>= :GS_STARTDT 	)
	 	AND ( to_char(A.paydt, 'yyyymmdd')	<= :is_todt 	 	)
	   AND A.SHOPID 								= :is_partner  
		AND A.regtype 								Like :ls_REGtype ;

IF sqlca.sqlcode < 0 OR IsNull(ldc_sum) then ldc_sum = 0

ldc_daily_total = ldec_grand_tot 
//+ ldc_sum

f_printpos(ls_lin3)
ls_temp =  LeftA("Grand Total" + space(29), 29) + &
			  fs_convert_sign(ldc_sum, 12)
f_printpos(ls_temp)
f_printpos(ls_lin3)
PRN_LF(1)
//===========================================================
f_printpos("CS : 0505-122-1891, 031-617-1891")
f_printpos("Toll Free : 080-850-1891")
f_printpos("Email : lgservicerep@chol.com")
PRN_LF(1)
//F_POS_PRINT("www.i-mnet.com", 2)
F_POS_PRINT("http://i-mnet.uplus.co.kr", 2)
F_POS_PRINT("Thank you for using LG Uplus service", 2)

PRN_LF(4)
PRN_CUT()
PRN_ClosePort()
Commit ;
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//   출력 완료	
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
f_msg_info(9000, PARENT.Title, 'Z-Report 처리 완료.')
Return 



end event

type p_1 from u_p_saveas within ssrt_inq_report_sams
integer x = 2272
integer y = 144
boolean bringtotop = true
end type

