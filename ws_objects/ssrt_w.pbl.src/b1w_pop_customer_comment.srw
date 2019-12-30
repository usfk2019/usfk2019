$PBExportHeader$b1w_pop_customer_comment.srw
$PBExportComments$Help : 사용자 ID
forward
global type b1w_pop_customer_comment from w_a_reg_m
end type
end forward

global type b1w_pop_customer_comment from w_a_reg_m
integer width = 2894
integer height = 1656
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global b1w_pop_customer_comment b1w_pop_customer_comment

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt, is_act_gu, is_reg_partner
String is_priceplan,is_customerid, is_partner, is_svccod, is_itemcod[], is_main_itemcod, is_adtype
Long il_cnt, il_customer_hw, il_contractseq, il_itemcodcnt
Boolean ib_order

end variables

on b1w_pop_customer_comment.create
call super::create
end on

on b1w_pop_customer_comment.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_pop_customer_comment
	Desc	: 	코멘트 등록 팝업
	Ver.	:	1.0
	Date	: 	2010.01.28
	programer : JHCHOI
-------------------------------------------------------------------------*/
LONG		ll_row

is_customerid 	= ""
il_cnt 			= 0

//window 중앙에
f_center_window(this)

//Data 받아오기
is_customerid  = iu_cust_msg.is_data[1]
is_pgmid       = iu_cust_msg.is_data[2]

TriggerEvent("ue_ok")
end event

event ue_ok;LONG		ll_row,			ll_seq

ll_row = dw_cond.Retrieve(is_customerid)

IF ll_row <=0 THEN
	TriggerEvent("ue_insert")
	p_insert.TriggerEvent("ue_disable")	
	p_save.TriggerEvent("ue_enable")
ELSE
	ll_seq = dw_cond.Object.seq[1]
	
	dw_detail.Retrieve(is_customerid, ll_seq)
	
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_disable")
END IF

RETURN
end event

event ue_save;Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail.AcceptText() < 0 Then
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
	
End If

f_msg_info(3000,This.Title,"Save")

Trigger Event ue_ok()

p_save.TriggerEvent("ue_disable")

Return 0
end event

event closequery;Int li_rc

dw_detail.AcceptText()

//다시 재정의
If (dw_detail.ModifiedCount() > 0) and il_cnt = 0 Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
	//MessageBox(This.Title, "'서비스품목 할부 등록' 메뉴에서 할부정보를 등록하십시오")
   If li_rc <> 1 Then  Return 1 //Process Cancel
   Return 0
End If
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

dw_detail.Reset()

p_save.TriggerEvent("ue_disable")

Return 0
end event

event resize;//
end event

event ue_insert;CONSTANT INT LI_ERROR = -1
LONG		ll_row,			ll_seq
DATETIME	ldt_sysdate
STRING	ls_emp_nm

dw_detail.Reset()

ll_row = dw_detail.InsertRow(0)

dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

SELECT NVL(MAX(SEQ), 0) + 1, SYSDATE INTO :ll_seq, :ldt_sysdate
FROM   CUSTOMER_COMMENT
WHERE  CUSTOMERID = :is_customerid;

SELECT EMPNM INTO :ls_emp_nm
FROM   SYSUSR1T
WHERE  EMP_ID = :gs_user_id;

dw_detail.Object.customerid[ll_row]	= is_customerid
dw_detail.Object.seq[ll_row]			= ll_seq
dw_detail.Object.crt_user[ll_row]	= gs_user_id
dw_detail.Object.empnm[ll_row]		= ls_emp_nm
dw_detail.Object.crtdt[ll_row]		= ldt_sysdate
dw_detail.Object.shopid[ll_row]		= gs_shopid
dw_detail.Object.view_yn[ll_row]		= "Y"

p_save.TriggerEvent("ue_enable")

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_pop_customer_comment
integer x = 23
integer y = 28
integer width = 2514
integer height = 704
string dataobject = "b1dw_pop_customer_comment_mst"
boolean border = true
end type

event dw_cond::clicked;LONG		ll_seq

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

ll_seq = THIS.Object.seq[row]

dw_detail.Retrieve(is_customerid, ll_seq)

end event

event dw_cond::doubleclicked;//
end event

event dw_cond::itemchanged;//
end event

event dw_cond::sqlpreview;//
end event

type p_ok from w_a_reg_m`p_ok within b1w_pop_customer_comment
boolean visible = false
integer x = 2569
integer y = 36
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_pop_customer_comment
integer x = 2569
integer y = 264
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_pop_customer_comment
boolean visible = false
integer width = 2994
integer height = 760
end type

type p_delete from w_a_reg_m`p_delete within b1w_pop_customer_comment
boolean visible = false
integer x = 1010
integer y = 1888
end type

type p_insert from w_a_reg_m`p_insert within b1w_pop_customer_comment
integer x = 2569
integer y = 32
end type

type p_save from w_a_reg_m`p_save within b1w_pop_customer_comment
integer x = 2569
integer y = 148
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_pop_customer_comment
integer x = 23
integer y = 748
integer width = 2514
integer height = 788
string dataobject = "b1dw_pop_customer_comment_det"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;//
end event

type p_reset from w_a_reg_m`p_reset within b1w_pop_customer_comment
boolean visible = false
integer x = 2569
integer y = 260
boolean enabled = true
end type

