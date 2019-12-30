$PBExportHeader$mobile_reg_svc_req_hot.srw
$PBExportComments$해지정산내역입력
forward
global type mobile_reg_svc_req_hot from w_a_reg_m
end type
type dw_rate from u_d_external within mobile_reg_svc_req_hot
end type
end forward

global type mobile_reg_svc_req_hot from w_a_reg_m
integer width = 2981
integer height = 3288
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
dw_rate dw_rate
end type
global mobile_reg_svc_req_hot mobile_reg_svc_req_hot

on mobile_reg_svc_req_hot.create
int iCurrent
call super::create
this.dw_rate=create dw_rate
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_rate
end on

on mobile_reg_svc_req_hot.destroy
call super::destroy
destroy(this.dw_rate)
end on

event ue_extra_save;Long 		ll_row, ll_i, ll_ref_reqno, ll_seq
String 	ls_customerid, ls_contractseq, ls_fileformcd, ls_fileitem, ls_itemcod, ls_amtmon, ls_sale_month
date 		ld_sale_month
decimal 	ld_saleamt, ld_rate, ld_margin
integer  li_amtmon

dw_detail.accepttext()
ll_row = dw_detail.RowCount()

If ll_row < 0 Then Return 0

ld_rate = dw_rate.object.exrate[1]
ld_margin = dw_rate.object.margin[1]

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	
	For li_amtmon = 1 to 2 //amt_mon1, amt_mon2
		
		SELECT SEQ_HOT_PARTNERSALE.NEXTVAL INTO :ll_seq
		FROM DUAL;
		
		if li_amtmon = 1 then 
			ls_sale_month = dw_detail.object.sale_month[1] + '/01'
			ld_sale_month 	= date(ls_sale_month) // date(string(dw_cond.object.reqdt[1], '@@@@/@@/@@'))
		else
			ls_sale_month = dw_detail.object.sale_month1[1] + '/01'
			ld_sale_month 	= date(ls_sale_month)
		end if
		ls_customerid 	= dw_cond.object.customerid[1]
		ls_contractseq = dw_cond.object.contractseq[1]
		ls_fileformcd 	= dw_cond.object.fileformcd[1]
		ll_ref_reqno 	= long(dw_cond.object.reqno[1])
		ls_fileitem   	= dw_detail.object.fileitem[ll_i]
		ls_itemcod 		= dw_detail.object.itemcod[ll_i]
		ls_amtmon 		= 'amt_mon' + string(li_amtmon)
		ld_saleamt = dw_detail.getitemnumber(ll_i, ls_amtmon)
		
		
		if ld_saleamt <> 0 then
			
			INSERT INTO HOT_PARTNER_SALE
			( SEQ, 		SALE_MONTH,		CUSTOMERID,		CONTRACTSEQ,		FILEFORMCD,
			  FILEITEM,	ITEMCOD,			SALEAMT,			SALECNT,				RATE,
			  MARGIN,	REF_REQNO,		CRT_USER,		CRTDT)//, 				PGM_ID)
			VALUES
			( :ll_seq,			:ld_sale_month,	:ls_customerid, 	:ls_contractseq, 	:ls_fileformcd,
			  :ls_fileitem, 	:ls_itemcod, 		:ld_saleamt, 		1, 					:ld_rate,
			  :ld_margin, 		:ll_ref_reqno, 	:gs_user_id, 		sysdate);//, 			:gs_pgm_id);
			  
			  
			IF SQLCA.SQLCode < 0 THEN
					f_msg_sql_err(Title, string(SQLCA.SQLCode) +" (HOT_PARTNER_SALE)")
					Return -1
			end if
		
		end if
		
	next 
	
Next

	//신청 완료처리
	UPDATE SVC_REQ_MST SET
			COMEPLETE_YN = 'Y',
			TO_OPER = :gs_user_id,
			TO_CRTDT = sysdate
	WHERE REQNO = :ll_ref_reqno
	  AND CONTRACTSEQ = to_number(:ls_contractseq);
	  
	IF SQLCA.SQLCode < 0 THEN
					f_msg_sql_err(Title, string(SQLCA.SQLCode) +" (SVC_REQ_MST)")
					Return -1
	end if


Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: mobile_reg_svc_req_hot
	Desc.	: 개통처 핫빌정산내역 입력
	Ver 	: 1.0
	Date	: 2015.03.27
	Progrmaer: HMK
-------------------------------------------------------------------------*/


STRING	ls_customerid, ls_sale_month, ls_priceplan, ls_validkey, ls_fileformcd, ls_customernm
long 		ll_ref_reqno, ll_contractseq
integer 	li_row
datetime ld_sale_month

