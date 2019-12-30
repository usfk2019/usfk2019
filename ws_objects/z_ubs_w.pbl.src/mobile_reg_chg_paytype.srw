$PBExportHeader$mobile_reg_chg_paytype.srw
$PBExportComments$모바일 할부-일시불 전환
forward
global type mobile_reg_chg_paytype from w_a_reg_m_m3
end type
type dw_validkey from u_d_base within mobile_reg_chg_paytype
end type
type st_horizontal3 from st_horizontal within mobile_reg_chg_paytype
end type
end forward

global type mobile_reg_chg_paytype from w_a_reg_m_m3
integer width = 4251
integer height = 2196
dw_validkey dw_validkey
st_horizontal3 st_horizontal3
end type
global mobile_reg_chg_paytype mobile_reg_chg_paytype

type variables
String is_active
String is_term, is_amt_check
long il_orderno, il_contractseq
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function integer wf_chk_minap (string as_customerid)
public function integer wf_mobile_sales (integer row, string as_modelcd, string as_priceplan, integer ai_month, string as_fromdt)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기]
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0
end function

public function integer wf_chk_minap (string as_customerid);DEC ld_minap_amt

SELECT SUM(TRAMT - PAYIDAMT) INTO :ld_minap_amt
FROM REQDTL
WHERE PAYID = :as_customerid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wf_chk_minap(Select reqdtl Error)")
	return -1
End If	
  

IF ld_minap_amt <> 0 THEN
	messagebox("수납확인","미납액이 : " + string(ld_minap_amt) +  "$ 입니다. 먼저 수납후 진행 하세요")
	return -1
END IF

return 0
end function

public function integer wf_mobile_sales (integer row, string as_modelcd, string as_priceplan, integer ai_month, string as_fromdt);
 string ls_itemcod, ls_bilitem_yn, ls_oneoffcharge_yn, ls_model
 decimal ld_saleamt, ld_stdamt
 long ll_row, li_priority
 
	 //일시불금액
	 SELECT SALEAMT into :ld_stdamt FROM PRICEPLAN_RATE_MOBILE
						WHERE SALE_MODELCD = :as_modelcd
							  AND PRICEPLAN = :as_priceplan
							  AND MTH = 1
							  AND FROMDT = (SELECT MAX(FROMDT) FROM PRICEPLAN_RATE_MOBILE 
																  WHERE   SALE_MODELCD = :as_modelcd  
																		AND PRICEPLAN = :as_priceplan  
																		AND MTH = :ai_month 
																		AND FROMDT <= :as_fromdt);
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Select Error(PRICEPLAN_RATE_MOBILE)")
		Return  -1
	End If
			
																		
	//일시불이면 모델아이템 가져오기																	
	if ai_month = 1 then							
		
		 ls_model = dw_detail2.object.modelno[row]
		 SELECT B.ITEMCOD, C.oneoffcharge_yn, C.bilitem_yn, C.priority  
        	into :ls_itemcod, :ls_oneoffcharge_yn, :ls_bilitem_yn, :li_priority
     	 FROM ADMODEL A, ADMODEL_ITEM B, ITEMMST C
       WHERE A.MODELNO = B.MODELNO
		   AND B.ITEMCOD = C.ITEMCOD
			AND A.MODELNO = :ls_model
         AND A.SALE_MODELCD = :as_modelcd;
			
			
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "Select Error(ADMODEL_ITEM)")
			Return  -1
		End If
	end if		
	
  
	//금액세팅		
	dw_detail.object.pay_amt[1] = ld_stdamt
	dw_detail.object.itemcod[1] = ls_itemcod
	if dw_detail2.object.payment_month_cnt[1] > 0 then  //청구후면 잔여금액
		dw_detail.object.sale_amt[1] = dw_detail2.object.remain_amt[1]   //잔여금액
	else				//청구전이면 일시불금액
		dw_detail.object.sale_amt[1] =	ld_stdamt
	end if
	
	dw_detail.object.chk[1] = 'M'
	dw_detail.object.oneoffcharge_yn[1] = ls_oneoffcharge_yn
	dw_detail.object.bilitem_yn[1] = ls_bilitem_yn
	dw_detail.object.itemmst_priority[1] = li_priority

		
