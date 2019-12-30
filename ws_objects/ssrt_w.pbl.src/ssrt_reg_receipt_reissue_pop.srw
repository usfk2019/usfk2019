$PBExportHeader$ssrt_reg_receipt_reissue_pop.srw
$PBExportComments$영수증 입금[paymethod] 변경
forward
global type ssrt_reg_receipt_reissue_pop from w_a_reg_m
end type
type dw_detail2 from datawindow within ssrt_reg_receipt_reissue_pop
end type
type dw_seq from datawindow within ssrt_reg_receipt_reissue_pop
end type
type dw_itemlist from datawindow within ssrt_reg_receipt_reissue_pop
end type
end forward

global type ssrt_reg_receipt_reissue_pop from w_a_reg_m
integer width = 3397
integer height = 2104
boolean controlmenu = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = popup!
windowstate windowstate = normal!
event ue_search ( )
dw_detail2 dw_detail2
dw_seq dw_seq
dw_itemlist dw_itemlist
end type
global ssrt_reg_receipt_reissue_pop ssrt_reg_receipt_reissue_pop

type variables
String	is_customerid, &
is_customernm, &
is_appno, &
is_seq, &
is_reqdt, &
is_pgm_id, &
is_partner

Long	il_cnt, il_payseq
end variables

on ssrt_reg_receipt_reissue_pop.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_seq=create dw_seq
this.dw_itemlist=create dw_itemlist
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_seq
this.Control[iCurrent+3]=this.dw_itemlist
end on

on ssrt_reg_receipt_reissue_pop.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_seq)
destroy(this.dw_itemlist)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_receipt_reissue_pop
	Desc	: 	영수증 변경 처리 
	Ver.	:	1.0
	Date	: 	2007.7.18
	programer : 1hera
-------------------------------------------------------------------------*/
//Integer i
String  	ls_itemcod, 	ls_itemnm
Long		ll_row, 			ll, 			row
String 	ls_ref_desc, 	ls_temp, 	ls_reqdt, 	ls_regcod, 	ls_where
date 		ldt_paydt

dw_detail2.SetTransObject(sqlca)
//window 중앙에
f_center_window(this)

////Data 받아오기
//iu_cust_msg.is_grp_name = "Receipt Reissue"
//iu_cust_msg.is_data[1]  = ls_customerid
//iu_cust_msg.is_data[2]  = ls_customernm
//iu_cust_msg.is_data[3]  = ls_appno							//영수증번호
//iu_cust_msg.is_data[4]  = ls_seq               			//receiptmst.app_seq
//iu_cust_msg.is_data[5]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID


is_customerid  = iu_cust_msg.is_data[1]
is_customernm  = iu_cust_msg.is_data[2]
is_partner 		= iu_cust_msg.is_data[3]
is_seq			= iu_cust_msg.is_data[4]
is_pgm_id  		= iu_cust_msg.is_data[5]

//select payid into :is_payid from customerm
// where customerid = :is_customerid ;
// 

//ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
//If ls_temp 		= "" Then Return
//fi_cut_string(ls_temp, ";", is_method[])

dw_cond.object.customerid[1] 	= is_customerid
dw_cond.object.customernm[1] 	= is_customernm
dw_cond.object.appno[1]    	= is_seq


//영수증 번호가 같은 receiptmst 조회
il_cnt = dw_detail2.Retrieve(is_seq)

end event

