$PBExportHeader$b1w_inq_quota_item_popup.srw
$PBExportComments$[kem] 할부품목 신청 item popup
forward
global type b1w_inq_quota_item_popup from w_base
end type
type p_close from u_p_close within b1w_inq_quota_item_popup
end type
type dw_detail from u_d_sort within b1w_inq_quota_item_popup
end type
type ln_2 from line within b1w_inq_quota_item_popup
end type
end forward

global type b1w_inq_quota_item_popup from w_base
integer width = 2359
integer height = 1140
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
p_close p_close
dw_detail dw_detail
ln_2 ln_2
end type
global b1w_inq_quota_item_popup b1w_inq_quota_item_popup

type variables
String is_orderno, is_priceplan
end variables

event ue_ok();Long ll_row
//조회
ll_row = dw_detail.Retrieve(is_orderno, is_priceplan)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If

end event

event ue_close;Close(This)
end event

on b1w_inq_quota_item_popup.create
int iCurrent
call super::create
this.p_close=create p_close
this.dw_detail=create dw_detail
this.ln_2=create ln_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_close
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.ln_2
end on

on b1w_inq_quota_item_popup.destroy
call super::destroy
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	:	b1w_inq_quota_item_popup
	Desc	:  해당 할부품목의 품목 정보
	Ver	: 	1.0
	Date	: 	2003.10.20
	Programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_name[], ls_type
Integer li_cnt

f_center_window(b1w_inq_quota_item_popup)
is_orderno = ""
iu_cust_msg = Message.PowerObjectParm

is_orderno = iu_cust_msg.is_data[1]
is_priceplan = iu_cust_msg.is_data[2]


//Format 지정
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "P105", ls_ref_desc)
li_cnt = fi_cut_string(ls_temp, ";", ls_name[])

Select currency_type
  Into :ls_type
  From priceplanmst
 Where priceplan = :is_priceplan;

If ls_name[1] = ls_type Then
	dw_detail.object.priceplan_rate2_unitcharge.Format = "#,##0"
	
Else
	dw_detail.object.priceplan_rate2_unitcharge.Format = "#,##0.000000"
End If

If is_orderno <> "" Then
	Post Event ue_ok()
End If
end event

type p_close from u_p_close within b1w_inq_quota_item_popup
integer x = 1993
integer y = 932
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_quota_item_popup
integer x = 27
integer y = 48
integer width = 2277
integer height = 848
integer taborder = 10
string dataobject = "b1dw_inq_quota_item_pop"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
boolean ib_sort_use = false
end type

type ln_2 from line within b1w_inq_quota_item_popup
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