return 0
end function

on mobile_reg_chg_paytype.create
int iCurrent
call super::create
this.dw_validkey=create dw_validkey
this.st_horizontal3=create st_horizontal3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_validkey
this.Control[iCurrent+2]=this.st_horizontal3
end on

on mobile_reg_chg_paytype.destroy
call super::destroy
destroy(this.dw_validkey)
destroy(this.st_horizontal3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	bw1_reg_chg_priceplan
	Desc	:	가격정책 변경
	Ver.	:	1.0
	Date	:	2002.10.12
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_name[], ls_status
is_active = ""
is_term = ""
//is_amt_check = 'N'

//개통 상태코드
ls_ref_desc =""
is_active = fs_get_control("B0", "P223", ls_ref_desc)

//해지 상태코드
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_term = ls_name[2]


dw_cond.SetFocus()
dw_cond.Setrow(1)
dw_cond.SetColumn("customerid")

//SetRedraw(True)

//PostEvent("resize")

end event

event ue_ok;Long		ll_rows, li_ret
String	ls_where
String	ls_customerid, ls_validkey,ls_contractseq, ls_operator

dw_cond.accepttext()

//Condition
ls_validkey    = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid  = fs_snvl(dw_cond.Object.customerid[1], "")
ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], "")
ls_operator 	= fs_snvl(dw_cond.object.operator[1],"")

//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "con.customerid = '" + ls_customerid + "' "
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "val.validkey ='" + ls_validkey + "'"
END IF

IF ls_contractseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "con.contractseq '" + ls_contractseq + "' "
END IF

//고객번호, 인증키, 계약번호 모두가 Null이면 리턴.
If ls_customerid = "" AND ls_validkey = "" AND ls_contractseq = "" Then
	f_msg_usr_err(9000, Title, "다음 조회조건 중 한가지 이상을 입력하여 주십시오. (Customer ID or ContractSeq. or Phone Number)")
	return
End If

if ls_customerid = "" then
	f_msg_usr_err(9000, Title, "Customerid 를 입력하여 주십시오.")
	return
end if

if ls_operator = "" then
	f_msg_usr_err(9000, Title, "OPERATOR를 입력하여 주십시오.")
	return
end if

//미납금액 확인
li_ret = wf_chk_minap(ls_customerid)
if li_ret < 0 then 	Return

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	p_reset.TriggerEvent("ue_enable")
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	p_reset.TriggerEvent("ue_enable")
	f_msg_info(1000, Title, "")
ELSE
	dw_master.event ue_select()
END IF


end event

event ue_extra_save;Long    ll_row, ll_gubun[], ll_type[], ll_cnt, ll_cnt_1
Integer li_rc, i, j, p, ii, li_row
String  ls_chk, ls_validkey
Boolean ib_jon, ib_jon_1, lb_check = False, lb_check_2 = False

dw_detail.AcceptText()

ubs_dbmgr_activeorder	lu_dbmgr

//SetNull(il_contractseq)


//저장
lu_dbmgr = Create ubs_dbmgr_activeorder
lu_dbmgr.is_caller   = "ubs_w_reg_chg_paytype%save"
lu_dbmgr.is_title    = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_master               //계약정보
lu_dbmgr.idw_data[3] = dw_detail2   	     	  //단말할부
lu_dbmgr.idw_data[4] = dw_detail	   	     	  //일시불정보
lu_dbmgr.is_data[1]  = gs_user_id
lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]


lu_dbmgr.uf_prc_db_07()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	ai_return = li_rc
	Return 
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	ai_return = li_rc
	Return 
End If

If li_rc = -3 Then
	Destroy lu_dbmgr
	ai_return = li_rc
	Return 
End If

//il_orderno = lu_dbmgr.il_data[1]

Destroy lu_dbmgr
ai_return = 0


Return 


end event

event ue_save;