event ue_ok();//Dec{6} ldc_basicamt, ldc_saleamt, ldc_beforeamt, ldc_deposit, ldc_receamt
//Long ll_row, ll_hwseq, ll_rows
//Integer li_rc, li_cnt
//Date ld_startdate
//String ls_cnt, ls_where, ls_gubun
//String ls_modelno, ls_serialno
//
//dw_cond.AcceptText()
//
//b1u_dbmgr9	lu_dbmgr
//lu_dbmgr = Create b1u_dbmgr9
//
////신규
//li_cnt = dw_cond.object.cnt[1]
//ls_cnt = String(li_cnt)
//
//For ll_rows = 1 To dw_detail2.RowCount()
//	ls_modelno = Trim(dw_detail2.object.modelno[ll_rows])
//	ls_serialno = Trim(dw_detail2.object.serialno[ll_rows])
//
//	If IsNull(ls_modelno) Then ls_modelno = ""
//	If IsNull(ls_serialno) Then ls_serialno = ""
//
//	//정보 다 입력
//	If ls_modelno = "" Then
//		f_msg_info(200, Title, "장비모델")
//		dw_detail2.SetFocus()
//		dw_detail2.ScrollToRow(ll_rows)
//		dw_detail2.SetColumn("modelno")
//		Return
//	End If
//	
//	If ls_serialno = "" Then
//		f_msg_info(200, Title, "Serial No")
//		dw_detail2.SetFocus()
//		dw_detail2.ScrollToRow(ll_rows)
//		dw_detail2.SetColumn("serialno")
//		Return
//	End If
//	
//	//올바른 Serial No. 인지 확인
//	If ls_serialno <> "" Then
//		ll_hwseq = dw_detail2.object.adseq[ll_rows]
//		If IsNull(ll_hwseq) Then
//			f_msg_usr_err(201, Title, "Serial No")
//			dw_detail2.SetFocus()
//			dw_detail2.ScrollToRow(ll_rows)
//			dw_detail2.SetColumn("serialno")
//			Return
//		End If
//		
////		//장비SEQ chekc
////		SELECT adseq
////		  INTO :ll_ad
////		  FROM admst
////		 WHERE serialno = :ls_serialno;
////		 
////		If SQLCA.SQLCode < 0 Then
////			f_msg_usr_err(9000, Title, "admst select error')
////			Return
////		End If
////		If ll_hwseq <> ll_ad Then
////			dw_detail2.object.adseq[ll_rows] = ll_ad
////		End If
//	End If
//Next
//
//If IsNull(ls_cnt) Then ls_cnt = ""
//
////장비 할부 개월수 필수
//If ls_cnt = "" Then
//	f_msg_info(200, Title, "할부개월수")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("cnt")
//	Return
//End If
//
////금액 Check
//ldc_basicamt  = dw_cond.object.basicamt[1]
//ldc_beforeamt = dw_cond.object.beforeamt[1]
//ldc_saleamt   = dw_cond.object.saleamt[1]
//ldc_deposit   = dw_cond.object.deposit[1]
//ls_gubun      = Trim(dw_cond.object.gubun[1])
//ldc_receamt   = 0
//	
//If ls_gubun = "Y" Then
//	ldc_receamt = ldc_beforeamt
//	dw_cond.object.receamt[1] = ldc_receamt
//		
//	ldc_saleamt = (ldc_basicamt - ldc_beforeamt) + ldc_deposit
//	If ldc_saleamt <> 0 Then
//		dw_cond.object.saleamt[1] = ldc_saleamt
//	End If
//Else
//	ldc_receamt = ldc_beforeamt + ldc_deposit
//	dw_cond.object.receamt[1] = ldc_receamt
//		
//	ldc_saleamt = ldc_basicamt - ldc_beforeamt
//	If ldc_saleamt <> 0 Then
//		dw_cond.object.saleamt[1] = ldc_saleamt
//	End If
//End If
//
//If li_cnt > 0 Then
//
//	//할부 개월수 계산
//	lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop_2%insert"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.ii_data[1] = li_cnt
//	//lu_dbmgr.id_data[1] = ld_startdate
//	lu_dbmgr.is_data[1] = is_customerid
//	lu_dbmgr.is_data[2] = is_main_itemcod
//	lu_dbmgr.is_data[3] = is_orderno
//	lu_dbmgr.is_data[4] = gs_user_id
//	lu_dbmgr.is_data[5] = is_pgmid
//	//lu_dbmgr.is_data[6] = ls_startdate
//	lu_dbmgr.ic_data[1] = ldc_saleamt   //총판매금액
//	lu_dbmgr.idw_data[1] = dw_detail
//	lu_dbmgr.uf_prc_db_02()
//	li_rc = lu_dbmgr.ii_rc
//	If li_rc < 0 Then
//		Destroy lu_dbmgr
//		dw_cond.SetColumn("beforeamt")
//		Return
//	End If
//End If
//
//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//dw_cond.Enabled = False
//p_ok.TriggerEvent("ue_disable")
//Destroy lu_dbmgr
//
//Return 
end event

event type integer ue_extra_save();date		ldt_paydt, 		ldt_trdt,		ldt_transdt		
String	ls_partner,		ls_operator, 	ls_customerid, ls_itemcod, &
			ls_paymethod,	ls_regcod, 	ls_basecod, 	ls_payid, &		
			ls_dctype, 		ls_remark, 		ls_mark, 	ls_autochk, &
			ls_appno,		ls_payseq, &
			ls_paytype,		ls_trcod,		ls_prc_yn,	ls_sale_trcod, &
			ls_memberid,	ls_bf_paymethod

Dec{2}	ldc_payamt,		ldc_saleamt	
Long		ll,				ll_paycnt,		ll_payseq, 	ll_salecnt,		ll_new_seq
dec		ldc_orderno,	ldc_contractseq
boolean	lb_reqpay