dw_detail.InsertRow(0)

//iu_cust_msg.ib_data[1]  = FALSE
//iu_cust_msg.is_data[1]  = "CloseWithReturn"
//iu_cust_msg.il_data[1]  = row  		
//iu_cust_msg.idw_data[1] = dw_master
//iu_cust_msg.is_data[2]  = ls_req_code

iu_cust_msg = Create u_cust_a_msg


iu_cust_msg = Message.PowerObjectParm
li_row = iu_cust_msg.il_data[1]

ls_customerid 	= iu_cust_msg.idw_data[1].object.svc_req_mst_customerid[li_row]
ls_customernm	= iu_cust_msg.idw_data[1].object.customernm[li_row]
ll_contractseq = iu_cust_msg.idw_data[1].object.svc_req_mst_contractseq[li_row]
ls_validkey 	= iu_cust_msg.idw_data[1].object.validinfo_validkey[li_row]
ld_sale_month 	= iu_cust_msg.idw_data[1].object.svc_req_mst_reqdt[li_row]
ll_ref_reqno 	= iu_cust_msg.idw_data[1].object.svc_req_mst_reqno[li_row]


dw_cond.object.customerid[1]  = ls_customerid
dw_cond.object.customernm[1]  = ls_customernm
dw_cond.object.validkey[1]		= ls_validkey
dw_cond.object.contractseq[1]	= string(ll_contractseq)
dw_cond.object.reqno[1]			= string(ll_ref_reqno)
dw_cond.object.reqdt[1]			= string(ld_sale_month, 'yyyymmdd')



SELECT FILEFORMCD INTO :ls_fileformcd
FROM REQFILEFORMMST
WHERE SVCCOD = (SELECT SVCCOD FROM CONTRACTMST WHERE CONTRACTSEQ = :ll_contractseq)
  AND FILEFORMCD LIKE 'HOTBIL%';

dw_cond.object.fileformcd[1] = ls_fileformcd

dw_detail.Retrieve(ls_fileformcd)
dw_rate.Retrieve(string(ld_sale_month, 'yyyymmdd'))

p_insert.visible = false
p_delete.visible = false


end event

event ue_insert;call super::ue_insert;
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event ue_reset;call super::ue_reset;//초기화
dw_detail.reset()

Return 0
end event

event ue_extra_insert;

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)


////Log 정보
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.updt_user[al_insert_row] = gs_user_id
//dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//
Return 0
end event

event close;call super::close;Destroy iu_cust_msg
end event

event ue_save;Constant Int LI_ERROR = -1
integer i

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
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
End If

p_save.TriggerEvent("ue_disable")

//저장한거로 인식하게 함.
For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next  


Return 0
end event

event resize;//
end event

type dw_cond from w_a_reg_m`dw_cond within mobile_reg_svc_req_hot
integer x = 41
integer y = 52
integer width = 1929
integer height = 224
string dataobject = "mobile_cnd_svc_req_hot"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within mobile_reg_svc_req_hot
integer x = 1093
integer y = 3228
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within mobile_reg_svc_req_hot
integer x = 2418
integer y = 128
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within mobile_reg_svc_req_hot
integer x = 18
integer width = 1979
integer height = 432
end type

type p_delete from w_a_reg_m`p_delete within mobile_reg_svc_req_hot
integer x = 370
integer y = 3228
end type

type p_insert from w_a_reg_m`p_insert within mobile_reg_svc_req_hot
integer x = 78
integer y = 3228
end type

type p_save from w_a_reg_m`p_save within mobile_reg_svc_req_hot
integer x = 2117
integer y = 124
end type

type dw_detail from w_a_reg_m`dw_detail within mobile_reg_svc_req_hot
integer x = 27
integer y = 476
integer width = 2912
integer height = 2668
string dataobject = "mobile_svc_req_hot_det"
boolean hscrollbar = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;string ls_salemonth1, ls_salemonth2


select to_char(reqdt,'yyyy/mm'), to_char(add_months(reqdt, 1),'yyyy/mm') into :ls_salemonth1, :ls_salemonth2
from reqconf
where chargedt = '1';


dw_detail.object.sale_month[1] = ls_salemonth1
dw_detail.object.sale_month1[1] = ls_salemonth2

end event

type p_reset from w_a_reg_m`p_reset within mobile_reg_svc_req_hot
integer x = 654
integer y = 3228
end type

type dw_rate from u_d_external within mobile_reg_svc_req_hot
integer x = 654
integer y = 316
integer width = 1230
integer height = 80
integer taborder = 60
boolean bringtotop = true
string dataobject = "mobile_cnd_rate_term"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

