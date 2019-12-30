$PBExportHeader$ssrt_reg_cancel_payment.srw
$PBExportComments$[1hera] CancelPayment
forward
global type ssrt_reg_cancel_payment from w_a_reg_m_sql
end type
type st_horizontal from statictext within ssrt_reg_cancel_payment
end type
type dw_split from datawindow within ssrt_reg_cancel_payment
end type
type p_1 from u_p_reset within ssrt_reg_cancel_payment
end type
type cb_1 from commandbutton within ssrt_reg_cancel_payment
end type
type dw_detail2 from u_d_indicator within ssrt_reg_cancel_payment
end type
end forward

global type ssrt_reg_cancel_payment from w_a_reg_m_sql
integer width = 4229
integer height = 2096
event type long ue_retive ( )
event ue_reset ( )
st_horizontal st_horizontal
dw_split dw_split
p_1 p_1
cb_1 cb_1
dw_detail2 dw_detail2
end type
global ssrt_reg_cancel_payment ssrt_reg_cancel_payment

type variables
//NVO For Processing
u_cust_a_db iu_cust_db_prc



//AncestorReturnValue사용으로 필요가 없어짐.
//Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

//Messeage for messagebox
String is_msg_text
String is_msg_process

//Messeage No. for messagebox
Long il_msg_no

protected privatewrite string is_cur_fr,is_cur_to,is_next_fr,is_next_to
protected privatewrite Integer ii_input_error


String 	is_paycod, 		is_format, 	is_reqdt
Double 	ib_seq
DATE		idt_shop_closedt

DEC{2} 	idc_amt[], 		idc_total, 	idc_income_tot
String 	is_method[], 	is_trcod[]
Integer 	ii_method_cnt 	

end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public function integer wfi_get_paytype (string as_paytype)
public subroutine wf_set_total ()
public function integer wf_split (date wfdt_paydt)
public function integer wfi_get_payid (string as_payid, string as_memberid)
public subroutine of_refreshbars ()
public function long wfi_call_proc ()
end prototypes

event ue_reset();Int 		li_rc
String 	ls_paytype
String 	ls_ref_desc, 	ls_paymethod
F_INIT_DSP(1,"","")

dw_cond.Reset()
dw_cond.InsertRow(0)

dw_detail.Reset()
dw_detail2.Reset()

// Set the Top, Bottom Controls
idrg_Top 		= dw_detail
idrg_Bottom 	= dw_detail2

//Change the back color so they cannot be seen.
ii_WindowTop 				= idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor 			= BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

//****kEnn : 이부분이 필요하면 수정사항 반영할 것
//li_rc = This.TriggerEvent("ue_reset")
//****
//ls_paytype = " "

//dw_cond.object.trdt.Protect 	= 1
//li_rc 								= wfi_get_paytype(ls_paytype)
dw_cond.object.paydt[1] 		= f_find_shop_closedt(GS_SHOPID)


p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")

end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness)



end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.
If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

public function integer wfi_get_paytype (string as_paytype);String ls_paycod, ls_paytype

SELECT substr(ref_content, 1, Instr(ref_content, ';') -1) 
INTO :is_paycod
FROM sysctl1t 
WHERE module = 'B5' 
AND ref_no = 'I101';

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Payment Method(wfi_get_paycode)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "입금유형이 없습니다.(B5:I101)")
	Return -1
End If

dw_cond.object.paycod[1] = is_paycod

Return 0 
end function

public subroutine wf_set_total ();dec{2} ldc_TOTAL
ldc_total = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total = dw_detail.GetItemNumber(dw_detail.RowCount(), "all_sum") 
END IF

dw_cond.Object.total[1] 		= ldc_total


F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

public function integer wf_split (date wfdt_paydt);Long		ll, 				ll_cnt,			ll_row
Integer 	li_pay_cnt, 	li_pp,			li_first,		li_paycnt, 	li_chk
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 		ldc_income,	ldc_receive
String 	ls_method,		ls_basecod, 	ls_customerid, ls_payid, 	ls_trcod, &
			ls_saletrcod, 	ls_req_trdt, 	ls_remark

li_pay_cnt 	= 1

dw_cond.AcceptText()
dw_detail2.SetSort("Priority A")
dw_detail2.Sort()

ls_remark						= dw_cond.object.remark[1]
IF ISNull(ls_remark) 		then 		ls_remark = ''