FOR ll = 1 to il_cnt
	lb_reqpay =  False
	//======================================================================
	// 1. 취소분에대한 (-) 자료 dailypayment에 Insert
	//======================================================================
	ldt_paydt		= dw_detail2.Object.paydt[ll]
	ldt_trdt			= dw_detail2.Object.trdt[ll]

	ll_payseq		= dw_detail2.Object.payseq[ll]
	ls_partner		= dw_detail2.Object.shopid[ll]
	ls_operator		= dw_detail2.Object.operator[ll]
	ls_customerid	= dw_detail2.Object.customerid[ll]
	ls_itemcod		= dw_detail2.Object.itemcod[ll]
	ls_paymethod	= dw_detail2.Object.after_method[ll]
	ls_bf_paymethod	= dw_detail2.Object.paymethod[ll]
	ls_regcod		= dw_detail2.Object.regcod[ll]
	
	ldc_saleamt		= dw_detail2.Object.payamt[ll]
	ll_salecnt		= dw_detail2.Object.paycnt[ll]
	
	ldc_payamt		= dw_detail2.Object.payamt[ll] * -1
	ll_paycnt		= dw_detail2.Object.paycnt[ll] * -1
	
	ls_basecod		= dw_detail2.Object.basecod[ll]
	ls_payid			= dw_detail2.Object.payid[ll]
	ls_dctype		= dw_detail2.Object.dctype[ll]
	ls_remark		= dw_detail2.Object.remark[ll]
	ls_mark			= dw_detail2.Object.mark[ll]
	ls_autochk		= dw_detail2.Object.auto_chk[ll]
	ls_appno			= dw_detail2.Object.approvalno[ll]
	insert into dailypayment
				( payseq,		
				  paydt,			shopid,			operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user)
	values 
			   ( seq_dailypayment.nextval, 	
				  :ldt_paydt, 	:ls_partner, 	:ls_operator, 	:ls_customerid,
				  :ls_itemcod,	:ls_bf_paymethod,	:ls_regcod,		:ldc_payamt,	:ls_basecod,
				  :ll_paycnt,	:ls_payid,		:ls_remark,		:ldt_trdt,		:ls_mark,
				  :ls_autochk,	:ls_dctype,		:ls_appno,		sysdate,			sysdate,		:gs_user_id )	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
			Return -1
	End If		
	//======================================================================
	// 2.  변경자료 dailypayment에 Insert
	//======================================================================
	Select seq_dailypayment.nextval		  Into :ll_new_seq  From dual;
	IF sqlca.sqlcode < 0 THEN
					RollBack;
					f_msg_sql_err(title, SQLCA.SQLErrText+ " Sequence Error(seq_dailypayment)")
					Return -1
	END IF

	insert into dailypayment
		( payseq,		paydt,			shopid,			operator,		customerid,
		  itemcod,		paymethod,		regcod,			payamt,			basecod,
		  paycnt,		payid,			remark,			trdt,				mark,
		  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user)
	values 
	   ( :ll_new_seq, :ldt_paydt, 	:ls_partner, 	:ls_operator, 	:ls_customerid,
		  :ls_itemcod,	:ls_paymethod,	:ls_regcod,		:ldc_saleamt,	:ls_basecod,
		  :ll_salecnt,	:ls_payid,		:ls_remark,		:ldt_trdt,		:ls_mark,
		  :ls_autochk,	:ls_dctype,		:ls_appno,		sysdate,			sysdate,		:gs_user_id )	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(Title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT) - Issue")
			Return -1
	End If
	
	//======================================================================
	// 3. 취소분에대한 (-) 자료 reqpay 에 Insert
	//======================================================================
	 SELECT 	PAYID, 			PAYTYPE,			TRCOD,  		PAYDT,  		TRDT, 
	 			TRANSDT,  		ORDERNO,   		CONTRACTSEQ, 
				REMARK, 			PRC_YN, 			SALE_TRCOD
		INTO 	:ls_payid, 		:ls_paytype, 	:ls_trcod, 	:ldt_paydt, :ldt_trdt, 
				:ldt_transdt,	:ldc_orderno,	:ldc_contractseq, 
				:ls_remark, 	:ls_prc_yn, 	:ls_sale_trcod
    FROM REQPAY  
   WHERE PAYSEQ = :ll_payseq               ;
	//조회 실패 
	If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Select Error(REQPAY)")
			Return -1
		ELSEIF sqlca.sqlcode = 0 THEN
			lb_reqpay = True
	End If
	IF lb_reqpay THEN
		insert into REQPAY
				(SEQNO,
				 PAYID,				PAYTYPE,		TRCOD,				PAYDT,
				 PAYAMT,				TRDT,			TRANSDT,				ORDERNO,			CONTRACTSEQ,
				 REMARK,				PRC_YN,		
				 CRT_USER,			UPDT_USER,	CRTDT,				UPDTDT,			PGM_ID,
				 SALE_TRCOD,		PAYSEQ )    
 		values 
			   ( seq_reqpay.nextval, 	
				  :ls_payid, 		:ls_paytype, 	:ls_trcod, 		:ldt_paydt, 
				  :ldc_payamt, 	:ldt_trdt, 		:ldt_transdt,	:ldc_orderno,	:ldc_contractseq, 
				  :ls_remark, 		:ls_prc_yn,
				  :gs_user_id,		:gs_user_id,	sysdate,			sysdate,
				  :ls_sale_trcod, :ll_payseq 
				  )	 ;
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(REQPAY) - Old")
			Return -1
		End If
	END IF
	//======================================================================
	//4. 신규수정분 reqpay  Insert
	//======================================================================
	IF lb_reqpay then
		insert into REQPAY
				(SEQNO,
				 PAYID,				PAYTYPE,		TRCOD,				PAYDT,
				 PAYAMT,				TRDT,			TRANSDT,				ORDERNO,			CONTRACTSEQ,
				 REMARK,				PRC_YN,		
				 CRT_USER,			UPDT_USER,	CRTDT,				UPDTDT,			PGM_ID,
				 SALE_TRCOD,		PAYSEQ )    
 		values 
			   ( seq_reqpay.nextval, 	
				  :ls_payid, 		:ls_paytype, 	:ls_trcod, 		:ldt_paydt, 
				  :ldc_saleamt, 	:ldt_trdt, 		:ldt_transdt,	:ldc_orderno,	:ldc_contractseq, 
				  :ls_remark, 		:ls_prc_yn,
				  :gs_user_id,		:gs_user_id,	sysdate,			sysdate,
				  :ls_sale_trcod, :ll_new_seq 
				  )	 ;
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(REQPAY) -New")
			Return -1
		End If
		
	END IF
