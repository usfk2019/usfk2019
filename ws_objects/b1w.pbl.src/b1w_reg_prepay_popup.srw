$PBExportHeader$b1w_reg_prepay_popup.srw
$PBExportComments$[kem] 선수금 처리
forward
global type b1w_reg_prepay_popup from w_base
end type
type dw_item from datawindow within b1w_reg_prepay_popup
end type
type dw_cond from u_d_external within b1w_reg_prepay_popup
end type
type p_close from u_p_close within b1w_reg_prepay_popup
end type
type p_save from u_p_save within b1w_reg_prepay_popup
end type
end forward

global type b1w_reg_prepay_popup from w_base
integer width = 2834
integer height = 880
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_save ( )
event ue_close ( )
dw_item dw_item
dw_cond dw_cond
p_close p_close
p_save p_save
end type
global b1w_reg_prepay_popup b1w_reg_prepay_popup

type variables
String 	is_customerid, 	is_orderno, 	is_contractseq, is_pgm_id,&
			is_memberid, 		is_priceplan
Boolean ib_order
end variables

forward prototypes
public function integer wf_reqpay_save ()
end prototypes

event ue_save();String ls_paytype, ls_paydt, ls_trcod, ls_paymethod, ls_priceplan
Dec ldc_payamt
Long   ll_ret

dw_cond.AcceptText()

ldc_payamt 		= dw_cond.Object.payamt[1]
ls_paytype 		= Trim(dw_cond.Object.paytype[1])
ls_paydt   		= String(dw_cond.Object.paydt[1],'yyyymmdd')
ls_trcod   		= Trim(dw_cond.Object.trcod[1])
ls_paymethod 	= Trim(dw_cond.Object.paymethod[1])

If IsNull(ls_paytype) 		Then ls_paytype 		= ""
If IsNull(ls_paydt) 			Then ls_paydt 			= ""
If IsNull(ls_trcod) 			Then ls_trcod 			= ""
If IsNull(ls_paymethod) 	Then ls_paymethod 	= ""


If ldc_payamt > 0 Then
	If ls_paytype = "" Then
		f_msg_info(200, Title, "납부방법")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paytype")
		Return 
	End If
   If ls_paydt = "" Then
		f_msg_info(200, Title, "납부일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paydt")
		Return 
	End If
	If ls_trcod = "" Then
		f_msg_info(200, Title, "거래유형")
		dw_cond.SetFocus()
		dw_cond.SetColumn("trcod")
		Return 
	End If
	
	If ls_paymethod = "" Then
		f_msg_info(200, Title, "Paymethod")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paymethod")
		Return 
	End If
	
	
	ll_ret = wf_reqpay_save()
	
	If ll_ret = -1 Then
		//ROLLBACK와 동일한 기능
		ROLLBACK;		
		f_msg_info(3010, This.Title, "선수금등록")
		Return
	ElseIf ll_ret = 0 Then
		//COMMIT와 동일한 기능
		COMMIT;
		f_msg_info(3000, This.Title, "선수금등록")
	End if

	//저장한거로 인식하게 함.
	dw_cond.SetitemStatus(1, 0, Primary!, NotModified!)

Else
	f_msg_info(9000, Title, '선수금 납부내역이 없습니다.')
	Return
End If

p_save.TriggerEvent("ue_disable")		//버튼 비활성화

dw_cond.enabled = False

Close(This)
Return
	
end event

event ue_close();
Close(This)
end event

public function integer wf_reqpay_save ();//reqpay Table Save
String 	ls_payid, 		ls_orderno, 		ls_contractseq,	ls_paytype,&
			ls_trcod,		ls_remark,			ls_pgm_id, 			ls_memberid,&
			ls_paymethod,	ls_pricecode,		ls_ref_desc
Dec    	ldc_payamt,		ldec_charge,		ldec_remain, &
			ldec_saleamt
Long   	ll_orderno, 	ll_contractseq, 	ll_row, ll, ll_rowcount
Date   	ld_paydt,		ldt_shop_closedt

datawindow ldw_data
String 	ls_basecod,		ls_regcod,		ls_appseq
Long		ll_shopcount,	ll_payseq,		jj, i, &
			ll_keynum
