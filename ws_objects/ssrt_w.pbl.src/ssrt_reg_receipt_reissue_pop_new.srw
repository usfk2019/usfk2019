$PBExportHeader$ssrt_reg_receipt_reissue_pop_new.srw
forward
global type ssrt_reg_receipt_reissue_pop_new from window
end type
type dw_itemlist from datawindow within ssrt_reg_receipt_reissue_pop_new
end type
type dw_seq from datawindow within ssrt_reg_receipt_reissue_pop_new
end type
type p_2 from u_p_save within ssrt_reg_receipt_reissue_pop_new
end type
type p_1 from u_p_close within ssrt_reg_receipt_reissue_pop_new
end type
type dw_detail2 from datawindow within ssrt_reg_receipt_reissue_pop_new
end type
type dw_cond from datawindow within ssrt_reg_receipt_reissue_pop_new
end type
end forward

global type ssrt_reg_receipt_reissue_pop_new from window
integer width = 3383
integer height = 1672
boolean titlebar = true
string title = "Untitled"
boolean minbox = true
windowtype windowtype = popup!
long backcolor = 29478337
event ue_close ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
dw_itemlist dw_itemlist
dw_seq dw_seq
p_2 p_2
p_1 p_1
dw_detail2 dw_detail2
dw_cond dw_cond
end type
global ssrt_reg_receipt_reissue_pop_new ssrt_reg_receipt_reissue_pop_new

type variables

u_cust_a_msg iu_cust_msg

String	is_customerid, &
is_customernm, &
is_appno, &
is_seq, &
is_reqdt, &
is_pgm_id, &
is_partner

Long	il_cnt, il_payseq
end variables

event ue_close();Close(This)
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
	dw_detail2.SetFocus()
	Return LI_ERROR
ElseIf li_return = -3 Then
	Return LI_ERROR
End If

f_msg_info(3000,This.Title,"Save")
return 0
end event

event ue_extra_save;date		ldt_paydt, 		ldt_trdt,		ldt_transdt		
String	ls_partner,		ls_operator, 	ls_customerid, ls_itemcod, &
			ls_paymethod,	ls_regcod, 	ls_basecod, 	ls_payid, &		
			ls_dctype, 		ls_remark, 		ls_mark, 	ls_autochk, &
			ls_appno,		ls_payseq, &
			ls_paytype,		ls_trcod,		ls_prc_yn,	ls_sale_trcod, &
			ls_memberid,	ls_bf_paymethod,				ls_manual_yn, ls_orderno

Dec{2}	ldc_payamt,		ldc_saleamt	
Long		ll,				ll_paycnt,		ll_payseq, 	ll_salecnt,		ll_new_seq
dec		ldc_orderno,	ldc_contractseq
boolean	lb_reqpay


FOR ll = 1 to il_cnt
	lb_reqpay =  False
	//======================================================================
	// 1. 취소분에대한 (-) 자료 dailypayment에 Insert
	//======================================================================
	ldt_paydt		= date(dw_detail2.Object.paydt[ll])
	ldt_trdt			= date(dw_detail2.Object.trdt[ll])

	ll_payseq		= dw_detail2.Object.payseq[ll]
	ls_partner		= dw_detail2.Object.shopid[ll]
	ls_operator		= dw_detail2.Object.operator[ll]
	ls_customerid	= dw_detail2.Object.customerid[ll]
	ls_itemcod		= dw_detail2.Object.itemcod[ll]
	ls_paymethod	= dw_detail2.Object.after_method[ll]
	
	//2013-06-13 BY HMK
	//dailypayment에 insert시 orderno도 들어가도록 처리
	//아래 insert문에서 사용
	ls_orderno		= string(dw_detail2.Object.orderno[ll])
	//
	
	IF IsNull(ls_paymethod) then ls_paymethod = ''
	IF ls_paymethod = '' then
		f_msg_usr_err(9000, Title, "After Paymethod ==> Not Input ")
		dw_detail2.SetFocus()
		return -1
	END IF
	
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
	ls_manual_yn	= dw_detail2.Object.manual_yn[ll]
	insert into dailypayment
				( payseq,		
				  paydt,			shopid,			operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
				  manual_yn,	PGM_ID, orderno	)
	values 
			   ( seq_dailypayment.nextval, 	
				  :ldt_paydt, 	:ls_partner, 	:ls_operator, 	:ls_customerid,
				  :ls_itemcod,	:ls_bf_paymethod,	:ls_regcod,		:ldc_payamt,	:ls_basecod,
				  :ll_paycnt,	:ls_payid,		:ls_remark,		:ldt_trdt,		:ls_mark,
				  :ls_autochk,	:ls_dctype,		:ls_appno,		sysdate,			sysdate,		:gs_user_id,
				  :ls_manual_yn, 'REISSUE', :ls_orderno )	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
			RollBack;
			Return -1
	End If		
	//======================================================================
	// 2.  변경자료 dailypayment에 Insert
	//======================================================================
	Select seq_dailypayment.nextval		  Into :ll_new_seq  From dual;
	IF sqlca.sqlcode < 0 THEN
					f_msg_sql_err(title, SQLCA.SQLErrText+ " Sequence Error(seq_dailypayment)")
					RollBack;
					Return -1
	END IF

	insert into dailypayment
		( payseq,		paydt,			shopid,			operator,		customerid,
		  itemcod,		paymethod,		regcod,			payamt,			basecod,
		  paycnt,		payid,			remark,			trdt,				mark,
		  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
		  manual_yn,	PGM_ID , orderno)
	values 
	   ( :ll_new_seq, :ldt_paydt, 	:ls_partner, 	:ls_operator, 	:ls_customerid,
		  :ls_itemcod,	:ls_paymethod,	:ls_regcod,		:ldc_saleamt,	:ls_basecod,
		  :ll_salecnt,	:ls_payid,		:ls_remark,		:ldt_trdt,		:ls_mark,
		  :ls_autochk,	:ls_dctype,		:ls_appno,		sysdate,			sysdate,		:gs_user_id ,
		  :ls_manual_yn, 'REISSUE' , :ls_orderno)	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT) - Issue")
			RollBack;
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
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Select Error(REQPAY)")
			RollBack;
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
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(REQPAY) - Old")
			RollBack;
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
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(REQPAY) -New")
			RollBack;
			Return -1
		End If
		
	END IF
