$PBExportHeader$ssrt_reg_receipt_management_old.srw
forward
global type ssrt_reg_receipt_management_old from w_a_reg_m
end type
type dw_seq from datawindow within ssrt_reg_receipt_management_old
end type
type dw_itemlist from datawindow within ssrt_reg_receipt_management_old
end type
end forward

global type ssrt_reg_receipt_management_old from w_a_reg_m
integer width = 3950
integer height = 2016
dw_seq dw_seq
dw_itemlist dw_itemlist
end type
global ssrt_reg_receipt_management_old ssrt_reg_receipt_management_old

type variables
String is_cus_status
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wf_get_customerid (string as_customerid, string as_memberid)
public function integer wf_reprint (long wf_row)
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

public function integer wf_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm, ls_payid, ls_partner, ls_customerid
Integer	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	Select customernm, status,  	 payid,	    partner
	  Into :ls_customernm,   :is_cus_status,    :ls_payid,   :ls_partner
	  From customerm
	 Where customerid = :as_customerid;
	 
	 ls_customerid = as_customerid
ELSE
	Select customerid, customernm, status, 	 payid,    partner
	  Into :ls_customerid,:ls_customernm,:is_cus_status,:ls_payid,:ls_partner
	  From customerm
	 Where memberid = :as_memberid;
END IF