Int 		li_return, 		i,						ii
LONG		ll_row,			ll_row2
DEC{2}	ldc_total,		ldc_total_old,		ldc_basicamt,	ldc_basicamt_old
STRING	ls_chk,			ls_quota_yn,		ls_onefee,		ls_bil,				ls_itemcod
STRING	ls_chk_old,		ls_quota_yn_old,	ls_onefee_old,	ls_bil_old,			ls_itemcod_old
STRING	ls_priceplan,	ls_priceplan_old,	ls_reqdt,		ls_reqdt_old,		ls_svccod
STRING	ls_customerid
Boolean 	lb_direct

ii_error_chk = -1

IF dw_master.AcceptText() < 0 Then
	dw_master.SetFocus()
	Return -1
END IF

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

ls_svccod			= dw_master.Object.svccod[dw_master.GetRow()]
ls_priceplan		= dw_detail.Object.priceplan[dw_detail.GetRow()]
//ls_reqdt				= STRING(dw_detail2.Object.reqdt[dw_detail2.GetRow()], 'yyyymmdd')

This.Trigger Event ue_extra_save(li_return)


	IF li_return = 0 THEN
	//=========================================
	//즉시불 처리 항목 여부 check
	// bilitem_yn = 'N' AND oneoffcharge_yn = 'Y'
	//=========================================
		lb_direct =  False
		iu_cust_msg = Create u_cust_a_msg
		ll_row  = dw_detail.RowCount()
		
		ldc_total = 0
		ldc_total_old = 0
		For i = 1 To ll_row
			ls_chk 		= Trim(dw_detail.object.chk[i])
			//ls_quota_yn = Trim(dw_detail.object.quota_yn[i])
			ls_onefee 	= Trim(dw_detail.object.ONEOFFCHARGE_YN[i])
			ls_bil 		=Trim(dw_detail.object.bilitem_yn[i])
			ls_itemcod  = Trim(dw_detail.object.itemcod[i])
			ldc_basicamt = dw_detail.object.pay_amt[i]
			
			If ls_chk = "Y" or ls_chk = "M" AND ls_onefee = "Y" and ls_bil = 'N' Then
																			
				IF Isnull(ldc_basicamt) THEN ldc_basicamt = 0
				
				ldc_total = ldc_total + ldc_basicamt			
				lb_direct = True
				
			End If
		Next
		

		
		IF ldc_total <> ldc_total_old THEN
			lb_direct = TRUE
		END IF
		
		If lb_direct Then			//즉시불 처리
			ls_customerid 	= Trim(dw_cond.object.customerid[1])
			ls_reqdt 		= String(dw_detail2.object.sale_month[1], 'yyyymmdd')
			iu_cust_msg.is_pgm_name = "서비스품목 장비 즉시불 등록"
			iu_cust_msg.is_grp_name = "서비스 신청"
			iu_cust_msg.ib_data[1]  = True
			iu_cust_msg.il_data[1]  = il_orderno					//order number
			iu_cust_msg.il_data[2]  = il_contractseq				//contractseq
			iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
			iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
			iu_cust_msg.is_data[4] 	= ls_reqdt 			//
			iu_cust_msg.is_data[5] 	= ls_priceplan 				//가격정책
			iu_cust_msg.is_data[6] 	= ls_svccod 				//서비스
			
			iu_cust_msg.idw_data[1] = dw_detail
			OpenWithParm(b1w_reg_directpay_pop_sams, iu_cust_msg)
			
			IF iu_cust_msg.ib_data[1] THEN
				is_amt_check = iu_cust_msg.is_data[1]
			END IF
			
			IF is_amt_check = 'N' THEN
				li_return = -1
			END IF	
		END IF
	END IF

	
If li_return = -1  Then
//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return  -1
	End If
	f_msg_info(3010,This.Title,"일시불 변경")
	Return -1
ElseIf li_return = 0 Then
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	f_msg_info(3000,This.Title,"일시불 변경")
ElseIf li_return  = -2 Then
	Return -1
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
ls_customerid = Trim(dw_cond.object.customerid[1])

//dw_detail.Reset()
//dw_detail2.Reset()
//dw_master.Reset()
//dw_cond.object.customerid[1] = ls_customerid

Trigger Event ue_ok()

ii_error_chk = 0

Return 0
end event

event ue_reset;Int li_rc, li_ret
Long ll_row
String ls_status 
ii_error_chk = -1

ll_row = dw_master.GetSelectedRow(0)
If ll_row <= 0 Then  Return


