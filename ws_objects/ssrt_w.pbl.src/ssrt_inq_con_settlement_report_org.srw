$PBExportHeader$ssrt_inq_con_settlement_report_org.srw
$PBExportComments$[kem] aafes settlement report
forward
global type ssrt_inq_con_settlement_report_org from w_a_inq_m
end type
type cb_dr from commandbutton within ssrt_inq_con_settlement_report_org
end type
type dw_regcod from datawindow within ssrt_inq_con_settlement_report_org
end type
type p_1 from u_p_saveas within ssrt_inq_con_settlement_report_org
end type
end forward

global type ssrt_inq_con_settlement_report_org from w_a_inq_m
integer width = 3241
integer height = 2000
event ue_saveas ( )
cb_dr cb_dr
dw_regcod dw_regcod
p_1 p_1
end type
global ssrt_inq_con_settlement_report_org ssrt_inq_con_settlement_report_org

type variables

end variables

forward prototypes
public function string wf_fill_space (string wfs_buf, string wfs_sw)
end prototypes

event ue_saveas();STRING	ls_file_name,	ls_sysdate
datawindow	ldw

ldw = dw_detail

SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') INTO :ls_sysdate
FROM   DUAL;

ls_file_name =  "SettlementReport_" + ls_sysdate

f_excel_new(ldw, ls_file_name)

end event

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

on ssrt_inq_con_settlement_report_org.create
int iCurrent
call super::create
this.cb_dr=create cb_dr
this.dw_regcod=create dw_regcod
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_dr
this.Control[iCurrent+2]=this.dw_regcod
this.Control[iCurrent+3]=this.p_1
end on