String 	ls_itemcod, 	ls_chk,			ls_temp,		ls_itemnm, ls_val, &
			ls_facnum
Integer 	li_rtn

ls_paymethod   = Trim(dw_cond.Object.paymethod[1])
ls_memberid    = Trim(dw_cond.Object.memberid[1])
ls_payid       = Trim(dw_cond.Object.payid[1])
ll_orderno     = Long(dw_cond.Object.orderno[1])
ll_contractseq = Long(dw_cond.Object.contractseq[1])
ldc_payamt     = dw_cond.Object.payamt[1]
ld_paydt       = dw_cond.Object.paydt[1]
ls_paytype     = Trim(dw_cond.Object.paytype[1])
ls_trcod       = Trim(dw_cond.Object.trcod[1])
ls_remark      = dw_cond.Object.remark[1]
ls_pgm_id      = gs_pgm_id[gi_open_win_no]

ldt_shop_closedt =  f_find_shop_closedt(GS_SHOPID)


INSERT INTO REQPAY ( seqno, 		payid, 		paytype, 		trcod,
                     paydt, 		payamt, 		remark, 			prc_yn,
							crt_user, 	updt_user, 	crtdt, 			updtdt,
							pgm_id, 		orderno, 	contractseq, 	transdt)
				VALUES ( seq_reqpay.nextval, :ls_payid, :ls_paytype, :ls_trcod,
				         :ld_paydt, 	:ldc_payamt, :ls_remark, 	'N',
							:gs_user_id,:gs_user_id, sysdate, 		sysdate,
							:ls_pgm_id, :ll_orderno, :ll_contractseq, :ld_paydt);
						
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "REQPAY TABLE INSERT Error")
	Return -1
End If
//-----------------------POS관련 처리 부분임.....
//음성외 기타
ls_pricecode = fs_get_control("B0", "P100", ls_ref_desc)

ldw_data 		= iu_cust_msg.idw_data[1]
ll_rowcount 	= ldw_data.RowCount()
ldw_data.SetSort("itemmst_pricetable A, itemmst_priority A")
ldw_data.Sort( )

IF ll_rowcount = 0 THEN	return 0

//customerm Search
select basecod, payid INTO :ls_basecod, :ls_payid  from customerm
 where customerid 	=  :is_customerid ;
		
IF IsNull(ls_basecod)  OR sqlca.sqlcode <> 0 THEN ls_basecod 	= ""
IF IsNull(ls_regcod)   OR sqlca.sqlcode <> 0 THEN ls_regcod 	= ""
		
//1.receiptMST Insert
//SEQ 
Select seq_app.nextval		  Into :ls_appseq						  From dual;
If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Sequence Error(seq_app)")
		RollBack;
		Return  -1
End If			

//SHOP COUNT
Select shopcount	    Into :ll_shopcount	  From partnermst
 WHERE partner = :GS_SHOPID ;
		
IF IsNull(ll_shopcount)  THEN ll_shopcount = 0
IF sqlca.sqlcode <> 0 THEN
	RollBack;
	f_msg_sql_err(title, " Update Error(partnermst)")
	Return -1
END IF
ll_shopcount += 1

INSERT INTO RECEIPTMST ( APPROVALNO,
		SHOPCOUNT,  		RECEIPTTYPE,			SHOPID,     		POSNO,      
		WORKDT,     		TRDT,       			MEMBERID,   		OPERATOR,   		TOTAL,      
		CASH,       		CHANGE,     			SEQ_APP,    		CUSTOMERID, 		PRT_YN   
		)
