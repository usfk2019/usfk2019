$PBExportHeader$b3w_inq_discount_customer.srw
$PBExportComments$[jwlee] 할인고객으로 조회
forward
global type b3w_inq_discount_customer from w_a_inq_m
end type
end forward

global type b3w_inq_discount_customer from w_a_inq_m
integer width = 3666
integer height = 1844
end type
global b3w_inq_discount_customer b3w_inq_discount_customer

type variables
boolean ib_sort_use 
end variables

on b3w_inq_discount_customer.create
call super::create
end on

on b3w_inq_discount_customer.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;Long ll_row
String ls_where
String ls_cddiscount,ls_customerid


//조회시 상단에 입력한 내용으로 조회
ls_customerid = Trim(dw_cond.Object.customerid[1])

If IsNull(ls_cddiscount) Then ls_cddiscount = ""
If IsNull(ls_customerid) Then ls_customerid = ""

ls_where = ""

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.customerid = '" + ls_customerid + "' "	
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If








end event

type dw_cond from w_a_inq_m`dw_cond within b3w_inq_discount_customer
integer y = 64
integer width = 1682
integer height = 124
string dataobject = "b3dw_cnd_discount_customer"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 //This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid

Choose Case dwo.name
		
	case 'customerid' 
		
		 select nvl(customernm,'')
		   into :ls_customerid
			from customerm
		  where customerid = :data;

		if SQLCA.SQLCODE >= 0 then
			 dw_cond.object.customernm[1] = ls_customerid
		end if					 
end Choose
end event

type p_ok from w_a_inq_m`p_ok within b3w_inq_discount_customer
integer x = 2743
integer y = 56
end type

type p_close from w_a_inq_m`p_close within b3w_inq_discount_customer
integer x = 3045
integer y = 56
end type

type gb_cond from w_a_inq_m`gb_cond within b3w_inq_discount_customer
integer width = 1765
integer height = 232
end type

type dw_detail from w_a_inq_m`dw_detail within b3w_inq_discount_customer
integer y = 256
integer width = 3575
integer height = 1440
string dataobject = "b3dw_inq_discount_customer"
boolean ib_sort_use = false
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_SORT = Object.customerid_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_detail::constructor;call super::constructor;ib_sort_use = true
end event

event dw_detail::clicked;call super::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