on ssrt_inq_con_settlement_report_org.destroy
call super::destroy
destroy(this.cb_dr)
destroy(this.dw_regcod)
destroy(this.p_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: ssrt_inq_con_settlement_report
	Desc.	: Report
	Ver.	: 1.0
	Date	: 2011.10.11
	Programer : kem
-------------------------------------------------------------------------*/
DEC{2}	ldc_cash_hand
Date     ldt_fromdt, ldt_todt

dw_cond.object.PARTNER[1] 	= gs_shopid

SELECT NVL(CASH_HAND, 0) INTO :ldc_cash_hand
FROM   PARTNERMST
WHERE  PARTNER = :gs_shopid;

dw_cond.Object.cash_hand[1] = ldc_cash_hand
dw_cond.object.issuedt[1]   = date(fdt_get_dbserver_now())
ldt_fromdt                  = f_mon_first_date(dw_cond.Object.issuedt[1])
ldt_todt                    = f_mon_last_date(dw_cond.Object.issuedt[1])
dw_cond.Object.fromdt[1]    = ldt_fromdt
dw_cond.Object.todt[1]      = ldt_todt



end event

event ue_ok();String 	ls_where, ls_shoptype, ls_shopid
String 	ls_issuedt, ls_fromdt, ls_todt
Date 		ldt_issuedt, ldt_fromdt, ldt_todt
Long 		ll_row

dw_cond.AcceptText()

ls_shopid 			= Trim(dw_cond.object.partner[1])
ls_shoptype 		= Trim(dw_cond.object.shoptype[1])

ldt_issuedt		= dw_cond.object.issuedt[1]
ldt_fromdt 		= dw_cond.object.fromdt[1]
ldt_todt 		= dw_cond.object.todt[1]
ls_issuedt		= String(ldt_issuedt, 'yyyymmdd')
ls_fromdt		= String(ldt_fromdt, 'yyyymmdd')
ls_todt			= String(ldt_todt, 'yyyymmdd')

//select max(cutoff_dt) + 1
//  INTO :idt_cutoffdt
//  from cutoff 
// where to_char(cutoff_dt, 'yyyymmdd') < :is_trdt ;
//
//IF sqlca.sqlcode < 0 THEN
//	RETURN 
//END IF

If IsNull(ls_shoptype) 		Then ls_shoptype 		= ""
If IsNull(ls_shopid) 		Then ls_shopid 		= ""
If IsNull(ls_issuedt) 		Then ls_issuedt 			= ""
If IsNull(ls_fromdt) 		Then ls_fromdt 		= ""
If IsNull(ls_todt) 			Then ls_todt 			= ""

IF ls_shopid = '' THEN
	f_msg_info(200, title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return 
END IF
	
IF ls_issuedt = '' THEN
	f_msg_info(200, title, "Sales Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("issuedt")
	Return 
END IF

IF ls_shoptype = '' THEN
	f_msg_info(200, title, "Shop Type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("shoptype")
	Return 
END IF

IF ls_fromdt = '' THEN
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return 
END IF
IF ls_todt = '' THEN
	dw_cond.SetFocus()
	dw_cond.SetColumn("todt")
	Return 
END IF

ls_shoptype = ls_shoptype + '%'

ls_where = ""

If ls_shopid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.SHOPID = '" + ls_shopid + "' "
End IF

//If ls_issuedt <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "to_char(A.PAYDT, 'yyyymmdd') = '" + ls_issuedt + "' "
//End IF

If ls_shoptype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "d.regtype Like '" + ls_shoptype + "' "
End IF
	
If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(A.PAYDT, 'yyyymmdd') >= '" + ls_fromdt + "' "
End IF
If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(A.PAYDT, 'yyyymmdd') <= '" + ls_todt + "' "
End IF


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m`dw_cond within ssrt_inq_con_settlement_report_org
integer x = 55
integer y = 60
integer width = 2167
integer height = 284
integer taborder = 0
string dataobject = "ssrt_cnd_inq_con_settlement_report"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Date     ldt_fromdt, ldt_todt
DEC{2}	ldc_cash_hand


Choose Case dwo.name
//	Case "partner"	
//		SELECT NVL(CASH_HAND, 0) INTO :ldc_cash_hand
//		FROM   PARTNERMST
//		WHERE  PARTNER = :data;
//		
//		THIS.Object.cash_hand[1] = ldc_cash_hand
	
	Case "issuedt"
		ldt_fromdt = f_mon_first_date(Date(data))
		ldt_todt   = f_mon_last_date(Date(data))
		dw_cond.Object.fromdt[1] = ldt_fromdt
		dw_cond.Object.todt[1]   = ldt_todt
End Choose

end event

event dw_cond::constructor;call super::constructor;//this.SetTransObject(sqlca)
//this.InsertRow(0)
end event

type p_ok from w_a_inq_m`p_ok within ssrt_inq_con_settlement_report_org
integer x = 2290
end type

type p_close from w_a_inq_m`p_close within ssrt_inq_con_settlement_report_org
integer x = 2885
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within ssrt_inq_con_settlement_report_org
integer width = 2213
integer height = 380
end type

type dw_detail from w_a_inq_m`dw_detail within ssrt_inq_con_settlement_report_org
integer x = 32
integer y = 400
integer width = 3150
integer height = 1372
string dataobject = "ssrt_inq_report_daily_new"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT

choose case this.dataobject
	case 'ssrt_inq_report_daily_new'
		ldwo_SORT = Object.memberid_t
	case 'ssrt_inq_report_receipt_new'
		ldwo_SORT = Object.approvalno_t
	case 'ssrt_inq_report_zlog_new'
		ldwo_SORT = Object.partner_t
end choose

uf_init(ldwo_SORT)
end event

event dw_detail::clicked;call super::clicked;

String ls_type

ls_type = dwo.Type


end event

type cb_dr from commandbutton within ssrt_inq_con_settlement_report_org
integer x = 2295
integer y = 200
integer width = 617
integer height = 124
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Settlement Report"
end type

event clicked;
String ls_shopid, ls_shoptype, ls_issuedt, ls_fromdt, ls_todt
date	 ldt_issuedt

//f_msg_info(9000, PARENT.Title, '자료처리 준비중이 입니다...... ')
//return

ls_shopid 		= Trim(dw_cond.object.partner[1])
ls_shoptype 	= Trim(dw_cond.object.shoptype[1])
ldt_issuedt    = dw_cond.Object.issuedt[1]
ls_issuedt		= String(dw_cond.Object.issuedt[1], 'yyyymmdd')
ls_fromdt		= String(dw_cond.Object.fromdt[1], 'yyyymmdd')
ls_todt			= String(dw_cond.Object.todt[1], 'yyyymmdd')

If IsNull(ls_shoptype) 		Then ls_shoptype 		= ""
If IsNull(ls_shopid) 		Then ls_shopid 		= ""
If IsNull(ls_issuedt) 		Then ls_issuedt 			= ""
If IsNull(ls_fromdt) 		Then ls_fromdt 		= ""
If IsNull(ls_todt) 			Then ls_todt 			= ""

//IF dw_detail.rowCount() = 0 then return

iu_cust_msg = Create u_cust_a_msg
//
ls_shoptype 	= Trim(dw_cond.object.shoptype[1]) 

iu_cust_msg.is_pgm_name = "CONCESSIONAIRE SETTLEMENT REPORT - LG U+"
iu_cust_msg.is_grp_name = "Report"
iu_cust_msg.ib_data[1]  = True

iu_cust_msg.id_data[1] = ldt_issuedt
iu_cust_msg.is_data[1] = ls_shopid
iu_cust_msg.is_data[2] = ls_fromdt		
iu_cust_msg.is_data[3] = ls_todt
iu_cust_msg.is_data[4] = ls_shoptype
IF dw_detail.RowCount() = 0 THEN
	iu_cust_msg.ic_data[1] = 0
ELSE
	iu_cust_msg.ic_data[1] = 1
END IF

 //20150930 이전 조회용
OpenWithParm(ssrt_prt_con_settlement_report_org, iu_cust_msg)

end event

type dw_regcod from datawindow within ssrt_inq_con_settlement_report_org
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

type p_1 from u_p_saveas within ssrt_inq_con_settlement_report_org
integer x = 2587
integer y = 64
boolean bringtotop = true
end type