NEXT

COMMIT ;
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
Return 0
end event

event open;iu_cust_msg = Create u_cust_a_msg
iu_cust_msg = Message.PowerObjectParm

/*------------------------------------------------------------------------
	Name	:	ssrt_reg_receipt_reissue_pop
	Desc	: 	영수증 변경 처리 
	Ver.	:	1.0
	Date	: 	2007.7.18
	programer : 1hera
-------------------------------------------------------------------------*/
//Integer i
String  	ls_itemcod, 	ls_itemnm
Long		ll_row, 			ll, 			row
String 	ls_ref_desc, 	ls_temp, 	ls_reqdt, 	ls_regcod, 	ls_where, ls_method
date 		ldt_paydt

dw_cond.SetTransObject(sqlca)
dw_detail2.SetTransObject(sqlca)
//window 중앙에
f_center_window(this)
This.Title =  iu_cust_msg.is_pgm_name 


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
IF il_cnt > 0 then
	FOR ll = 1 to il_cnt
		ls_method =  trim(dw_detail2.Object.paymethod[ll])
		dw_detail2.Object.after_method[ll] =  ls_method
	NEXT
END IF



end event

on ssrt_reg_receipt_reissue_pop_new.create
this.dw_itemlist=create dw_itemlist
this.dw_seq=create dw_seq
this.p_2=create p_2
this.p_1=create p_1
this.dw_detail2=create dw_detail2
this.dw_cond=create dw_cond
this.Control[]={this.dw_itemlist,&
this.dw_seq,&
this.p_2,&
this.p_1,&
this.dw_detail2,&
this.dw_cond}
end on

on ssrt_reg_receipt_reissue_pop_new.destroy
destroy(this.dw_itemlist)
destroy(this.dw_seq)
destroy(this.p_2)
destroy(this.p_1)
destroy(this.dw_detail2)
destroy(this.dw_cond)
end on

event close;Destroy iu_cust_msg 
end event

type dw_itemlist from datawindow within ssrt_reg_receipt_reissue_pop_new
boolean visible = false
integer x = 2702
integer y = 224
integer width = 434
integer height = 104
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_item_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_seq from datawindow within ssrt_reg_receipt_reissue_pop_new
boolean visible = false
integer x = 2226
integer y = 228
integer width = 430
integer height = 104
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_seq_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type p_2 from u_p_save within ssrt_reg_receipt_reissue_pop_new
integer x = 2240
integer y = 100
end type

type p_1 from u_p_close within ssrt_reg_receipt_reissue_pop_new
integer x = 2560
integer y = 96
end type

type dw_detail2 from datawindow within ssrt_reg_receipt_reissue_pop_new
integer x = 18
integer y = 384
integer width = 3305
integer height = 1252
integer taborder = 20
string title = "none"
string dataobject = "ssrt_reg_receipt_reissue_pop"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
end event

event losefocus;AcceptText()
end event

type dw_cond from datawindow within ssrt_reg_receipt_reissue_pop_new
integer x = 23
integer width = 2089
integer height = 376
integer taborder = 10
string title = "none"
string dataobject = "ssrt_cnd_reg_receipt_reissue_pop"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
end event