ldc_receive 	= dw_cond.object.cp_receive[1]
ls_customerid 	= dw_cond.Object.customerid[1]
ls_payid 		= dw_cond.Object.customerid[1]


//customerm Search
select basecod INTO :ls_basecod from customerm  where customerid =  :ls_customerid ;

ll_cnt 				= dw_detail2.RowCount()
idc_income_tot 	= 0 // 전액을 입금하지 않을 경우에 대비 각 입금반영시 Add처리

FOR ll = 1 to ll_cnt
	ldc_tramt	= dw_detail2.object.cp_amt[ll]
	// 각 아이템의 입금완불이 안된 경우만 처리
	IF dw_detail2.object.COMPLETE_YN[ll] = 'N'  THEN
	
		ldc_income 		= 0
		ls_req_trdt 	= dw_detail2.object.trdt[ll]
		li_first 		= 0
		li_chk 			= 0
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		FOR li_pp =  li_pay_cnt to ii_method_cnt
			ls_method 	= is_method[li_pp]
			ls_trcod 	= is_trcod[li_pp]
			ldc_rem 		= idc_amt[li_pp]
		
			IF ldc_rem >= ldc_tramt THEN
				ldc_saleamt 	= ldc_tramt
				ldc_income 		+= ldc_saleamt
				IF li_first =  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else 
					li_paycnt 	= 0
				END IF
				ldc_rem 			= ldc_rem - ldc_saleamt
				ldc_tramt 		= 0
			ELSE
				ldc_saleamt 	= ldc_rem
				ldc_income 		+= ldc_saleamt
				ldc_tramt 		= ldc_tramt - ldc_rem
				ldc_rem 			= 0
				IF li_first =  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else
					li_paycnt 	= 0
				END IF
				li_pay_cnt		+= 1
			END IF
	
			ll_row =  dw_split.InsertRow(0)
			//---------------------------------------
			dw_split.Object.paydt[ll_row] 		= wfdt_paydt
			dw_split.Object.shopid[ll_row] 		= gs_shopid
			dw_split.Object.operator[ll_row] 	= gs_user_id
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
			dw_split.Object.paymethod[ll_row] 	= ls_method
			dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
			dw_split.Object.payamt[ll_row] 		= ldc_saleamt
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
			dw_split.Object.dctype[ll_row] 		= 'D'
			dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
			dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]
			
			idc_total 									= idc_total - ldc_saleamt
			idc_income_tot 							+= ldc_saleamt
			
			IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
					li_chk = 1
					exit
			END IF
			IF li_pay_cnt > ii_method_cnt then exit
		NEXT
	
		IF ldc_rem > 0 THEN		idc_amt[li_pay_cnt] = ldc_rem
		
		IF li_chk =  1 then
			dw_detail2.object.chk[ll] 		= '1'
			dw_detail2.object.income[ll] 	= ldc_income
		else
			dw_detail2.object.chk[ll] 		= '2'
			dw_detail2.object.income[ll] 	= ldc_income
		end if
	END IF
	IF idc_total <= 0 then EXIT
NEXT

dw_cond.Object.total[1] =  idc_income_tot

dw_split.AcceptText()

return 0
end function

public function integer wfi_get_payid (string as_payid, string as_memberid);String ls_payid, ls_paynm, ls_memberid

ls_payid 		= as_payid

IF ls_payID <> '' THEN
	Select Customernm, memberid  Into :ls_paynm, :ls_memberid  From Customerm
    Where customerid = :ls_payid;
ELSE
	Select CUSTOMERID, Customernm  Into :ls_payid, :ls_paynm  From Customerm
    Where MEMBERID = :as_memberid;
END IF

