$PBExportHeader$ssrt_reg_cancel_payment_shop.srw
$PBExportComments$[1hera] CancelPayment - Shop 용
forward
global type ssrt_reg_cancel_payment_shop from w_a_reg_m
end type
type dw_daily from datawindow within ssrt_reg_cancel_payment_shop
end type
end forward

global type ssrt_reg_cancel_payment_shop from w_a_reg_m
integer width = 3831
integer height = 1852
dw_daily dw_daily
end type
global ssrt_reg_cancel_payment_shop ssrt_reg_cancel_payment_shop

type variables
DATE 		idt_shop_closedt
String 	is_paydt,	is_seq_app,	is_payid
Long		ib_seq
end variables

forward prototypes
public function long wfi_call_proc (string wfs_payid)
end prototypes

public function long wfi_call_proc (string wfs_payid);String ls_errmsg, ls_pgm_id,  ls_payid
double lb_count , lb_seqno
Long   ll_return

dw_detail.AcceptText()
ls_errmsg 	= space(256)
ls_pgm_id 	= gs_pgm_id[gi_open_win_no]
ls_payid 	= wfs_payid
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

on ssrt_reg_cancel_payment_shop.create
int iCurrent
call super::create
this.dw_daily=create dw_daily
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_daily
end on

on ssrt_reg_cancel_payment_shop.destroy
call super::destroy
destroy(this.dw_daily)
end on

event ue_ok();call super::ue_ok;String ls_where
Long ll_row


is_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
is_payid 	= Trim(dw_cond.object.payid[1])
is_seq_app 	= Trim(dw_cond.object.seq_app[1])

If IsNull(is_paydt) 		Then is_paydt 	= ""
If IsNull(is_payid) 		Then is_payid 	= ""
If IsNull(is_seq_app) 	Then is_seq_app 	= ""

ls_where = ""

//SHOPID
If GS_SHOPID <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "shopid = '" + GS_SHOPID + "' "
End If

//paydt
If is_paydt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(trdt, 'yyyymmdd') = '" + is_paydt + "' "
End If
//payid
If is_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " customerid = '" + is_payid + "' "
End If
//seq_app
If is_seq_app <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " seq_app = '" + is_seq_app + "' "
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

event type integer ue_extra_save();//add -- 2007.7.13 [1hera] -- sams용
Double 	lb_seq
DEC{2}  	ldc_total, ldc_income[], 	ldc_payamt , &
			ldc_saleamt,	ldc_cash,	ldc_change

Integer  li_lp,	li_rc,	jj, 			li_paycnt, kk,	li_rtn
date     ldt_paydt, 			ldt_trdt,	ld_reqdt
String 	ls_customerid, 	ls_memberid,		ls_remark,	ls_pgm_id, &
			ls_user_id
String 	ls_appseq, 			ls_seq_app, 		ls_prt
Long		ll_shopcount,		ll_payseq,			ll_cnt,	ll_seq
String 	ls_approvalno,	ls_cancel, &
			ls_itemcod, &
			ls_paymethod, &
			ls_regcod , &
			ls_basecod , &
			ls_payid,	ls_call_payid,  &
			ls_trdt, &
			ls_saletrcod, &
			ls_temp, ls_ref_desc, ls_trcode,  ls_code, ls_codenm, &
			ls_method[], ls_trcod[]
//==============영수증 발행용...
String 	ls_lin1, ls_lin2, ls_lin3
DEC	 	ldc_shopCount
ls_lin1 	= '------------------------------------------'
ls_lin2 	= '=========================================='
ls_lin3 	= '******************************************'
String 	ls_itemnm, ls_val
Integer 	li_cnt
Long		ll_keynum
String	ls_facnum, ls_chk
String 	ls_methodnm


SELECT REQDT INTO :ld_reqdt FROM REQCONF
 WHERE CHARGEDT = '1' ;


//========================================================
//paymethod
ls_temp 			= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_trcod[])

li_rc 			= -2  //필수 입력 항목 요구
ls_memberid 	= Trim(dw_cond.object.memberid[1])
ldt_paydt 		= dw_cond.object.paydt[1]
ls_remark 		= dw_cond.object.remark[1]
ls_pgm_id 		= gs_pgm_id[gi_open_win_no]
ls_user_id 		= gs_user_id

IF IsNull(ls_remark) 	then ls_remark 	= ''
If IsNull(ls_memberid) 	Then ls_memberid 	= ''
//=====================================================
//SHOP COUNT
Select shopcount	Into :ll_shopcount  From partnermst
 WHERE partner = :GS_SHOPID ;