NEXT

COMMIT ;
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail2.AcceptText() < 0 Then
	dw_detail2.SetFocus()
	Return LI_ERROR
End If

li_return = Trigger Event ue_extra_save()
If li_return = -2  Then
	dw_detail.SetFocus()
	Return LI_ERROR
ElseIf li_return = -3 Then
	
	Trigger Event ue_reset()
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
		
	End If

f_msg_info(3000,This.Title,"Save")

Return 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail2.AcceptText()
//
If (dw_detail2.ModifiedCount() > 0) Or (dw_detail2.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If
Return 0
end event

event resize;call super::resize;//
//If newwidth < dw_detail2.X  Then
//	dw_detail2.Width = 0
//Else
//	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
//End If
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_receipt_reissue_pop
integer y = 88
integer width = 1723
integer height = 304
boolean enabled = false
string dataobject = "ssrt_cnd_reg_receipt_reissue_pop"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt_reg_receipt_reissue_pop
integer x = 1847
integer y = 96
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_receipt_reissue_pop
integer x = 2158
integer y = 96
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer y = 40
integer width = 1746
integer height = 384
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer x = 1010
integer y = 1884
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer x = 709
integer y = 1884
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_receipt_reissue_pop
integer x = 50
integer y = 1884
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer x = 23
integer y = 1824
integer width = 3342
integer height = 64
boolean enabled = false
string dataobject = "b1dw_reg_quotainfo_pop1_cl"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;//Setting
Long ll_row, i
ll_row = dw_detail.RowCount()
//임대여서 자료 없을때
If ll_row = 0 Then 
	dw_cond.object.cnt[1] = 1
	Return 0
End If

dw_cond.object.cnt[1] = ll_row
For i = 1 To ll_row
	dw_detail.object.amt[i] = dw_detail.object.sale_amt[i]
Next
If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_receipt_reissue_pop
integer x = 352
integer y = 1884
boolean enabled = true
end type

type dw_detail2 from datawindow within ssrt_reg_receipt_reissue_pop
integer x = 32
integer y = 440
integer width = 3269
integer height = 1360
integer taborder = 11
string title = "none"
string dataobject = "ssrt_reg_receipt_reissue_pop"
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type dw_seq from datawindow within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer x = 1833
integer y = 212
integer width = 571
integer height = 104
integer taborder = 11
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_seq_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_itemlist from datawindow within ssrt_reg_receipt_reissue_pop
boolean visible = false
integer x = 1833
integer y = 316
integer width = 571
integer height = 104
integer taborder = 21
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_item_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