IF IsNull(ls_paynm) 		then ls_paynm 		= ''
IF IsNull(ls_payid) 		then ls_payid 		= ''
IF IsNull(ls_memberid) 	then ls_memberid 	= ''

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay ID(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return -1
End If

dw_cond.object.marknm[1] 	= ls_paynm
dw_cond.object.payid[1] 	= ls_payid
dw_cond.object.memberid[1] = ls_memberid

Return 0

end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public function long wfi_call_proc ();String ls_errmsg, ls_pgm_id,  ls_payid
double lb_count , lb_seqno
Long   ll_return

dw_detail.AcceptText()
ls_errmsg 	= space(256)
ls_pgm_id 	= gs_pgm_id[gi_open_win_no]
//ls_paytype 	= dw_cond.object.paycod[1]
ls_payid 	= trim(dw_cond.object.payid[1])
ll_return 	= -1

//처리부분
SQLCA.B5REQPAY2DTL_PAYID_cancel(ls_payid, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count) 

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return  -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	Return -1
Else				//성공
	Return 0
End If

Return 0

end function

event open;call super::open;Int 		li_rc
String 	ls_paytype
String 	ls_ref_desc, 	ls_paymethod
String 	ls_temp

F_INIT_DSP(1,"","")

// Set the Top, Bottom Controls
idrg_Top 		= dw_detail
idrg_Bottom 	= dw_detail2

//Change the back color so they cannot be seen.
ii_WindowTop 				= idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor 			= BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

//dw_cond.object.trdt.Protect 	= 1
li_rc 								= wfi_get_paytype(ls_paytype)
dw_cond.object.paydt[1] 		= f_find_shop_closedt(GS_SHOPID)

//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_trcod[])

p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")


end event

event resize;call super::resize;of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_save_sql();call super::ue_save_sql;String 	ls_payid , 	ls_paydt  , 	ls_trdt  , 	ls_trcod, 	ls_transdt
String 	ls_pgm_id, 	ls_user_id, 	ls_remark,	ls_code,		ls_codenm
String 	ls_temp, 	ls_ref_desc
Long   	ll_rc    , 	ll_seq,			ll_rtn
Int    	li_rc    , 	li_rc2,			li_rtn, jj

//add -- 2007.7.13 [1hera] -- sams용
DEC{2}  	ldc_amt0[], 		ldc_tramt, 			ldc_total, 		&
			ldc_receive, 		ldc_change, 		ldc_cash, 				ldc_card_total
String 	ls_method0[], 		ls_trcod0[]
Integer  li_method_cnt, 	li_lp
date     ldt_paydt, 			ldt_trdt
String 	ls_canceltype,		ls_customerid, 	ls_req_trdt, 			ls_memberid, &
			ls_saletrcod,		ls_method
Dec{2} 	ldc_10, 				ldc_90, 				ldc_100, 				ldc_saleamt, &
			ldc_impact, 		ldc_card,			ldc_income[]
String 	ls_appseq, 			ls_seq, 		ls_prt,				ls_basecod,				ls_itemcod, &
			ls_regcod,			ls_paymethod[]
Long		ll_shopcount,		ll_payseq

idt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)
ldt_paydt			= dw_cond.Object.paydt[1]
ls_remark			= dw_cond.Object.remark[1]

IF IsNull(ls_remark) then ls_remark = ''

// 카드입금액이 총판매액보다 크면...
ldc_total 		= 	dw_cond.Object.total[1]

li_rc 			= -2  //필수 입력 항목 요구
ls_payid 		= Trim(dw_cond.object.payid[1])
ls_memberid 	= Trim(dw_cond.object.memberid[1])
ls_paydt 		= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_paydt 		= dw_cond.object.paydt[1]
ls_remark 		= dw_cond.object.remark[1]

ls_pgm_id 		= gs_pgm_id[gi_open_win_no]
ls_user_id 		= gs_user_id


If IsNull(ls_memberid) 	Then ls_memberid 	= ""
If IsNull(ls_payid) 		Then ls_payid 		= ""
If IsNull(ls_paydt) 		Then ls_paydt 		= ""

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Payer")
	dw_cond.SetColumn("payid")
	Return li_rc
End If

If ls_paydt = "" Then
	f_msg_usr_err(200, Title, "Cancel Date")
	dw_cond.SetColumn("paydt")
	Return li_rc
End If
//customerm.basecod Search
select basecod   INTO :ls_basecod   FROM customerm
 WHERE customerid = :ls_payid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""

//Paymethod
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_paymethod[])