//상태 코드 
ls_status = Trim(dw_master.object.status[1])


dw_detail.AcceptText()

If ls_status = is_active Then
	If dw_detail.ModifiedCount() > 0 or &
		dw_detail.DeletedCount() > 0 or &
		dw_detail2.ModifiedCount() > 0 or &
		dw_detail2.DeletedCount() > 0 then
		
		li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
		CHOOSE CASE li_ret
			CASE 1
				li_ret = -1 
				li_ret = Event ue_save()
				If Isnull( li_ret ) or li_ret < 0 then return
			CASE 2
	
			CASE ELSE
				Return 
		END CHOOSE
			
	end If

End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//
ii_error_chk = 0
is_amt_check = 'N'

dw_cond.SetFocus()
dw_cond.Enabled = True
dw_cond.SetColumn("customerid")



end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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





//CALL w_a_m_master::resize
//
//dw_cond.SetFocus()
//dw_cond.Setrow(1)
//dw_cond.SetColumn("customerid")
//
//SetRedraw(True)
//
//
//
//
end event

type dw_cond from w_a_reg_m_m3`dw_cond within mobile_reg_chg_paytype
integer x = 41
integer y = 68
integer width = 2304
integer height = 296
integer taborder = 10
string dataobject = "b1dw_cnd_reg_chg_paytype"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;//Choose Case dwo.name
//	Case "customerid"
//		If dw_cond.iu_cust_help.ib_data[1] Then
//			 dw_cond.Object.customerid[row] = &
//			 dw_cond.iu_cust_help.is_data[1]
//			 dw_cond.object.customernm[row] = &
//			 dw_cond.iu_cust_help.is_data[2]
//			 dw_cond.object.memberid[row] = &
//			 dw_cond.iu_cust_help.is_data[4]
//		End If
//End Choose

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;String 	ls_customerid,		ls_customernm,		ls_memberid, 	&
		 	ls_operator,		ls_empnm,			ls_paydt,		&
			ls_paydt_1,			ls_sysdate,			ls_paydt_c, ls_partner
Integer	li_cnt
Date		ldt_paydt
DEC{2}	ldc_total,			ldc_90
LONG		ll_return

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
			
			return
			
		ELSE
			//This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
		END IF
		
	case 'operator'
		SELECT EMPNM, EMP_GROUP INTO :ls_empnm, :ls_partner
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
		dw_cond.object.partner[row]    = ls_partner
		
//		is_operator   = data
//		is_operatornm = ls_empnm
//		is_partner    = ls_partner
		
	case 'validkey'
		
		IF IsNumber(data) = False THEN
			f_msg_usr_err(9000, Title, "Phone Number는 숫자만 입력이 가능합니다! (입력값=" + data + ")")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.validkey[row]		= ""
			dw_cond.object.validkey[row]	= ""
			dw_cond.SetColumn("validkey")
			RETURN 2				
		END IF
End Choose

end event

type p_ok from w_a_reg_m_m3`p_ok within mobile_reg_chg_paytype
integer x = 2450
integer y = 164
end type

type p_close from w_a_reg_m_m3`p_close within mobile_reg_chg_paytype
integer x = 2766
integer y = 164
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within mobile_reg_chg_paytype
integer y = 4
integer width = 2322
integer height = 388
integer taborder = 0
end type

type dw_master from w_a_reg_m_m3`dw_master within mobile_reg_chg_paytype
integer y = 420
integer width = 4142
integer height = 540
integer taborder = 20
string dataobject = "b1dw_reg_chg_paytype_mas"
end type

event dw_master::ue_select;Long ll_selected_row ,ll_row, ll_orderno
Integer li_return, li_ret,i, li_cnt
string ls_contractseq, ls_orderno, ls_customerid
string	ls_salemodelcd, 	ls_priceplan, ls_fromdt


ll_selected_row = GetSelectedRow( 0 )
if ll_selected_row <= 0 then return

//If dw_detail.ModifiedCount() > 0 or &
//	dw_detail.DeletedCount() > 0 or &
//	dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
//	
//	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
//	CHOOSE CASE li_ret
//		CASE 1
//			li_ret = Parent.Event ue_save()
//			If isnull( li_ret ) or li_ret < 0 then return
//		CASE 2
//		CASE ELSE
//			Return
//	END CHOOSE
//		
//end If