If SQLCA.SQLCode = 100 Then		//Not Found
	IF li_sw = 1 THEN
   	f_msg_usr_err(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	f_msg_usr_err(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
dw_cond.object.customerid[1] = ls_customerid
Return 0

end function

public function integer wf_reprint (long wf_row);Integer	li_rtn
String 	ls_seq, 				ls_appno, 			ls_memberid
Long 		ll_row, 				ll,					jj,				kk,	&
			ll_shopcount, 		ll_list_cnt, 		ll_seq, &
			ll_cnttotal,		ll_paycnt,			ll_keynum
DEC{2}	ldc_total, 			ldc_cash,			ldc_change,		ldc_paytotal, &
			ldc_amt[],			ldc_payamt,			ldc_tmp, &
			ldc_amt_new[]
dec		ldc_shopCount

String 	ls_lin1, 		ls_lin2, 		ls_lin3
String 	ls_empnm,		ls_partner,		ls_method[], ls_cdname[],  ls_cdname_new[]
date 		ldt_workdt
String 	ls_temp, &
			ls_ref_desc, &
			ls_itemcod, 	ls_itemnm, &
			ls_paymethod, &
			ls_val, &
			ls_regcod, &
			ls_facnum
			

//변수 Clear
FOR kk = 1 to 5
	ldc_amt[kk] = 0
NEXT
ll_seq 			= 0
ldc_paytotal 	= 0
ll_cnttotal 	= 0
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ls_partner 	= dw_cond.Object.partner[1]
//==================================================
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
// PayMethod Name
FOR ll = 1 to 5
	SELECT codenm INTO :ls_cdname[ll] from syscod2t
	 WHERE grcode = 'B310' 
	   AND code   = :ls_method[ll] ;
NEXT
//======================================================
//total 계산
ldc_total 	=  dw_detail.Object.total[wf_row]
ldc_cash 	=  dw_detail.Object.cash[wf_row]
ldc_change 	=  dw_detail.Object.change[wf_row]


//ldc_total 	=  dw_seq..GetItemNumber(dw_seq.RowCount(), "cp_total")
//ldc_cash 	=  dw_seq.GetItemNumber(dw_seq.RowCount(), "cp_cash")
//ldc_change 	=  dw_seq.GetItemNumber(dw_seq.RowCount(), "cp_change")
//

// PayMethod 별 total 계산.
ls_appno = dw_detail.Object.approvalno[wf_row]
FOR jj =  1 to 5
	select SUM(payamt) INTO :ldc_tmp FROM dailypayment
	 WHERE APPROVALNO = :ls_appno
	   AND paymethod = :ls_method[jj] ;
		
	IF IsNULL(ldc_tmp) OR sqlca.sqlcode < 0 then ldc_tmp = 0
	ldc_amt[jj] = ldc_tmp
NEXT
//change ---> add cash
ldc_amt[1] += ldc_change

//paymethod별 우선 순위 정의
//3, 2, 5, 4 , 1
ldc_amt_new[1] = ldc_amt[3]
ldc_amt_new[2] = ldc_amt[2]
ldc_amt_new[3] = ldc_amt[5]
ldc_amt_new[4] = ldc_amt[4]
ldc_amt_new[5] = ldc_amt[1]

ls_cdname_new[1] =  ls_cdname[3]
ls_cdname_new[2] =  ls_cdname[2]
ls_cdname_new[3] =  ls_cdname[5]
ls_cdname_new[4] =  ls_cdname[4]
ls_cdname_new[5] =  ls_cdname[1]


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
li_rtn = f_pos_header(ls_partner, 'R', ll_shopcount, 0)
IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			PRN_ClosePort()
			return -9
END IF
//======================================================================
//Item List 출력
ll_list_cnt =  dw_itemlist.REtrieve(ls_appno)
ldc_paytotal 	= 0
ll_cnttotal 	= 0
For jj = 1 To ll_list_cnt
		ll_seq += 1
		ls_temp 		= String(ll_seq, '000') + ' ' //순번
		ls_itemcod 	= trim(dw_itemlist.Object.itemcod[jj])
		ls_itemNM 	= trim(dw_itemlist.Object.itemNM[jj])
		ldc_payamt	= dw_itemlist.object.payamt[jj]
		ll_paycnt 	= dw_itemlist.object.paycnt[jj]

		IF IsNull(ls_itemNM) 	then ls_itemNM 	= ""
		
		ldc_paytotal 	+= ldc_payamt
		ll_cnttotal 	+= ll_paycnt 
		ls_temp 			+= LeftA(ls_itemnm + space(24), 24)  //아이템
		ls_temp 			+= Space(1) + RightA(Space(4) + String(ll_paycnt), 4) + ' '  //수량
		ls_val 			= fs_convert_amt(ldc_payamt,  8)
		ls_temp 			+= ls_val //금액
		f_printpos(ls_temp)	
	
		ls_regcod 	= trim(dw_itemlist.Object.regcod[jj])
		//regcode master read
		select keynum, 		trim(facnum)	INTO :ll_keynum,	:ls_facnum
	  	  FROM regcodmst
	 	 where regcod = :ls_regcod ;
	
		IF IsNull(ll_keynum)  or sqlca.sqlcode < 0 	then ll_keynum 	= 0
		IF IsNull(ls_facnum)  or sqlca.sqlcode < 0	then ls_facnum 	= ""
		ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
		f_printpos(ls_temp)
NEXT
//======================================================================
//Item List 출력 --END
f_printpos(ls_lin1)
ls_val 	= fs_convert_sign(ldc_paytotal, 8)
ls_temp 	= LeftA("Grand Total" + space(32), 32) + ls_val
f_printpos(ls_temp)
f_printpos(ls_lin1)

//--------------------------------------------------------
//결제수단별 입금액
For kk = 1 To 5
	if ldc_amt_new[kk] <> 0 then
		ls_val 	= fs_convert_sign(ldc_amt_new[kk],  8)
		ls_temp 	= LeftA(ls_cdname_new[kk] + space(33), 33) + ls_val
		f_printpos(ls_temp)
	END IF
NEXT
//거스름돈 처리
ls_val 	= fs_convert_sign(ldc_change,  8)
ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
f_printpos(ls_temp)
f_printpos(ls_lin1)

ls_seq = dw_detail.Object.seq_app[wf_row]
F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id)
return 0
end function

on ssrt_reg_receipt_management_old.create
int iCurrent
call super::create
this.dw_seq=create dw_seq
this.dw_itemlist=create dw_itemlist
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_seq
this.Control[iCurrent+2]=this.dw_itemlist
end on

on ssrt_reg_receipt_management_old.destroy
call super::destroy
destroy(this.dw_seq)
destroy(this.dw_itemlist)
end on

event ue_ok();call super::ue_ok;String 	ls_customerid, &
			ls_partner, 	&
			ls_where1, ls_where2, &
			ls_memberid, &
			ls_saledt_fr, ls_saledt_to, ls_sysdt, &
			ls_option, ls_approvalno,	&
			ls_issudt_to,	ls_issudt_fr
Long 		ll_row, 			ll_result

dw_cond.AcceptText()

ls_sysdt       = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_saledt_fr   = String(dw_cond.object.saledt_fr[1],'yyyymmdd')
ls_saledt_to   = String(dw_cond.object.saledt_to[1],'yyyymmdd')

ls_issudt_fr   = String(dw_cond.object.issuedt_fr[1],'yyyymmdd')
ls_issudt_to   = String(dw_cond.object.issuedt_to[1],'yyyymmdd')

ls_customerid  = Trim(dw_cond.object.customerid[1])
ls_memberid    = Trim(dw_cond.object.memberid[1])
ls_partner     = Trim(dw_cond.object.partner[1])
ls_approvalno  = Trim(dw_cond.object.approvalno[1])
//ls_option      = Trim(dw_cond.object.option[1])
//ls_operator  	= Trim(dw_cond.object.operator[1])

If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_saledt_fr) 	Then ls_saledt_fr 	= ""
If IsNull(ls_saledt_to) 	Then ls_saledt_to 	= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
IF IsNull(ls_approvalno) 	then ls_approvalno 	= ""
IF IsNull(ls_issudt_fr) 	then ls_issudt_fr 	= ""
IF IsNull(ls_issudt_to) 	then ls_issudt_to 	= ""


