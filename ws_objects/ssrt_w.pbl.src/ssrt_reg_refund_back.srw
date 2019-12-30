$PBExportHeader$ssrt_reg_refund_back.srw
$PBExportComments$[1hera] 단 품 반 품 관리
forward
global type ssrt_reg_refund_back from w_a_reg_m
end type
end forward

global type ssrt_reg_refund_back from w_a_reg_m
integer width = 3534
integer height = 1852
end type
global ssrt_reg_refund_back ssrt_reg_refund_back

type variables
STring 		is_emp_grp, &
is_customerid, &
is_caldt , &
is_userid , &
is_pgm_id , is_basecod, is_control, &
is_method[], &
is_trcod[]

dec{2} 			idc_total, idc_receive, idc_change
end variables

forward prototypes
public subroutine wf_set_total ()
end prototypes

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund")
END IF
dw_cond.Object.total[1] 		= ldc_total

//
//F_INIT_DSP(2, "", String(ldc_total))
//
return 
end subroutine

on ssrt_reg_refund_back.create
call super::create
end on

on ssrt_reg_refund_back.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String 	ls_where, &
		 	LS_CUSTOMERID, ls_partner, 	ls_operator, ls_refunddt, &
		 	ls_contno_fr, 	ls_contno_to, 	ls_remark, &
		 	ls_flag
Long 		ll_row
date 		ldt_refunddt

ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_partner 		= Trim(dw_cond.object.partner[1])
ls_operator		= Trim(dw_cond.object.operator[1])
ls_contno_fr	= Trim(dw_cond.object.contno_fr[1])
ls_contno_to	= Trim(dw_cond.object.contno_to[1])
ls_remark 		= Trim(dw_cond.object.remark[1])
ls_refunddt		= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_refunddt	= dw_cond.object.paydt[1]

If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
If IsNull(ls_operator) 		Then ls_operator 		= ""
If IsNull(ls_contno_fr) 	Then ls_contno_fr 	= ""
If IsNull(ls_contno_to) 	Then ls_contno_to 	= ""
If IsNull(ls_remark) 		Then ls_remark 		= ""
If IsNull(ls_refunddt) 		Then ls_refunddt 		= ""

IF ls_operator = "" then
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("operator")
	Return 
END IF

IF ls_customerid = "" then
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("customerid")
	Return 
END IF

ls_where = ""
//Sale_Flag
ls_flag =  "1"
If ls_flag <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.sale_flag = '" + ls_flag + "' "
End If
//CUSTOMERID

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.customerid = '" + ls_customerid + "' "
End If

//Contno
If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.contno >= '" + ls_contno_fr + "' "
End If
If ls_contno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.contno <= '" + ls_contno_to + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

event type integer ue_extra_save();Long 		ll_row, 		i, 	ll_seq, 		ll_tmp
Dec{2} 	lc_amt[], 	lc_totalamt,		ldc_tmp
Dec 		lc_saleamt
Integer 	li_rc, 		li_rtn,				li_tmp
String 	ls_itemcod, ls_paydt, 			ls_customerid, 		ls_memberid, &
			ls_rf_type, ls_partner,			ls_tmp,					ls_operator, &
			ls_remark

b1u_dbmgr_dailypayment	lu_dbmgr
dw_cond.AcceptText()

idc_total 		= 0
ls_remark 		= trim(dw_cond.Object.remark[1])
ls_customerid 	= trim(dw_cond.Object.customerid[1])
ls_Operator 	= trim(dw_cond.Object.operator[1])
ls_MEMBERid 	= trim(dw_cond.Object.memberid[1])
idc_total 		= dw_cond.Object.total[1]
idc_receive 	= dw_cond.Object.cp_receive[1]
idc_change 		= dw_cond.Object.cp_change[1]
ls_paydt 		= String(dw_cond.Object.paydt[1], 'yyyymmdd')
ls_partner 		= Trim(dw_cond.object.partner[1])

//고객번호 및 오퍼레이터 존재여부 확인
IF IsNUll(ls_remark) 		then ls_remark 	= ''
IF IsNUll(ls_customerid) 	then ls_customerid 	= ''
IF IsNUll(ls_operator) 		then ls_operator 		= ''
li_rtn = f_check_ID(ls_customerid, ls_operator)
IF li_rtn =  -1 THEN
		f_msg_usr_err(9000, Title, "Customerid가 존재하지 않습니다.")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.Object.customerid[1] = ''
		dw_cond.Object.customernm[1] = ''
		dw_cond.SetColumn("customerid")
		Return -1 