values 
   ( 	seq_receipt.nextval,
	  	:ll_shopcount,		'100', 					:GS_SHOPID, 		NULL,
	  	:ld_paydt,			:ldt_shop_closedt,	:ls_memberid,		:GS_user_ID,		:ldc_payamt,
	  	:ldc_payamt,		0,							:ls_appseq,			:is_customerid, 	'Y' )	 ;
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

		
ldec_remain	= ldc_payamt	
JMP00:
FOR ll =  1 to ll_rowcount
IF ldec_remain > 0 THEN	
	//우선순위1. 음성외기타 - priority 2.음성 - priority.
	ls_itemcod 	= trim(ldw_data.Object.itemcod[ll])
	ls_chk	 	= trim(ldw_data.Object.chk[ll])
	IF ls_chk = 'Y' then
		//priceplan_rate2.unitcharge 
		SELECT unitcharge INTO :ldec_charge FROM priceplan_rate2
		 WHERE PRICEPLAN = :is_priceplan
		   AND ITEMCOD	  = :ls_itemcod ;
		
		IF IsNull(ldec_charge) OR sqlca.sqlcode <> 0 THEN ldec_charge = 0
		
		IF ldec_charge > 0 then
			//b. dailypayment Insert
			// regcod search
			IF ldec_remain > 0 THEN
				IF ldec_remain >= ldec_charge THEN
					ldec_remain =  ldec_remain - ldec_charge
				ELSE
					ldec_charge	= ldec_remain
					ldec_remain = 0
				END IF
			END IF
			
			select regcod INTO :ls_regcod FROM ITEMMST
			 WHERE itemcod = :ls_itemcod ;
			
			IF sqlca.sqlcode <> 0 OR IsNUll(ls_regcod) then ls_regcod = ""
			Select seq_dailypayment.nextval		  Into :ll_payseq  From dual;
			IF sqlca.sqlcode < 0 THEN
				RollBack;
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
				Return -1
			END IF

			insert into dailypayment
				( payseq,		paydt,			shopid,			operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
				  MANUAL_YN		)
			values 
			   ( :ll_payseq, 	:ldt_shop_closedt,:GS_SHOPID,	:GS_USER_ID, 	:is_customerid,
				  :ls_itemcod,	:ls_paymethod,	:ls_regcod,		:ldec_charge,	:ls_basecod,
				  1,				:is_customerid, NULL,			:ld_paydt,		NULL,
				  NULL,			'D',				:ls_appseq,		sysdate,			sysdate,		:gs_user_id,
				  'N'	)	 ;
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				f_msg_sql_err(title,SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
				Return -1
			End If				
			ll_row = dw_item.InsertRow(0)
			dw_item.Object.payseq[ll_row] 		= ll_payseq
			dw_item.Object.paydt[ll_row] 			= ld_paydt
			dw_item.Object.shopid[ll_row]	 		= GS_SHOPID
			dw_item.Object.operator[ll_row] 		= GS_USER_ID
			dw_item.Object.customerid[ll_row] 	= is_customerid
			dw_item.Object.itemcod[ll_row] 		= ls_itemcod
			dw_item.Object.paymethod[ll_row] 	= ls_paymethod
			dw_item.Object.regcod[ll_row] 		= ls_regcod
			dw_item.Object.payamt[ll_row] 		= ldec_charge
			dw_item.Object.basecod[ll_row] 		= ls_basecod
			dw_item.Object.paycnt[ll_row] 		= 1
			dw_item.Object.payid[ll_row] 			= is_customerid
			dw_item.Object.dctype[ll_row]	 		= 'D'
			dw_item.Object.approvalno[ll_row] 	= ls_appseq
		END IF
	END IF
END IF
IF ldec_remain = 0 THEN EXIT
NEXT
IF ldec_remain > 0 THEN GOTO JMP00

//마지막으로 영수증 출력........
String ls_lin1, ls_lin2, ls_lin3
String ls_empnm
DEC	 ldc_shopCount

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
FOR jj = 1  to 2
	IF jj = 1 then 
		li_rtn = f_pos_header(GS_SHOPID,  'A', ll_shopcount, 1 )
	ELSE 
		li_rtn = f_pos_header(GS_SHOPID,  'Z', ll_shopcount, 0 )
	END IF
	IF li_rtn < 0 then
		MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
		PRN_ClosePort()
		return -1 
	END IF
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//2. Item List 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	ll_row = dw_item.RowCount()
	For i = 1 To ll_row
		ls_temp 			= String(i, '000') + ' ' //순번
		ls_itemcod 		= trim(dw_item.Object.itemcod[i])
		ldec_saleamt	= dw_item.Object.payamt[i]	

		select itemnm INTO :ls_itemnm FROM itemmst
		 WHERE itemcod = :ls_itemcod ;
		IF sqlca.sqlcode <> 0 OR IsNull(ls_itemnm) then ls_itemnm = "" 

		ls_temp 	+= LeftA(ls_itemnm + space(24), 24) + ' '  //아이템
		ls_temp 	+= '   1' + ' '   	  //수량
		ls_val 	= fs_convert_amt(ldec_saleamt,  8)
		ls_temp 	+= ls_val //금액
		f_printpos(ls_temp)	
	
		ls_regcod =  trim(dw_item.Object.regcod[i])
		//regcode master read
		select keynum, 		trim(facnum)
		  INTO :ll_keynum,	:ls_facnum
		  FROM regcodmst
		 where regcod = :ls_regcod ;
	
		IF IsNull(ll_keynum) 	then ll_keynum 	= 0
		IF IsNull(ls_facnum) 	then ls_facnum 	= ""
		ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
		f_printpos(ls_temp)
	NEXT
	f_printpos(ls_lin1)
	ls_val 	= fs_convert_sign(ldc_payamt, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)

	ls_val 	= fs_convert_sign(ldc_payamt,  8)
	ls_temp 	= LeftA("Cash" + space(33), 33) + ls_val
	f_printpos(ls_temp)
	
	ls_val 	= fs_convert_sign(0,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
   F_POS_FOOTER(ls_memberid, ls_appseq, gs_user_id)
next 
PRN_ClosePort()
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//   출력 완료	
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Return 0

end function

on b1w_reg_prepay_popup.create
int iCurrent
call super::create
this.dw_item=create dw_item
this.dw_cond=create dw_cond
this.p_close=create p_close
this.p_save=create p_save
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_item
this.Control[iCurrent+2]=this.dw_cond
this.Control[iCurrent+3]=this.p_close
this.Control[iCurrent+4]=this.p_save
end on

on b1w_reg_prepay_popup.destroy
call super::destroy
destroy(this.dw_item)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_save)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_prepay_popup
	Desc	: 	후불서비스 신청시 선수금정보 등록
	Ver.	:	1.0
	Date	: 	2004.12.20
	programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
String ls_paycod, ls_name[], ls_tmp, ls_ref_desc, ls_paymethod

is_orderno = ""
is_customerid = ""
is_contractseq = ""


//window 중앙에
f_center_window(b1w_reg_prepay_popup)

//Data 받아오기
ib_order       = iu_cust_msg.ib_data[1]
is_orderno     = String(iu_cust_msg.il_data[1])
is_contractseq = String(iu_cust_msg.il_data[2])
is_customerid  = iu_cust_msg.is_data[2]
is_pgm_id      = iu_cust_msg.is_data[3]
is_memberid    = iu_cust_msg.is_data[4]
is_priceplan   = iu_cust_msg.is_data[5]

//ohj add 2005.07.26 
ls_tmp= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_paycod =ls_name[5] 

//PayMethod
ls_paymethod = fs_get_control("C1", "A200", ls_ref_desc)

dw_cond.Object.paymethod[1]   = ls_paymethod
dw_cond.Object.memberid[1]    = is_memberid
dw_cond.Object.paytype[1]     = ls_paycod
dw_cond.Object.payid[1]       = is_customerid
dw_cond.Object.orderno[1]     = is_orderno
dw_cond.Object.contractseq[1] = is_contractseq
dw_cond.Object.paydt[1]       = Date(fdt_get_dbserver_now())

dw_cond.SetTransObject( SQLCA ) 


end event

type dw_item from datawindow within b1w_reg_prepay_popup
boolean visible = false
integer x = 2359
integer y = 564
integer width = 389
integer height = 96
integer taborder = 20
boolean titlebar = true
string title = "dw_item"
string dataobject = "ssrt_reg_prepay_popup_itemlist"
boolean border = false
end type

event constructor;This.SetTransObject(sqlca)
end event

type dw_cond from u_d_external within b1w_reg_prepay_popup
integer x = 96
integer y = 40
integer width = 2240
integer height = 680
integer taborder = 10
string dataobject = "b1dw_cnd_prepay_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
end type

type p_close from u_p_close within b1w_reg_prepay_popup
integer x = 2432
integer y = 300
end type

type p_save from u_p_save within b1w_reg_prepay_popup
integer x = 2432
integer y = 140
end type

