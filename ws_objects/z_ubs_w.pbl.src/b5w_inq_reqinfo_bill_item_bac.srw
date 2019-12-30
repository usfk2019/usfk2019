$PBExportHeader$b5w_inq_reqinfo_bill_item_bac.srw
$PBExportComments$모바일 품목별 청구서
forward
global type b5w_inq_reqinfo_bill_item_bac from w_a_inq_m_m
end type
type p_1 from u_p_print within b5w_inq_reqinfo_bill_item_bac
end type
end forward

global type b5w_inq_reqinfo_bill_item_bac from w_a_inq_m_m
integer width = 2775
integer height = 2284
boolean maxbox = false
event ue_print ( )
p_1 p_1
end type
global b5w_inq_reqinfo_bill_item_bac b5w_inq_reqinfo_bill_item_bac

type variables
String is_format
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
end prototypes

event ue_print();IF dw_detail.rowCount() > 0 Then
	dw_detail.Print()
END IF
end event

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay id(wfi_get_payid)")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

event ue_ok;Long		ll_rows, ll_i
String	ls_where
String	ls_payid, ls_paynm

ls_payid = Trim(dw_cond.Object.payid[1])

//Error 처리부분
If IsNull(ls_payid) Then ls_payid = ""

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Payer ID")
	dw_cond.SetColumn("payid")
	Return
End If

//Dynamic SQL
ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= " payid = '"+ ls_payid +"'"
End If

dw_master.is_where = ls_where
//Retrieve
ll_rows	= dw_master.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If



dw_detail.object.datawindow.Zoom =   95 
end event

on b5w_inq_reqinfo_bill_item_bac.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b5w_inq_reqinfo_bill_item_bac.destroy
call super::destroy
destroy(this.p_1)
end on

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_reqinfo_bill_item_bac
integer x = 55
integer y = 64
integer width = 1518
integer height = 148
string dataobject = "b5d_cnd_inq_reqinfo_bill"
boolean controlmenu = true
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;//Choose Case dwo.Name
//	Case "payid"
//		If iu_cust_help.ib_data[1] Then
//			Object.payid[row] = iu_cust_help.is_data[1]
//			Object.paynm[row] = iu_cust_help.is_data[2]
//		End If

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
//	Case "customerid"
//		If iu_cust_help.ib_data[1] Then
//			This.Object.customerid[1] = iu_cust_help.is_data2[1]
//			This.Object.customernm[1] = iu_cust_help.is_data2[2]			
//		End If	
End Choose

AcceptText()

Return 0 
		
		
		
		
//	Case "partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.partner[row] = iu_cust_help.is_data[1]
//			Object.partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "settle_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.settle_partner[row] = iu_cust_help.is_data[1]
//			Object.settle_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "maintain_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.maintain_partner[row] = iu_cust_help.is_data[1]
//			Object.maintain_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "reg_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.reg_partner[row] = iu_cust_help.is_data[1]
//			Object.reg_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "sale_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.sale_partner[row] = iu_cust_help.is_data[1]
//			Object.sale_partnernm[row] = iu_cust_help.is_data[2]
//		End If
		
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_payid
int    li_rc

Choose Case Dwo.Name
	Case "payid"
		ls_payid = dw_cond.object.payid[1]
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.Object.payid[1] = ""
			dw_cond.Object.paynm[1] = ""
			dw_cond.SetColumn("payid")
			return 2
		End IF
End Choose

end event

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_reqinfo_bill_item_bac
integer x = 1605
integer y = 36
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_reqinfo_bill_item_bac
integer x = 1893
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_reqinfo_bill_item_bac
integer width = 1554
integer height = 232
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_reqinfo_bill_item_bac
integer y = 284
integer width = 2021
integer height = 448
string dataobject = "b5d_inq_mst_reqinfo_bill"
boolean hscrollbar = false
boolean hsplitscroll = false
boolean ib_sort_use = false
end type

event dw_master::clicked;call super::clicked;String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
End Choose

end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_reqinfo_bill_item_bac
integer x = 32
integer y = 784
integer width = 2021
integer height = 1356
string dataobject = "b5d_inq_detail_reqinfo_bill_itemsale"
borderstyle borderstyle = stylebox!
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_retrieve;String	ls_where, ls_reqdt, ls_reqterm, ls_hd_ym
Integer 	li_rc, i, li_cnt, li_bilseq
Long 		ll_rc, ll_row, ll_masterrow
Date 		ld_workdt, ld_workdt_to
String   ls_trcod, ls_bilcod, ls_desc[], ls_payid, ls_trdt

