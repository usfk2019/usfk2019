$PBExportHeader$ssrt_reg_refund.srw
$PBExportComments$[1hera] 단 품 반 품 관리
forward
global type ssrt_reg_refund from w_a_reg_m
end type
end forward

global type ssrt_reg_refund from w_a_reg_m
integer width = 4393
integer height = 1852
end type
global ssrt_reg_refund ssrt_reg_refund

type variables
STring 		is_emp_grp, &
is_customerid, &
is_caldt , &
is_userid , &
is_pgm_id , is_basecod, is_control, &
is_method[], &
is_trcod[]

dec{2} 			idc_total, idc_receive, idc_change, idc_impack

// 2019.04.19 Vat 처리를 위한 변수 추가 Modified by Han
date   idt_refund_dt


end variables

forward prototypes
public function integer wf_set_impack (string as_data)
public subroutine wf_set_total ()
end prototypes

public function integer wf_set_impack (string as_data);LONG		ll_row1
INT		ii
DEC{2}	ldc_impack2,	ldc_impack3,	ldc_total,		ldc_impack,		ldc_impack_10
DEC      ldc_impack1
  
dw_detail.AcceptText()

ll_row1 = dw_detail.RowCount()

ldc_impack = DEC(as_data)										//카드 입력한 금액
ldc_impack_10 = ROUND(ldc_impack * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impack = 0 THEN
	RETURN -1
END IF

idc_impack = 0

FOR ii = 1 TO ll_row1
	ldc_impack1 = dw_detail.Object.impack_card[ii]	
	IF IsNull(ldc_impack1) THEN ldc_impack1 = 0
	idc_impack  = idc_impack + ldc_impack1	
	
NEXT

IF idc_impack >= 0 THEN
	IF idc_impack < ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF
ELSE
	IF idc_impack > ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF	
END IF

ldc_total = dw_cond.Object.total[1]
IF idc_impack <> 0 THEN
	dw_cond.Object.credit[1]	= ldc_total - ldc_impack_10
ELSE
	dw_cond.Object.credit[1]	= 0
END IF

RETURN 0
end function

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_detail.RowCount() > 0 THEN
//	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund")
// 2019.04.19 Total에 Vat 추가 Modified by Han 
	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund") + dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund_vat")
END IF
dw_cond.Object.total[1] 		= ldc_total

//
//F_INIT_DSP(2, "", String(ldc_total))
//
return 
end subroutine

on ssrt_reg_refund.create
call super::create
end on

on ssrt_reg_refund.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String 	ls_where, &
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
	f_msg_usr_err(9000, Title, "operator를 입력하세요.")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("operator")
	Return 
END IF

IF ls_customerid = "" then
	f_msg_usr_err(9000, Title, "Customerid를 입력하세요.")		
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("customerid")
	Return 
END IF

IF ls_contno_fr = "" THEN
	f_msg_usr_err(9000, Title, "Control No를 입력하세요.")			
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("contno_fr")
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

event ue_extra_save;Long 		ll_row, 		i, 	ll_seq, 		ll_tmp
Dec{2} 	lc_amt[], 	lc_totalamt,		ldc_tmp,					ldc_impack,		ldc_card, ldc_check_total
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
ldc_impack		= dw_cond.Object.amt5[1]


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
//		ldc_check_total 	+= dw_detail.Object.refund_price[i]
// 2019.04.19 Vat를 포함한 금액으로 Summary Modified by Han
		ldc_check_total 	+= dw_detail.Object.refund_price[i] + dw_detail.Object.refund_vat[i]
	END IF
NEXT


//2013.02.07 Sunzu Kim
IF ls_rf_type = "" Then
	f_msg_usr_err(9000, Title, "Refund Type을 선택하시기 바랍니다.")
	Return -2
END IF	