ldc_income[1] = 0 //Paymethod = 101 TRCODE = 900
ldc_income[2] = 0 //Paymethod = 102 TRCODE = 930
ldc_income[3] = 0 //Paymethod = 103 TRCODE = 910
ldc_income[4] = 0 //Paymethod = 104 TRCODE = 920
ldc_income[5] = 0 //Paymethod = 105 TRCODE = 950
//=================================================
//0. Total 금액 계산
//=================================================
ldc_total = 0
FOR li_lp =  1 to dw_detail2.RowCount()
	ldc_tramt 		= dw_detail2.Object.repayment[li_lp] * -1
	ls_canceltype 	= trim(dw_detail2.Object.cancel_type[li_lp])
	IF IsNull(ls_canceltype) then ls_canceltype = ''
	IF ldc_tramt <> 0 AND ls_canceltype <> '' then
		ldc_total += ldc_tramt
		//trcod 조회
		FOR jj = 1 to 5
			IF is_trcod[jj] = ls_canceltype then
				ldc_income[jj] += ldc_tramt
			END IF
		NEXT
		
		
		
	END IF
NEXT

//1 영수증정보에 Insert
IF ldc_total = 0 THEN return -1

//SEQ 
Select seq_receipt.nextval		  Into :ls_appseq						  From dual;

//SHOP COUNT
Select shopcount	    Into :ll_shopcount	  From partnermst
 WHERE partner = :GS_SHOPID ;
		
IF IsNull(ll_shopcount) THEN ll_shopcount = 0
If SQLCA.SQLCode < 0 Then
	RollBack;
	f_msg_sql_err(title, " Update Error(PARTNERMST)")
	Return -1
End If			
		
ll_shopcount += 1
ls_prt = 'Y'
Select seq_app.nextval		  Into :ls_seq						  From dual;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title,  " Sequence Error(seq_app)")
	RollBack;
	Return -1
End If
////영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
//ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
//fi_cut_string(ls_temp, ";", ls_rtype[])

	
insert into RECEIPTMST ( 
					approvalno,		shopcount,			receipttype,	shopid,			posno,
				  	workdt,														trdt,				
					memberid,		operator,			total,		  	cash,				change, 
				  	seq_app,			customerid,			prt_yn)
values 
			   ( :ls_appseq, 		:ll_shopcount,		'200', 			:GS_SHOPID, 	NULL,
				  to_date(:ls_paydt, 'yyyy-mm-dd'),						:idt_shop_closedt,	 
				  :ls_memberid,	:GS_USER_ID,		:ldc_total,	  	0,					0,
				  :ls_seq,			:ls_payid,	:ls_prt)	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Insert Error(RECEIPTMST)")
		RollBack;
		Return -1
End If			
		
//ShopCount ADD 1
Update partnermst
	Set shopcount 	= :ll_shopcount
 Where partner  = :GS_SHOPID ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Update  Error(PARTNERMST)")
		RollBack;
		Return -1
End If		

//2. REQPAY & dailypayment 에 Insert
	
FOR li_lp =  1 to dw_detail2.RowCount()
	ldt_trdt			= date(dw_detail2.Object.trdt[li_lp])
	lS_trdt			= STRING(dw_detail2.Object.trdt[li_lp], 'yyyy-mm-dd')
	ls_canceltype 	= trim(dw_detail2.Object.cancel_type[li_lp])
	IF IsNull(ls_canceltype) then ls_canceltype = ''
	
	ldc_tramt 		= dw_detail2.Object.repayment[li_lp] * -1
	ls_saletrcod 	= dw_detail2.Object.trcod[li_lp]
	ls_method 		= ''
	//trcod 조회
	FOR jj = 1 to 5
		IF is_trcod[jj] = ls_canceltype then
			ls_method = is_method[jj]
		END IF
	NEXT
	
	IF ldc_tramt <> 0 AND ls_canceltype <> '' then
	
		Select seq_reqpay.nextval Into :ib_seq From dual;
		//수동 입금 반영 Table Insert
		Insert Into reqpay (
       	seqno,		payid, 		paytype, 	trcod, 				paydt,
			trdt, 		remark, 		prc_yn, 		payamt, 				transdt,
			crt_user, 	crtdt,		pgm_id,		sale_trcod,			cancel_yn)
		values ( 
			:ib_seq, 	:ls_payid, 	:ls_method,	:ls_canceltype, 	:ldt_paydt,
			:ldt_trdt, 	:ls_trdt, 	'N', 			:ldc_tramt, 		sysdate,
			:gs_user_id, sysdate, 	:ls_pgm_id, :ls_saletrcod,		'Y' );

		If SQLCA.SQLCode < 0 Then
			Rollback ;
			f_msg_sql_err(Title, "Insert Error(REQPAY)")
			Return -1
		End If	
		
		//==========================================================
		//DailyPayment 에 Insert
		//==========================================================
		Select seq_dailypayment.nextval		  Into :ll_payseq  From dual;
		IF sqlca.sqlcode < 0 THEN
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
			RollBack ;
			Return -1 
		END IF
	
		ls_itemcod 	= dw_detail2.Object.itemcod[li_lp]
		ls_regcod  	= dw_detail2.Object.regcod[li_lp]

	
		insert into dailypayment
				( 	payseq,			paydt,			
					shopid,			operator,		customerid,
				  	itemcod,			paymethod,		regcod,			payamt,			basecod,
				  	paycnt,			payid,			remark,			trdt,				mark,
				  	auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
				  	MANUAL_YN,		PGM_ID )
		values 
			   ( 	:ll_payseq, 	:idt_shop_closedt, 	
					:GS_SHOPID, 	:GS_USER_ID, 	:ls_payid,
				  	:ls_itemcod,	:ls_method,		:ls_regcod,		:ldc_tramt,		:ls_basecod,
				  	1,					:ls_payid,		:ls_remark,		:ldt_paydt,		null,
				  	NULL,				'C',				:ls_appseq,		sysdate,			sysdate,		:gs_user_id,
				  	'N',				'CANCEL' )	 ;
				   
		//		저장 실패 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
			RollBack;
			Return -1
		End If	
	END IF