ELSEIF li_rtn = -2 THEN 
		f_msg_usr_err(9000, Title, "Operator가 존재하지 않습니다.")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.Object.operator[1] = ''
		dw_cond.SetColumn("operator")
		Return -1 
END IF




FOR i =  1 to dw_detail.rowCount()
	dw_detail.Object.remark[i]	= ls_remark
	ls_rf_type = dw_detail.Object.refund_type[i]
	IF IsNull(ls_rf_type) then ls_rf_type = ""
	IF ls_rf_type <> "" THEN
		idc_total 	+= dw_detail.Object.refund_price[i]
	END IF
NEXT

IF idc_total <> idc_receive then
	f_msg_usr_err(9000, Title, "입금액과 Refund Type을 확인 바랍니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -2	
END IF
//==========================================================
// 입금액이 sale금액보다 크거나 같으면.... 처리
//==========================================================

//-2006-8-19 add ------------------------------------------------------------------
//Impact Card로 결제 하는 경우 
//10%는 Impact 90%는 Credit card 로 분할 처리
Dec{2} 	ldc_10, ldc_90, ldc_100, ldc_impact, ldc_card

ldc_100 =  dw_cond.Object.amt5[1]
If IsNull(ldc_100) then ldc_100 = 0
IF ldc_100 <> 0 then
	ldc_10 						= Round(ldc_100 * 0.1, 2)
	ldc_90 						= ldc_100 - ldc_10
	
	ldc_card 					= dw_cond.Object.amt3[1]
	If IsNull(ldc_card) then ldc_card = 0
	
	dw_cond.Object.amt5[1]	= ldc_10
	dw_cond.Object.amt3[1]	= ldc_card + ldc_90
END IF
dw_cond.Accepttext()



//li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
li_rtn = 1
//저장
lu_dbmgr = Create b1u_dbmgr_dailypayment

lu_dbmgr.is_caller 	= "save_refund"
lu_dbmgr.is_title 	= Title
lu_dbmgr.idw_data[1] = dw_cond 	//조건
lu_dbmgr.idw_data[2] = dw_detail //조건

lu_dbmgr.is_data[1] 	= ls_customerid
lu_dbmgr.is_data[2] 	= ls_paydt  //paydt(shop별 마감일 )
lu_dbmgr.is_data[3] 	= ls_partner //shopid
lu_dbmgr.is_data[4] 	= GS_USER_ID //Operator
IF li_rtn = 1 THEN 
	lu_dbmgr.is_data[5] 	= "Y"
ELSE
	lu_dbmgr.is_data[5] 	= "N"
END IF

lu_dbmgr.is_data[6] 	= gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[7] 	= "Y" //ADMST Update 여부
lu_dbmgr.is_data[8] 	= ls_memberid //memberid
lu_dbmgr.is_data[9] 	= "N" //ADLOG Update여부
lu_dbmgr.is_data[10]	= "REFUND" //PGM_ID


lu_dbmgr.uf_prc_db_07()
//위 함수에서 이미 commit 한 상태임.
li_rc = lu_dbmgr.ii_rc
Destroy lu_dbmgr

If li_rc = -1 Or li_rc = -3 Then
	Return -1
ELSEIf li_rc = -2 Then
	f_msg_usr_err(9000, Title, "!!")
	Return -1
End If

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_cond.SetFocus()
dw_detail.Reset()
Return 0
end event

event type integer ue_reset();call super::ue_reset;String ls_temp, ls_ref_desc
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_method[])

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_trcod[])

//초기화
dw_cond.ReSet()
dw_cond.InsertRow(0)
dw_cond.Object.partner[1] 	= GS_SHOPID
dw_cond.Object.paydt[1] 	= f_find_shop_closedt(GS_SHOPID)
dw_cond.Object.amt1[1] 		= 0
dw_cond.Object.amt2[1] 		= 0
dw_cond.Object.amt3[1] 		= 0
dw_cond.Object.amt4[1] 		= 0
dw_cond.Object.amt5[1] 		= 0
dw_cond.Object.total[1] 	= 0
dw_cond.Object.method1[1] = is_method[1]
dw_cond.Object.method2[1] = is_method[2]
dw_cond.Object.method3[1] = is_method[3]
dw_cond.Object.method4[1] = is_method[4]
dw_cond.Object.method5[1] = is_method[5]