IF IsNull(ll_shopcount) THEN ll_shopcount = 0
//=====================================================

FOR li_lp =  1 to dw_detail.RowCount()
	ls_cancel 	= trim(dw_detail.Object.cancel_yn[li_lp])
	IF IsNull(ls_cancel) then ls_cancel = ''
	
	IF ls_cancel = 'Y' then // cancel 
		ls_approvalno 	= trim(dw_detail.Object.approvalno[li_lp])
		ls_call_payid	= trim(dw_detail.Object.customerid[li_lp])
		//===========================================================
		//1 영수증정보에 Insert
		//SEQ 
		Select seq_receipt.nextval		Into :ls_appseq	From dual;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title,  " Sequence Error(seq_receipt)")
			RollBack;
			Return -1
		End If
		Select seq_app.nextval		  Into :ls_seq_app	  From dual;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title,  " Sequence Error(seq_app)")
			RollBack;
			Return -1
		End If
		
		//영수증발행 수 Inc.
		ll_shopcount 	+= 1
		ls_prt 			= 'Y' // 영수증발행여부(Y)
		ldc_total = dw_detail.Object.total[li_lp] * -1

		insert into RECEIPTMST ( 
					approvalno,		shopcount,			receipttype,	shopid,			posno,
				  	workdt,														trdt,				
					memberid,		operator,			total,		  	cash,				change, 
				  	seq_app,			customerid,			prt_yn)
		values 
			   ( :ls_appseq, 		:ll_shopcount,		'200', 			:GS_SHOPID, 	NULL,
				  to_date(:is_paydt, 'yyyy-mm-dd'),						:idt_shop_closedt,	 
				  :ls_memberid,	:GS_USER_ID,		:ldc_total,	  	0,					0,
				  :ls_seq_app,		:ls_call_payid,	:ls_prt)	 ;
				   
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " Insert Error(RECEIPTMST)")
				RollBack;
				Return -1
		End If			
		FOR kk = 1 to 5
			ldc_income[kk] = 0
		NEXT
		//2. REQPAY & dailypayment 에 Insert
		ll_cnt =  dw_daily.Retrieve(ls_approvalno)
		FOR jj =  1 to ll_cnt
			ls_itemcod 		= dw_daily.Object.ITEMCOD[jj]
			ls_paymethod 	= dw_daily.Object.PAYMETHOD[jj]
			ls_regcod 		= dw_daily.Object.REGCOD[jj] 
			ldc_payamt 		= dw_daily.Object.PAYAMT[jj] * -1
			ls_basecod 		= dw_daily.Object.BASECOD[jj]
			li_paycnt 		= dw_daily.Object.PAYCNT[jj]
			ls_payid			= dw_daily.Object.PAYID[jj]
			ls_trdt			= String(dw_daily.Object.trdt[jj] , 'yyyymmdd')
			//================================================================
			//DailyPayment 에 Insert
			//===============================================================
			Select seq_dailypayment.nextval	Into :ll_payseq  From dual;
			IF sqlca.sqlcode < 0 THEN
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
				RollBack ;
				Return -1 
			END IF
	
			insert into dailypayment
						( 	payseq,			paydt,			
							shopid,			operator,		customerid,
						  	itemcod,			paymethod,		regcod,			payamt,			basecod,
						  	paycnt,			payid,			remark,			trdt,				mark,
						  	auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  	MANUAL_YN,		PGM_ID )
			values 
					   ( 	:ll_payseq, 	:idt_shop_closedt, 	
							:GS_SHOPID, 	:GS_USER_ID, 	:is_payid,
						  	:ls_itemcod,	:ls_paymethod,	:ls_regcod,		:ldc_payamt,	:ls_basecod,
						  	:li_paycnt,		:is_payid,		:ls_remark,		:ldt_paydt,		null,
						  	NULL,				'C',				:ls_appseq,		sysdate,			sysdate,		:gs_user_id,
						  	'N',				'CANCEL' )	 ;
				   
			//		저장 실패 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, SQLCA.SQLErrText + " Insert Error(DAILYPAMENT)")
				RollBack;
				Return -1
			End If	
			
			Select seq_reqpay.nextval Into :lb_seq From dual;
			//수동 입금 반영 Table Insert
			//paymethod ==>trcode 로 변경..
			FOR kk = 1 to 5
				IF ls_method[kk]	=  ls_paymethod then
					ls_trcode 		=  ls_trcod[kk]
					ldc_income[kk] = ldc_income[kk] + ldc_payamt
					EXIT
				END IF
			NEXT
			ls_saletrcod = dw_daily.Object.trcod[jj] 
			
			Insert Into reqpay (
		       	seqno,		payid, 		paytype, 		trcod, 				paydt,
					trdt, 		remark, 		prc_yn, 			payamt, 				transdt,
					crt_user, 	crtdt,		pgm_id,			sale_trcod,			cancel_yn)
			values ( 
					:lb_seq, 	:is_payid, 	:ls_paymethod,	:ls_trcode, 		:ldt_paydt,
					:ld_reqdt,	:ls_trdt, 	'N', 				:ldc_payamt, 		sysdate,
					:gs_user_id, sysdate, 	:ls_pgm_id, 	:ls_saletrcod,		'Y' );

			If SQLCA.SQLCode < 0 Then
					Rollback ;
					f_msg_sql_err(Title, "Insert Error(REQPAY)")
					Return -1
			End If	
		NEXT		
		//FOR jj END..
		li_rc = wfi_call_proc(ls_call_payid)
		IF li_rc =  -1 then
			Rollback ;