// 상단 refund 금액과 하단의 refund  행별 합계 금액이 다를경우
IF idc_total <> ldc_check_total   Then	
	f_msg_usr_err(9000, Title, "Refund Total 금액과  Refund Price 합계금액이 다릅니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -2
END IF
//=======

IF idc_total <> idc_receive   Then	
	f_msg_usr_err(9000, Title, "입금액과 환불요청 금액이 다릅니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -2
END IF
//==========================================================
// 입금액이 sale금액보다 크거나 같으면.... 처리
//==========================================================


//lc_saleamt = round(abs(dw_detail.Object.cp_total[1]),2) //2013.02.06 김선주
// 2019.04.19 Vat 금액 추가
lc_saleamt = round(abs(dw_detail.Object.cp_total[1]) + abs(dw_detail.Object.cp_total_vat[1]),2)

if round(abs(lc_saleamt),2) <> abs(idc_total) Then	
	f_msg_usr_err(9000,Title,"현 카드 SALE금액은 "+string(lc_saleamt)+"불인데"+' '+ &
								"환불요청 금액은 "+ string(abs(idc_total))+"불과 불일치 합니다." )
	
  // f_msg_usr_err(9000,Title,"Refund금액은("+string(lc_saleamt)+" ) "+"Sale금액과 ("+string(abs(idc_total))+" ) 다릅니다.")
	Return -2
end if



//2009.06.10 추가
IF ldc_impack <> 0 THEN
	Dec{2} 	ldc_90
	ldc_90 = dw_cond.Object.credit[1]
	ldc_card = dw_cond.Object.amt3[1]	
	dw_cond.Object.amt5[1] = idc_total - ldc_90
	dw_cond.Object.amt3[1] = ldc_card + (ldc_impack - (idc_total - ldc_90))
END IF
//2009.06.10 추가

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
lu_dbmgr.is_data[4] 	= ls_Operator //Operator
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


//lu_dbmgr.uf_prc_db_07()
lu_dbmgr.uf_prc_db_08()
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

event ue_reset;call super::ue_reset;String ls_temp, ls_ref_desc
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
dw_cond.Object.amt6[1] 		= 0
dw_cond.Object.total[1] 	= 0
dw_cond.Object.method1[1] = is_method[1]
dw_cond.Object.method2[1] = is_method[2]
dw_cond.Object.method3[1] = is_method[3]
dw_cond.Object.method4[1] = is_method[4]
dw_cond.Object.method5[1] = is_method[5]
dw_cond.Object.method6[1] = is_method[6]

dw_cond.Object.trcod1[1] = is_trcod[1]
dw_cond.Object.trcod2[1] = is_trcod[2]
dw_cond.Object.trcod3[1] = is_trcod[3]
dw_cond.Object.trcod4[1] = is_trcod[4]
dw_cond.Object.trcod5[1] = is_trcod[5]
dw_cond.Object.trcod6[1] = is_trcod[6]

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
//PayMethod101, 102, 103, 104, 105, 107
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

dw_cond.Object.method1[1] = is_method[1]
dw_cond.Object.method2[1] = is_method[2]
dw_cond.Object.method3[1] = is_method[3]
dw_cond.Object.method4[1] = is_method[4]
dw_cond.Object.method5[1] = is_method[5]
dw_cond.Object.method6[1] = is_method[6]



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

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_refund
integer x = 32
integer y = 28
integer width = 3072
integer height = 700
string dataobject = "ssrt_cnd_refund"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;String	ls_customerid, 	ls_customernm, 	ls_memberid, 		ls_paydt,	&
			ls_paydt_1,			ls_sysdate,			ls_paydt_c,			ls_empnm
Date		ldt_paydt
Long		ll_return

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
	case "customerid"
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

	case "contno_fr"
		this.Object.contno_to[1] =  data
		
	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impack(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
			END IF			
		END IF		
		WF_SET_TOTAL()
		
	Case "paydt"
		ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
		ls_paydt  = String(ldt_paydt, 'yyyymmdd')
		
		SELECT TO_CHAR(TO_DATE(TO_CHAR(:ldt_paydt, 'yyyymmdd'), 'YYYYMMDD') + 1, 'YYYYMMDD'),
				 TO_CHAR(SYSDATE, 'YYYYMMDD'),
				 REPLACE(:data, '-', '') 
		INTO   :ls_paydt_1, :ls_sysdate, :ls_paydt_c
		FROM   DUAL;
		
		IF ls_paydt_c > ls_paydt_1 OR ls_paydt_c < ls_paydt THEN
			dw_cond.object.paydt[row]	= ldt_paydt
			f_msg_usr_err(9000, Title, "Pay Date 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.SetColumn("paydt")
			RETURN 2
		END IF
		
	case "operator"
		SELECT EMPNM INTO :ls_empnm
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm		
		
			
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

type p_ok from w_a_reg_m`p_ok within ssrt_reg_refund
integer x = 3168
integer y = 40
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_refund
integer x = 3163
integer y = 152
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_refund
integer x = 23
integer y = 16
integer width = 3109
integer height = 728
integer textsize = -2
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_refund
boolean visible = false
integer x = 983
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_refund
boolean visible = false
integer x = 690
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_refund
integer x = 27
integer y = 1616
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_refund
integer x = 23
integer y = 760
integer width = 4005
integer height = 796
string dataobject = "ssrt_reg_refund"
end type

event dw_detail::retrieveend;call super::retrieveend;Long		ll, ll_deposit_cnt
DEC{2}	ldc_refund
STRING	ls_det_itemcod

// 2019. 04.19 VAT 처리를 위한 변수 추가
string   ls_surtaxyn
Dec{2}   ld_taxrate

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

// 2019.04.19 Vat 계산을 위한 Customerid, Date 가져오기
	is_customerid = dw_cond.Object.customerid[1]
	idt_refund_dt = dw_cond.Object.paydt     [1]
	
	FOR ll =  1 to rowcount
		ldc_refund = this.Object.sale_amt[ll] * -1
		ls_det_itemcod = trim(THIS.Object.itemcod[ll])		

// 2019.04.19 Vat 계산을 위한 Tax_rate, surtaxyn 가져오기
		SELECT FNC_GET_TAXRATE(:is_customerid, 'I', :ls_det_itemcod, :idt_refund_dt), DECODE(surtaxyn, 'N', '*', ' ')
		  INTO :ld_taxrate                                                          , :ls_surtaxyn
		  FROM ITEMMST
		 WHERE itemcod = :ls_det_itemcod;

		This.Object.surtaxyn  [ll] = ls_surtaxyn                                            /* 부가세여부 */
		This.Object.sale_vat  [ll] = Round(This.Object.sale_amt[ll] * ld_taxrate / 100, 2)  /* Sale Vat   */
		This.Object.refund_vat[ll] = Round(ldc_refund               * ld_taxrate / 100, 2)  /* Refund Vat */
		This.Object.taxrate   [ll] = ld_taxrate

		this.Object.refund_price[ll] =  ldc_refund
		
		idc_total += ldc_refund + Round(ldc_refund * ld_taxrate / 100, 2)
		
		//impact card 금액계산		 
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_det_itemcod OR OUT_ITEM = :ls_det_itemcod );	
	
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[ll] 	= Round(ldc_refund * 0.1, 2)
			THIS.Object.impack_not[ll] 	= Round(ldc_refund - Round(ldc_refund * 0.1, 2), 2)
			THIS.Object.impack_check[ll] 	= 'A'	
		ELSE
			THIS.Object.impack_card[ll] 	= 0
			THIS.Object.impack_not[ll] 	= ldc_refund
			THIS.Object.impack_check[ll] 	= 'B'		
		END IF		
		
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

event dw_detail::itemchanged;call super::itemchanged;STRING	ls_det_itemcod
LONG		ll_deposit_cnt

// 2019.04.19 Vat 계산을 위한 변수 추가 Modified by Han
Dec      ld_taxrate

THIS.AcceptText()

choose case dwo.name
	case "refund_price"
		idc_total 	=  this.GetItemNumber(this.RowCount(), "cp_refund")
//		dw_cond.Object.total[1] =  idc_total
		
		ls_det_itemcod = trim(THIS.Object.itemcod[row])		
// 2019.04.19 Vat 재계산 처리 Modified by Han
		This.Object.refund_vat[row] = Round(dec(data) * This.Object.taxrate[row] / 100, 2)
		dw_cond.Object.total[1] =  this.GetItemNumber(this.RowCount(), "cp_refund") + This.GetItemNumber(This.RowCount(), "cp_refund_vat")


		//impact card 금액계산		 
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_det_itemcod OR OUT_ITEM = :ls_det_itemcod );	
		
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[row] 	= Round(DEC(DATA) * 0.1, 2)
			THIS.Object.impack_not[row] 	= Round(DEC(DATA) - Round(DEC(DATA) * 0.1, 2), 2)
			THIS.Object.impack_check[row] 	= 'A'	
		ELSE
			THIS.Object.impack_card[row] 	= 0
			THIS.Object.impack_not[row] 	= Round(DEC(DATA), 2)
			THIS.Object.impack_check[row] 	= 'B'		
		END IF		
	
		wf_set_total()
	case "refund_type"
		wf_set_total()
		
end choose

end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_refund
integer x = 366
integer y = 1616
end type

