$PBExportHeader$p0w_reg_out_cancel.srw
$PBExportComments$[uhmjj] 카드판매출고 취소
forward
global type p0w_reg_out_cancel from w_a_reg_m
end type
type p_cancel from u_p_cancel within p0w_reg_out_cancel
end type
end forward

global type p0w_reg_out_cancel from w_a_reg_m
integer width = 3099
event type integer ue_cancel ( )
p_cancel p_cancel
end type
global p0w_reg_out_cancel p0w_reg_out_cancel

type variables
Long il_row, il_row2, il_get_row
end variables

event type integer ue_cancel();Integer li_return, li_rc
Long    ll_sale_cnt, ll_out_qty
Dec     lc_outseq
String  ls_ref_desc, ls_temp, ls_result[], ls_status, ls_flag

//선불카드마스터 판매내역 체크
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P101", ls_ref_desc)
If ls_temp = "" Then Return -1

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return -1
ls_status = ls_result[2]

//선불카드마스터 재고구분 체크
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P112", ls_ref_desc)
If ls_temp = "" Then Return -1

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return -1
ls_flag = ls_result[1]               //판매

lc_outseq = dw_detail.object.outseq[il_get_row]
ll_out_qty = dw_detail.object.out_qty[il_get_row]

Select Count(*) 
Into :ll_sale_cnt
From p_cardmst
Where status = :ls_status
And outseq = :lc_outseq
And sale_flag = :ls_flag;

//p_outlog 와 p_cardmst 에 수량이 같아야 판매출고취소 가능
If ll_sale_cnt = ll_out_qty Then 
	// 처리부분
	p0c_dbmgr5 iu_db
	iu_db = Create p0c_dbmgr5
	iu_db.is_title = Title	
	iu_db.is_caller = "p0w_reg_out_cancel"
	iu_db.ic_data[1] = lc_outseq
	iu_db.uf_prc_db()

   li_rc = iu_db.ii_rc
	Destroy iu_db

	f_msg_info(3000, This.Title, "선불카드 판매출고 취소")
	Return 0
Else
	MessageBox("System Control","판매상태가 아닌 카드가 있어 취소 할 수 없습니다.")
	Return -1
End If
end event

on p0w_reg_out_cancel.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
end on

on p0w_reg_out_cancel.destroy
call super::destroy
destroy(this.p_cancel)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : p0w_reg_out_cancle
	Desc : 선불카드 판매출고 취소
	Date : 2004.10.14
	Auth.: 엄재준
--------------------------------------------------------------------------*/
dw_detail.SetRowFocusIndicator(Off!)
end event

event ue_ok();call super::ue_ok;String ls_where, ls_outdt_fr, ls_outdt_to, ls_pricemodel, ls_partner_prefix
Long ll_row
Integer li_return
Date ld_outdt_fr, ld_outdt_to

ld_outdt_fr = dw_cond.Object.outdt_fr[1]
ld_outdt_to = dw_cond.Object.outdt_to[1]
ls_outdt_fr = String(dw_cond.Object.outdt_fr[1],'yyyy-mm-dd')
ls_outdt_to = String(dw_cond.Object.outdt_to[1],'yyyy-mm-dd')
ls_pricemodel = Trim(dw_cond.Object.pricemodel[1])
ls_partner_prefix = Trim(dw_cond.Object.partner_prefix[1])

If IsNull(ls_outdt_fr) Then ls_outdt_fr = ""
If IsNull(ls_outdt_to) Then ls_outdt_to = ""
If IsNull(ls_pricemodel) Then ls_pricemodel = ""
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""
	  
ls_where = ""

If ls_outdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(outdt,'yyyy-mm-dd') >= '" + ls_outdt_fr + "' "
End If
If ls_outdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(outdt,'yyyy-mm-dd') <= '" + ls_outdt_to + "' "
End If
If ls_pricemodel <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pricemodel = '" + ls_pricemodel + "' "
End If
If ls_partner_prefix <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "partner_prefix = '" + ls_partner_prefix + "' "
End If
If ls_outdt_fr <> "" AND ls_outdt_to <> "" Then
	li_return = fi_chk_frto_day(ld_outdt_fr, ld_outdt_to)
	If li_return = -1 Then
	 f_msg_usr_err(211, Title, "출고일자")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("oudt_fr")
	 Return 
	End If
End If
	
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retreive()")
End If

p_cancel.TriggerEvent("ue_enable")

Return
end event

event resize;call super::resize;If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_cancel.Y = newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;p_cancel.TriggerEvent("ue_disable")

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within p0w_reg_out_cancel
integer y = 76
integer width = 2025
integer height = 224
string dataobject = "p1dw_cnd_prt_outlog"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p0w_reg_out_cancel
integer x = 2281
integer y = 44
end type

type p_close from w_a_reg_m`p_close within p0w_reg_out_cancel
integer x = 2587
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within p0w_reg_out_cancel
integer width = 2098
integer height = 336
end type

type p_delete from w_a_reg_m`p_delete within p0w_reg_out_cancel
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within p0w_reg_out_cancel
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within p0w_reg_out_cancel
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within p0w_reg_out_cancel
integer y = 368
integer height = 1196
string dataobject = "p0dw_reg_out_cancle"
end type

event dw_detail::clicked;call super::clicked;If Row = 0 then Return

// 선택 ROW 표시
If IsSelected( Row ) then
	SelectRow( Row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( Row , TRUE )
End If

il_get_row = Row


end event

type p_reset from w_a_reg_m`p_reset within p0w_reg_out_cancel
integer x = 370
integer y = 1600
integer height = 92
end type

type p_cancel from u_p_cancel within p0w_reg_out_cancel
integer x = 55
integer y = 1600
integer height = 92
boolean bringtotop = true
end type

event clicked;call super::clicked;//
end event