//			f_msg_sql_err(Title, "B5REQPAY2DTL_PAYID_cancel")
			Return -1
		End If	
		
		//ShopCount Update
		Update partnermst		Set shopcount 	= :ll_shopcount	 
		 Where partner  = :GS_SHOPID ;
		//Update 실패 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, " Update  Error(PARTNERMST)")
			RollBack;
			Return -1
		End If			
		
		//================================================================
		//영수증 발행
		//================================================================
		//1. head 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
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
			FOR li_lp = 1 to dw_daily.RowCount()
				ldc_payamt 	= dw_daily.Object.payamt[li_lp] * -1
				ll_seq 		+= 1
				ls_temp 		= String(li_lp, '000') + ' ' //순번
				ls_itemcod 	= trim(dw_daily.Object.itemcod[li_lp])
				ls_itemnm 	= trim(dw_daily.Object.itemnm[li_lp])
				IF IsNull(ls_itemnm) then ls_itemnm 	= ""
					
				ldc_saleamt	= ldc_payamt
				ldc_total 	+= ldc_saleamt 
				ls_temp 		+= LeftA(ls_itemnm + space(24), 24) + ' '   //아이템
				li_cnt 		=  1
				ls_temp 		+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
				ls_val 		= fs_convert_amt(ldc_saleamt,  8)
				ls_temp 		+= ls_val //금액
				f_printpos(ls_temp)	
	
				ls_regcod =  trim(dw_daily.Object.regcod[li_lp])
				//regcode master read
				select keynum, 		trim(facnum)
			  	  INTO :ll_keynum,	:ls_facnum
			  	  FROM regcodmst
			 	 where regcod = :ls_regcod ;
	
				IF IsNull(ll_keynum) or sqlca.sqlcode < 0	then ll_keynum 	= 0
				IF IsNull(ls_facnum) or sqlca.sqlcode < 0	then ls_facnum 	= ""
				ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
				f_printpos(ls_temp)
			NEXT
	
			f_printpos(ls_lin1)
			ls_val 	= fs_convert_sign(ldc_total, 8)
			ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
			f_printpos(ls_temp)
			f_printpos(ls_lin1)
			//결제 수단별 금액 처리
			For li_lp = 1 To 5
				ldc_cash = ldc_income[li_lp]
				ls_code 	= ls_method[li_lp]
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
			ldc_change = 0
			ls_val 	= fs_convert_sign(ldc_change,  8)
			ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
			f_printpos(ls_temp)
			f_printpos(ls_lin1)
			F_POS_FOOTER(ls_memberid, ls_seq_app, gs_user_id)
		next 
		//--FOR jj END...
		//===================================
	END IF
NEXT
PRN_ClosePort()
commit;
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

return 0

end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)

idt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)
dw_cond.Object.paydt[1] =  idt_shop_closedt

dw_cond.SetColumn("seq_app")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_cancel_payment_SHOP
	Desc.	: 	수납취소-SHOP용
	Ver.	:	1.0
	Date	: 	2007.2.22
	Programer : Cho Kyung Bok [ 1hera ]
--------------------------------------------------------------------------*/

end event

event type integer ue_save();Integer 	li_return, 	li_rc, 		li_tmp
String 	ls_tmp
Date 		ld_tmp

dw_detail.AcceptText()
li_return = This.Trigger Event ue_extra_save()

Choose Case li_return
	Case Is <= -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_cust_db_app.is_title 		= This.Title
		iu_cust_db_app.is_caller 	= "ROLLBACK"
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then Return -1
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
	   f_msg_info(3000, This.Title, "Save")
		//초기화
		dw_cond.object.paydt[1] 	= f_find_shop_closedt(GS_SHOPID)
		dw_cond.object.remark[1] 	= ''
		This.TriggerEvent("ue_ok")
		p_ok.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		TriggerEvent("ue_ok")