If ls_partner = "" Then
	f_msg_info(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

//필수항목 먼저 처리
ls_where1 = ""
ls_where2 = ""
//ls_where1 += "customerid ='" + ls_customerid + "' "
ls_where1 += "shopid ='" + ls_partner + "' "
ls_where1 += "and prt_yn = '" + "Y" + "' "
ls_where1 += "and RECEIPTTYPE <> '" + "400" + "' "

If ls_saledt_fr <> "" Then
	ls_where1 += "and to_char(trdt,'yyyymmdd') >='" + ls_saledt_fr + "' "
END IF
If ls_saledt_to <> "" Then
	ls_where1 += "and to_char(trdt, 'yyyymmdd') <='" + ls_saledt_to + "' "
END IF

If ls_issudt_fr <> "" Then
	ls_where1 += "and to_char(workdt,'yyyymmdd') >='" + ls_issudt_fr + "' "
END IF
If ls_issudt_to <> "" Then
	ls_where1 += "and to_char(workdt, 'yyyymmdd') <='" + ls_issudt_to + "' "
END IF

If ls_approvalno <> "" Then
	ls_where1 += "and seq_app = '" + ls_approvalno + "'"
End If

If ls_customerid <> "" Then
	ls_where1 += "and customerid = '" + ls_customerid + "'"
End If


dw_detail.is_where = ls_where1
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If
//IF dw_detail.RowCount() = 0 then
//	cb_issue.Hide()
//ELSE
//	cb_issue.Show()
//END IF
//
SetRedraw(False)

If ll_row > 0 Then
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_disable")

	dw_cond.Enabled 		= False
else
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_Enable")
	dw_cond.Enabled 		= True
	dw_cond.SetFocus()
End If

SetRedraw(True)
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_receipt_management
	Desc	: 	영수증 통합발행 및 재발행, 입금방법 변경 처리
	Ver.	:	2.0
	Date	:   2007.07.19.
	Programer : 1hera
-------------------------------------------------------------------------*/
//call w_a_condition::open
String ls_ref_desc, ls_temp
iu_cust_db_app = Create u_cust_db_app

//날짜 Setting
dw_cond.object.saledt_fr[1]			= f_find_shop_closedt(GS_SHOPID)
dw_cond.object.saledt_to[1] 			= f_find_shop_closedt(GS_SHOPID)
dw_cond.object.partner[1] 				= GS_SHOPID


//PAYMETHOD
//ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
//If ls_temp 		= "" Then Return
//fi_cut_string(ls_temp, ";", is_method[])


//cb_issue.Hide()
PostEvent("resize")





end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
//날짜 Setting
dw_cond.object.saledt_fr[1]			= f_find_shop_closedt(GS_SHOPID)
dw_cond.object.saledt_to[1] 			= f_find_shop_closedt(GS_SHOPID)
dw_cond.object.partner[1] 				= GS_SHOPID

dw_cond.SetColumn("memberid")


//p_insert.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_receipt_management_old
integer x = 37
integer y = 52
integer width = 2217
integer height = 292
string dataobject = "ssrt_cnd_reg_receipt_management"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm, ls_memberid, &
		 ls_operator
Integer	li_cnt

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
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			
			return 1
			
		ELSE
			This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
		END IF
	Case "memberid"
		ls_memberid = trim(data)
		select customerid, 		customernm
		  INTO :ls_customerid,	:ls_customernm
		  FROM customerm
		 where memberid = :ls_memberid ;
		 
		 IF IsNull(ls_customerid) then ls_customerid = ""
		 IF IsNull(ls_customernm) then ls_customernm = ""
		 
		This.Object.customerid[1] =  ls_customerid
		This.Object.customernm[1] =  ls_customernm
End Choose

end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_receipt_management_old
integer x = 2482
integer y = 28
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_receipt_management_old
integer x = 2784
integer y = 28
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_receipt_management_old
integer x = 18
integer width = 2290
integer height = 348
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_receipt_management_old
boolean visible = false
integer x = 315
integer y = 1768
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_receipt_management_old
boolean visible = false
integer x = 23
integer y = 1768
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_receipt_management_old
integer x = 608
integer y = 1768
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_receipt_management_old
integer x = 18
integer y = 376
integer width = 3849
integer height = 1340
string dataobject = "ssrt_reg_receipt_management_list"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::buttonclicked;call super::buttonclicked;String ls_appno, ls_seq, &
			ls_customerid, ls_customernm, ls_partner
choose case dwo.name
	case "b_change"
		ls_customerid 	= dw_detail.Object.customerid[1]
		ls_customernm 	= dw_cond.Object.customernm[1]
		ls_partner 		= dw_cond.Object.partner[1]
		ls_appno 		= this.Object.approvalno[row]
		iu_cust_msg 	= Create u_cust_a_msg
		
		iu_cust_msg.is_pgm_name = "영수증 변경"
		iu_cust_msg.is_grp_name = "Receipt Reissue"
		iu_cust_msg.is_data[1]  = ls_customerid
		iu_cust_msg.is_data[2]  = ls_customernm
		iu_cust_msg.is_data[3]  = ls_partner				//
		iu_cust_msg.is_data[4]  = ls_appno               //receiptmst.approval
		iu_cust_msg.is_data[5]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	 
 		OpenWithParm(ssrt_reg_receipt_reissue_pop_new, iu_cust_msg)
		Destroy iu_cust_msg
	case "b_reprint"
		ls_appno 			=  this.Object.approvalno[row]
		//영 수증 재 발행 처리 -----
		wf_reprint(row)
	case else
end choose

end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_receipt_management_old
integer x = 1179
integer y = 1768
end type

type dw_seq from datawindow within ssrt_reg_receipt_management_old
boolean visible = false
integer x = 2450
integer y = 308
integer width = 311
integer height = 56
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_seq_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_itemlist from datawindow within ssrt_reg_receipt_management_old
boolean visible = false
integer x = 2798
integer y = 308
integer width = 311
integer height = 56
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_item_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