ls_contractseq = string(dw_master.object.contractseq[ll_selected_row])
setnull(ls_orderno)

//ls_customerid = dw_master.object.contractmst_customerid[ll_selected_row]
////ls_orderno    = string(dw_master.object.orderno[ll_selected_row])
//dw_detail3.retrieve(ls_contractseq,ls_customerid)
//
ll_row = dw_detail2.retrieve(ls_contractseq,ls_orderno )  //할부정보

end event

event dw_master::clicked;call super::clicked;String ls_status, ls_priceplan, ls_where,	ls_contractseq


If row <= 0 Then Return 0

ls_status      = Trim(dw_master.object.status[row])
ls_priceplan   = Trim(dw_master.object.priceplan[row])
ls_contractseq = STRING(dw_master.object.contractseq[row])

//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If




end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::retrieveend;call super::retrieveend;String ls_status, ls_priceplan, ls_where, ls_contractseq


If rowcount = 0 Then Return 0

ls_status   	= Trim(dw_master.object.status[1])
ls_priceplan	= Trim(dw_master.object.priceplan[1])
ls_contractseq = STRING(dw_master.object.contractseq[1])

//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If

end event

type dw_detail from w_a_reg_m_m3`dw_detail within mobile_reg_chg_paytype
integer y = 1492
integer width = 2725
integer height = 396
integer taborder = 40
string dataobject = "mobile_dw_change_paytype"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m3`p_insert within mobile_reg_chg_paytype
boolean visible = false
integer y = 1980
end type

type p_delete from w_a_reg_m_m3`p_delete within mobile_reg_chg_paytype
boolean visible = false
integer y = 1980
end type

type p_save from w_a_reg_m_m3`p_save within mobile_reg_chg_paytype
integer x = 59
integer y = 1924
end type

type p_reset from w_a_reg_m_m3`p_reset within mobile_reg_chg_paytype
integer x = 361
integer y = 1924
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within mobile_reg_chg_paytype
integer y = 992
integer width = 4137
integer height = 460
integer taborder = 30
string dataobject = "b1dw_reg_customer_t6_pop_v20_quota"
end type

event dw_detail2::retrieveend;string ls_salemodelcd, ls_priceplan, ls_fromdt
integer i, li_cnt

If rowcount >  0 Then
	
	dw_detail.reset()
	dw_detail.insertrow(0)
		
	ls_salemodelcd	= dw_detail2.object.sale_modelcd[1]
	ls_priceplan 	= dw_detail2.object.priceplan[1]
	ls_fromdt      = String(fdt_get_dbserver_now(),'yyyymmdd')
	
	dw_detail.object.sale_modelcd[1] = ls_salemodelcd
	dw_detail.object.priceplan[1] = ls_priceplan
	li_cnt = 0
	for i = 1 to dw_detail2.rowcount()
		if dw_detail2.object.cancel_yn[i] = 'N'  and dw_detail2.object.sale_type[i] = 'M' then //취소되지않고 할부인 유효한 건만..
		
			wf_mobile_sales(i,ls_salemodelcd, ls_priceplan, 1, ls_fromdt)
			li_cnt++
			
		end if
	next
	
	if li_cnt = 0 then
			messagebox("단말정보", "할부판매된 계약이 아닙니다.")
			dw_detail.reset()
			p_save.TriggerEvent("ue_disable")
			Return
	end if
End If

p_save.TriggerEvent("ue_enable")	
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within mobile_reg_chg_paytype
integer x = 27
integer y = 960
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within mobile_reg_chg_paytype
integer x = 27
integer y = 1452
end type

type dw_validkey from u_d_base within mobile_reg_chg_paytype
boolean visible = false
integer x = 64
integer y = 2108
integer width = 3063
integer height = 404
integer taborder = 0
boolean bringtotop = true
string dataobject = "b1dw_inq_chg_priceplan_validkey"
end type

type st_horizontal3 from st_horizontal within mobile_reg_chg_paytype
boolean visible = false
integer y = 1544
end type