End Choose

return 0

end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_cancel_payment_shop
integer x = 37
integer width = 2464
integer height = 280
string dataobject = "ssrt_cnd_cancel_payment_shop"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;String ls_customerid, ls_customernm, ls_memberid, &
		 ls_operator
Integer	li_cnt

Choose Case dwo.name
	Case "payid"
		ls_customerid = trim(data)
		select memberid, 		customernm
		  INTO :ls_memberid, :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_memberid) 	OR sqlca.sqlcode <> 0 	then ls_memberid 		= ""
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.marknm[1] 	=  ''
			This.Object.payid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("payid")
			return 1
		ELSE
			This.Object.memberid[1] 	=  ls_memberid
			This.Object.marknm[1] 	=  ls_customernm
		END IF
	Case "memberid"
		ls_memberid = trim(data)
		select customerid, 		customernm
		  INTO :ls_customerid,	:ls_customernm
		  FROM customerm
		 where memberid = :ls_memberid ;
		 
		 IF IsNull(ls_customerid) then ls_customerid = ""
		 IF IsNull(ls_customernm) then ls_customernm = ""
		 
		This.Object.payid[1] =  ls_customerid
		This.Object.marknm[1] =  ls_customernm
End Choose

end event

event dw_cond::clicked;//string ls_selectcod
//
////분류선택을 선택하지 않고 category 컬럼을 클릭할 때 메세지!!
//Choose Case dwo.Name
//	Case "category"
//		ls_selectcod = This.Object.selectcod[row]
//		If IsNull(ls_selectcod) or ls_selectcod = "" Then
//			 f_msg_usr_err(9000, parent.Title, "분류선택을 먼저 선택하세요!")
//			 return -1
//		End If
////	Case "selectcod"
////		ls_selectcod = This.Object.selectcod[row]		
////		Choose Case ls_selectcod
////			Case "categoryA"         //소분류
////				Modify("category.dddw.DataColumn='categorya'")
////				Modify("category.dddw.DisplayColumn='categoryanm'")		
////			Case "categoryA"         //소분류
////				Modify("category.dddw.DataColumn='categorya'")
////				Modify("category.dddw.DisplayColumn='categoryanm'")		
////			Case "categoryA"         //소분류
////				Modify("category.dddw.DataColumn='categorya'")
////				Modify("category.dddw.DisplayColumn='categoryanm'")		
////		End Choose				
//End Choose
//
//
//

end event

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.payid
This.is_data[1] 			= "CloseWithReturn"
dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "payid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.memberid[1] 	= dw_cond.iu_cust_help.is_data[4]
			 dw_cond.Object.payid[1] 		= dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.marknm[1] 		= dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemerror;call super::itemerror;return 1
end event

event dw_cond::losefocus;call super::losefocus;this.Accepttext()
end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_cancel_payment_shop
integer x = 2555
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_cancel_payment_shop
integer x = 2857
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_cancel_payment_shop
integer x = 23
integer width = 2505
integer height = 356
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_cancel_payment_shop
boolean visible = false
integer x = 315
integer y = 1616
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_cancel_payment_shop
boolean visible = false
integer x = 23
integer y = 1616
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_cancel_payment_shop
integer x = 608
integer y = 1616
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_cancel_payment_shop
integer x = 23
integer y = 372
integer width = 3685
integer height = 1204
string dataobject = "ssrt_reg_cancel_payment_sum_shop"
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_category_a
//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
End If



end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_category_b, ls_category_c, ls_oneoffcharger, ls_quota

//Choose Case dwo.Name
//	Case "itemmst_categorya"    //품목소분류 선택시 품목 중(대)분류 자동 뿌려줌!!
//		
//		SELECT categorya.categoryb, categoryb.categoryc 
//		INTO :ls_category_b, :ls_category_c
//		FROM categorya, categoryb
//		WHERE categorya.categorya = :data
//		 AND categorya.categoryb = categoryb.categoryb;		
//		 
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(Title, " SELECT categoryc ")
//			Return
//		End If		
//		
//		This.Object.categorya_categoryb[row] = ls_category_b
//		This.Object.categoryb_categoryc[row] = ls_category_c
//		
//
//		
//End Choose
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_cancel_payment_shop
integer x = 1166
integer y = 1616
end type

type dw_daily from datawindow within ssrt_reg_cancel_payment_shop
boolean visible = false
integer x = 2606
integer y = 168
integer width = 576
integer height = 144
integer taborder = 11
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_reg_cancel_payment_daily"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