this.SetRedraw(false)
dw_master.AcceptText()		
ll_masterrow = dw_master.GetSelectedrow(0)
//Master에 Row 없으면 
If ll_masterrow = -1 Then Return -1


ls_payid = dw_cond.object.payid[1]
ls_trdt = String(dw_master.object.trdt[al_select_row],'yyyymmdd')

ll_row = this.retrieve(ls_payid, ls_trdt)

dw_detail.object.title.text = "LG Uplus Billing Statement"

//reqamtinfo_desc 에 값채우기 START
SELECT COUNT(*) INTO :li_cnt
FROM REQAMTINFO
WHERE TRDT = :ls_trdt 
  AND PAYID = :ls_payid;
  
IF li_cnt > 0 then
	
		SELECT      BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05, 
						BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
						BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15, 
						BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20, 
						BTRDESC21, BTRDESC22, BTRDESC23, BTRDESC24, BTRDESC25, 
						BTRDESC26, BTRDESC27, BTRDESC28, BTRDESC29, BTRDESC30 
		INTO     :ls_desc[1], :ls_desc[2], :ls_desc[3], :ls_desc[4], :ls_desc[5],
					:ls_desc[6], :ls_desc[7], :ls_desc[8], :ls_desc[9], :ls_desc[10],
					:ls_desc[11], :ls_desc[12], :ls_desc[13], :ls_desc[14], :ls_desc[15],
					:ls_desc[16], :ls_desc[17], :ls_desc[18], :ls_desc[19], :ls_desc[20],
					:ls_desc[21], :ls_desc[22], :ls_desc[23], :ls_desc[24], :ls_desc[25],
					:ls_desc[26], :ls_desc[27], :ls_desc[28], :ls_desc[29], :ls_desc[30]
		FROM REQAMTINFO
		WHERE TRDT = :ls_trdt 
		  AND PAYID = :ls_payid;

ELSE

		SELECT      BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05, 
						BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
						BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15, 
						BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20, 
						BTRDESC21, BTRDESC22, BTRDESC23, BTRDESC24, BTRDESC25, 
						BTRDESC26, BTRDESC27, BTRDESC28, BTRDESC29, BTRDESC30
		INTO     :ls_desc[1], :ls_desc[2], :ls_desc[3], :ls_desc[4], :ls_desc[5],
					:ls_desc[6], :ls_desc[7], :ls_desc[8], :ls_desc[9], :ls_desc[10],
					:ls_desc[11], :ls_desc[12], :ls_desc[13], :ls_desc[14], :ls_desc[15],
					:ls_desc[16], :ls_desc[17], :ls_desc[18], :ls_desc[19], :ls_desc[20],
					:ls_desc[21], :ls_desc[22], :ls_desc[23], :ls_desc[24], :ls_desc[25],
					:ls_desc[26], :ls_desc[27], :ls_desc[28], :ls_desc[29], :ls_desc[30]
		FROM REQAMTINFOH
		WHERE TRDT = :ls_trdt 
		  AND PAYID = :ls_payid;

END IF

for i = 1 to ll_row
	ls_trcod = dw_detail.object.trcod[i]
	
	//trcod 로 bilseq 구하기
	SELECT  B.BILSEQ, A.BILCOD into :li_bilseq, :ls_bilcod
	FROM INVOICE_ITEM_DET A, INVOICE_ITEM_SEQ B
	WHERE A.BILCOD = B.BILCOD
		 AND A.INV_TYPE = B.INV_TYPE
		 AND A.INV_TYPE = 'B001' 
		 AND A.TRCOD = :ls_trcod;
   
	dw_detail.object.reqamtinfo_desc[i] = ls_desc[li_bilseq]
	
next
//reqamtinfo_desc 에 값채우기 END


If li_rc < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If
		

this.SetRedraw(True)

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_reqinfo_bill_item_bac
integer x = 23
integer y = 740
integer height = 36
end type

type p_1 from u_p_print within b5w_inq_reqinfo_bill_item_bac
integer x = 1605
integer y = 140
boolean bringtotop = true
boolean originalsize = false
end type