dw_cond.Object.trcod1[1] = is_trcod[1]
dw_cond.Object.trcod2[1] = is_trcod[2]
dw_cond.Object.trcod3[1] = is_trcod[3]
dw_cond.Object.trcod4[1] = is_trcod[4]
dw_cond.Object.trcod5[1] = is_trcod[5]



dw_cond.SetFocus()
dw_cond.SetColumn("memberid")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_refund
	Desc.	: 	단 품 반 납
	Ver.	:	1.0
	Date	: 	2006.7.18
	Programer : Cho Kyung Bok [ 1hera ]
--------------------------------------------------------------------------*/


String ls_temp, ls_ref_desc
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

dw_cond.Object.method1[1] = is_method[1]
dw_cond.Object.method2[1] = is_method[2]
dw_cond.Object.method3[1] = is_method[3]
dw_cond.Object.method4[1] = is_method[4]
dw_cond.Object.method5[1] = is_method[5]



end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

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
	This.Trigger Event ue_reset() 
	
End If

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_refund_back
integer x = 37
integer y = 40
integer width = 3067
integer height = 704
string dataobject = "ssrt_cnd_refund_back"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;String ls_customerid, ls_customernm, ls_memberid

Choose Case dwo.name
	Case "memberid"
		ls_memberid = trim(data)
		select customerid, customernm
		  INTO :ls_customerid,	:ls_customernm
		  FROM customerm
		 where memberid = :ls_memberid ;
		 
		 IF sqlca.sqlcode <> 0 OR IsNull(ls_customerid) then ls_customerid = ""
		 IF sqlca.sqlcode <> 0 OR IsNull(ls_customernm) then ls_customernm = ""
		 
		IF ls_customerid = "" THEN
			This.Object.memberid[1] =  ""
			return 0
		ELSE
			This.Object.customerid[1] =  ls_customerid
			This.Object.customernm[1] =  ls_customernm
			return 0
		end if
	case 'customerid'
		ls_customerid 		= trim(data)
		select memberid, 			customernm
		  INTO :ls_memberid,		:ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		IF IsNull(ls_memberid) 		OR sqlca.sqlcode <> 0		then ls_memberid = ""
		IF IsNull(ls_customernm)  	OR sqlca.sqlcode <> 0		then ls_customernm = ""
		
		IF sqlca.sqlcode <> 0 then 
			This.Object.memberid[1] 	= ""
			This.Object.customerid[1] 	= ""
			This.Object.customernm[1] 	= ""
			f_msg_usr_err(9000, Title, "해당 고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")

			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			
			
			return 1
		else
			This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
		end if
	case 'operator'
		
	case "contno_fr"
		this.Object.contno_to[1] =  data
End Choose

end event

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "b1w_hlp_customerm"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


String ls_ref_desc
String ls_filter
INTEGER  li_exist
DataWindowChild ldwc
date	ldt_saledt


is_emp_grp		= ""
is_customerid	= ""
is_caldt 		= ""
is_userid 		= ""
is_pgm_id 		= ""


dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.memberid[1] 	= dw_cond.iu_cust_help.is_data[4]
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_refund_back
integer x = 3168
integer y = 40
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_refund_back
integer x = 3163
integer y = 152
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_refund_back
integer x = 69
integer y = 4
integer width = 3077
integer height = 744
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_refund_back
boolean visible = false
integer x = 315
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_refund_back
boolean visible = false
integer x = 23
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_refund_back
integer x = 27
integer y = 1616
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_refund_back
integer x = 23
integer y = 764
integer width = 3118
integer height = 812
string dataobject = "ssrt_reg_refund_back"
end type

event dw_detail::retrieveend;call super::retrieveend;Long ll
DEC{2} ldc_refund
//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	
//	p_insert.TriggerEvent("ue_disable")
//	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_ensable")
	dw_cond.Enabled = True
ELSE
	idc_total 	= 0
	idc_receive = 0
	idc_change 	= 0
	FOR ll =  1 to rowcount
		ldc_refund = this.Object.sale_amt[ll] * -1
		this.Object.refund_price[ll] =  ldc_refund
		idc_total += ldc_refund
	NEXT
	
End If
//dw_cond.Object.total[1] =  idc_total
p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_ensable")
dw_cond.Enabled = True


end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;choose case dwo.name
	case "refund_price"
		idc_total 	=  this.GetItemNumber(this.RowCount(), "cp_refund")
		dw_cond.Object.total[1] =  idc_total	
		wf_set_total()
	case "refund_type"
		wf_set_total()
		
end choose

end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_refund_back
integer x = 366
integer y = 1616
end type