NEXT
//===============================================================
//   Last
//영수증 발행
//===============================================================
String 	ls_lin1, ls_lin2, ls_lin3
DEC	 		ldc_shopCount
ls_lin1 	= '------------------------------------------'
ls_lin2 	= '=========================================='
ls_lin3 	= '******************************************'


//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//4. 영수증 발행
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
String 	ls_itemnm, ls_val
Integer 	li_cnt
Long		ll_keynum
String	ls_facnum, ls_chk
String 	ls_methodnm

FOR jj = 1  to 2
	IF jj = 1 then 
		li_rtn = f_pos_header(GS_SHOPID, 'B', LL_SHOPCOUNT, 1 )
	ELSE 
		li_rtn = f_pos_header(GS_SHOPID,  'Z', LL_SHOPCOUNT, 0 )
	END IF
	IF li_rtn < 0 then
		Rollback ;
		MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
		PRN_ClosePort()
		return  -1
	END IF
		
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//2. Item List 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	ldc_total 	= 0
	ll_seq 		= 0
	FOR li_lp = 1 to dw_detail2.RowCount()
		ldc_tramt 		= dw_detail2.Object.repayment[li_lp] * -1
		ls_canceltype 	= trim(dw_detail2.Object.cancel_type[li_lp])
		IF IsNull(ls_canceltype) then ls_canceltype = ''
		
		IF ldc_tramt <> 0 AND ls_canceltype <> '' then
				ll_seq 		+= 1
				ls_temp 		= String(li_lp, '000') + ' ' //순번
				ls_itemcod 	= trim(dw_detail2.Object.itemcod[li_lp])
				ls_itemnm 	= trim(dw_detail2.Object.itemnm[li_lp])
				IF IsNull(ls_itemnm) then ls_itemnm 	= ""
				
				ldc_saleamt	= ldc_tramt
				ldc_total 	+= ldc_saleamt 
				ls_temp 		+= LeftA(ls_itemnm + space(24), 24) + ' '   //아이템
				li_cnt 		=  1
				ls_temp 		+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
				ls_val 		= fs_convert_amt(ldc_saleamt,  8)
				ls_temp 		+= ls_val //금액
				f_printpos(ls_temp)	
		
				ls_regcod =  trim(dw_detail2.Object.regcod[li_lp])
				//regcode master read
				select keynum, 		trim(facnum)
				  INTO :ll_keynum,	:ls_facnum
				  FROM regcodmst
				 where regcod = :ls_regcod ;
		
				IF IsNull(ll_keynum) or sqlca.sqlcode < 0	then ll_keynum 	= 0
				IF IsNull(ls_facnum) or sqlca.sqlcode < 0	then ls_facnum 	= ""
				ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
				f_printpos(ls_temp)
		end if
	NEXT
	
	f_printpos(ls_lin1)

	ls_val 	= fs_convert_sign(ldc_total, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
	//결제 수단별 금액 처리
	For li_lp = 1 To 5
			ldc_cash = ldc_income[li_lp]
			ls_code 	= ls_paymethod[li_lp]
			IF ldc_cash <> 0 then
				ls_val 	= fs_convert_sign(ldc_cash,  8)
				select codenm INTO :ls_codenm from syscod2t
				where grcode = 'B310' 
				  and use_yn = 'Y'
				  AND code = :ls_code ;
				  
				ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
				f_printpos(ls_temp)
			EnD IF
	NEXT
	ls_val 	= fs_convert_sign(ldc_change,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
	F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id)
next 
PRN_ClosePort()
//===================================
commit;
Return 0

end event

event ue_ok();call super::ue_ok;DataWindowChild ldwc_trdt

String 	ls_payid, 	ls_where, 	ls_where2
Long   	ll_rc
Int 	 	li_rc2, 		li_exist
DEC{2}	ldc_summary

ls_payid 		= Trim(dw_cond.object.payid[1])
If IsNull(ls_payid) Then ls_payid = ""

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Payer")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("payid")
	Return
Else
   ll_rc = wfi_get_payid(ls_payid, "")  

   If ll_rc < 0 Then
		f_msg_usr_err(201, Title, "Payer")
		dw_cond.SetColumn("payid")
		Return
	End If
End If

ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "PAYID = '" + ls_payid + "'"
End If

ls_where2 = ""
If ls_payid <> "" Then
	If ls_where2 <> "" Then ls_where2 += " AND "
	ls_where2 += "A.PAYID = '" + ls_payid + "'"
End If

dw_detail.is_where 	= ls_where
ll_rc 					= dw_detail.Retrieve()
IF ll_rc > 0 THEN
	SELECT SUM(tramt) INTO :ldc_summary FROM REQDTL
	 WHERE payid = :ls_payid ;
	 
	IF IsNull(ldc_summary) OR sqlca.sqlcode < 0 then ldc_summary = 0
ELSE
	ldc_summary				= 0
	return 
END IF
dw_cond.Object.total[1] =  ldc_summary

dw_detail2.is_where 	= ls_where2
ll_rc 					= dw_detail2.Retrieve()

end event

on ssrt_reg_cancel_payment.create
int iCurrent
call super::create
this.st_horizontal=create st_horizontal
this.dw_split=create dw_split
this.p_1=create p_1
this.cb_1=create cb_1
this.dw_detail2=create dw_detail2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_horizontal
this.Control[iCurrent+2]=this.dw_split
this.Control[iCurrent+3]=this.p_1
this.Control[iCurrent+4]=this.cb_1
this.Control[iCurrent+5]=this.dw_detail2
end on

on ssrt_reg_cancel_payment.destroy
call super::destroy
destroy(this.st_horizontal)
destroy(this.dw_split)
destroy(this.p_1)
destroy(this.cb_1)
destroy(this.dw_detail2)
end on

event ue_save();Integer 	li_return, 	li_rc, 		li_tmp
String 	ls_tmp
Date 		ld_tmp


date		ldt_shop_closedt, ldt_paydt
dw_detail2.AcceptText()

ldt_paydt 			= dw_cond.Object.paydt[1]
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is <= -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title 		= This.Title
		iu_mdb_app.is_caller 	= "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
		//입금 처리 반영
		li_rc = wfi_call_proc()
		
		//성공적이면 commit
		iu_mdb_app.is_title 	= This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
	
		//Error 
		If li_rc < 0 Then 
			f_msg_info(3010, This.Title, "Save")
		Else	
		   f_msg_info(3000, This.Title, "Save")
		End If
		//초기화
		   SetNull(ld_tmp)
			SetNull(li_tmp)
			SetNull(ls_tmp)
			dw_cond.object.paydt[1] 	= f_find_shop_closedt(GS_SHOPID)
			dw_cond.object.remark[1] 	= ''
			This.TriggerEvent("ue_ok")
			p_ok.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
End Choose

end event

type dw_cond from w_a_reg_m_sql`dw_cond within ssrt_reg_cancel_payment
integer x = 46
integer y = 56
integer width = 2670
integer height = 364
string dataobject = "ssrt_cnd_cancel_payment"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid
ldwo_payid = dw_cond.object.payid

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] 	= iu_cust_help.is_data[1]	//고객번호
			Object.marknm[row] 	= iu_cust_help.is_data[2]	//고객명
			Object.memberid[row] = iu_cust_help.is_data[4]	//memberid
			//Item Changed Event 발생
			dw_cond.Event ItemChanged(1,ldwo_payid ,iu_cust_help.is_data[1])
		End If		
End Choose



Return 0

end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldwc_trdt
String ls_payid, ls_trcod, ls_customeryn, ls_filter
Int    li_rc, li_rc2  , li_exist

Choose Case dwo.Name
	case 'memberid'
		ls_payid = Trim(dw_cond.object.memberid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid("", ls_payid)

		If li_rc < 0 Then
			dw_cond.object.memberid[1] 	= ""
			dw_cond.object.payid[1] 		= ""
			dw_cond.object.marknm[1] 		= ""
			dw_cond.SetColumn("memberid")
			Return 0
		End IF
		
	Case "payid"
		ls_payid = Trim(dw_cond.object.payid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid, "")

		If li_rc < 0 Then
			dw_cond.object.payid[1] 		= ""
			dw_cond.object.memberid[1] 	= ""
			dw_cond.object.marknm[1] 		= ""
			dw_cond.SetColumn("payid")
			Return 0
		End IF
End Choose

Return 0
end event

event dw_cond::ue_init();call super::ue_init;DataWindowChild ldwc_trdt
Int    li_rc2, li_exist
String ls_payid

//If IsNull(ls_payid) Then ls_payid = " "
//li_rc2 = GetChild("trdt", ldwc_trdt)
//IF li_rc2 = -1 THEN 
//	MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
//	Return
//End If
//
//ldwc_trdt.SetTransObject(SQLCA)
//li_exist = ldwc_trdt.Retrieve(ls_payid)
//If li_exist < 0 Then 				
//End If  


This.idwo_help_col[1] 	= This.Object.payid
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.is_data[1] 			= "CloseWithReturn"




end event

event dw_cond::losefocus;call super::losefocus;AcceptText()
end event

type p_ok from w_a_reg_m_sql`p_ok within ssrt_reg_cancel_payment
integer x = 2752
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within ssrt_reg_cancel_payment
integer x = 3602
integer y = 52
end type

type gb_cond from w_a_reg_m_sql`gb_cond within ssrt_reg_cancel_payment
integer x = 9
integer width = 2725
integer height = 428
integer taborder = 0
end type

type p_save from w_a_reg_m_sql`p_save within ssrt_reg_cancel_payment
integer x = 3035
integer y = 52
end type

type dw_detail from w_a_reg_m_sql`dw_detail within ssrt_reg_cancel_payment
integer x = 14
integer y = 440
integer width = 3401
integer height = 816
string dataobject = "ssrt_reg_cancel_payment_sum"
boolean ib_sort_use = false
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event dw_detail::retrieveend;call super::retrieveend;
wf_set_total()


end event

type st_horizontal from statictext within ssrt_reg_cancel_payment
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 27
integer y = 1268
integer width = 745
integer height = 32
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeNS!"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If

	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;// Hide the bar
BackColor = il_HiddenColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

type dw_split from datawindow within ssrt_reg_cancel_payment
boolean visible = false
integer x = 2757
integer y = 312
integer width = 837
integer height = 108
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean border = false
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type p_1 from u_p_reset within ssrt_reg_cancel_payment
integer x = 3319
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

type cb_1 from commandbutton within ssrt_reg_cancel_payment
boolean visible = false
integer x = 2830
integer y = 156
integer width = 402
integer height = 112
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "call_wfi"
end type

event clicked;wfi_call_proc()
end event

type dw_detail2 from u_d_indicator within ssrt_reg_cancel_payment
event type integer ue_retrieve ( long al_select_row )
integer y = 1300
integer width = 3397
integer height = 580
integer taborder = 30
string dataobject = "ssrt_reg_cancel_payment_list"
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event losefocus;call super::losefocus;AcceptText()
end event

event itemchanged;call super::itemchanged;DEC{2}	ldc_payamt, ldc_repayment
string ls_aaa

ls_aaa = '1'

choose case dwo.name
	case 'repayment'
		ldc_payamt 		= this.Object.payidamt[row]
		ldc_repayment 	= this.Object.repayment[row]
		IF ldc_repayment > ldc_payamt then
			this.object.repayment[row]		= 0
			Return 1
		END IF
end choose

return 0
end event

event itemerror;call super::itemerror;return 1
end event

